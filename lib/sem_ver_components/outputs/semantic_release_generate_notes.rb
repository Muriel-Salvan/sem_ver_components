require 'time'

module SemVerComponents

  module Outputs

    class SemanticReleaseGenerateNotes < Output

      # Process commits info
      #
      # Parameters::
      # * *commits_info* (Array< Hash<Symbol, Object> >): List of commits info:
      #   * *components_bump_levels* (Hash<String or nil, Integer>): Set of bump levels (0: patch, 1: minor, 2: major) per component name (nil for global)
      #   * *commit* (Git::Object::Commit): Corresponding git commit
      def process(commits_info)
        # Compute new version
        new_version =
          if @local_git.git_from.nil?
            '0.0.1'
          elsif @local_git.git_from =~ /^v(\d+)\.(\d+)\.(\d+)$/
            major = Integer($1)
            minor = Integer($2)
            patch = Integer($3)
            bump_level = commits_info.map { |commit_info| commit_info[:components_bump_levels].values }.flatten(1).max
            case bump_level
            when 0
              patch += 1
            when 1
              minor += 1
              patch = 0
            when 2
              major += 1
              minor = 0
              patch = 0
            else
              raise "Invalid bump level: #{bump_level}"
            end
            "#{major}.#{minor}.#{patch}"
          else
            raise "Can't generate release notes from a git ref that is not a semantic release (#{@local_git.git_from})"
          end
        git_url = @local_git.git.remote('origin').url
        git_url = git_url[0..-5] if git_url.end_with?('.git')
        # Reference merge commits: merged commits will not be part of the changelog, but their bump level will be taken into account when reporting the merge commit.
        # List of merged commits' shas, per merge commit sha.
        # Hash< String, Array< String > >
        merge_commits = {}
        commits_info.each do |commit_info|
          git_commit = commit_info[:commit]
          git_commit_parents = git_commit.parents
          # In the case of a merge commit, reference all commits that are part of this merge commit, directly from the graph
          if git_commit_parents.size > 1
            git_commit_sha = git_commit.sha
            merge_commits[git_commit_sha] = @local_git.git_log.between(@local_git.git.merge_base(*git_commit_parents.map(&:sha)).first.sha, git_commit_sha)[1..-1].map(&:sha)
          end
        end
        commits_to_ignore = merge_commits.values.flatten(1).sort.uniq
        # Group commits per bump level, per component
        # Hash< String or nil, Hash< Integer, Array<Git::Object::Commit> >
        commits_per_component = {}
        commits_info.each do |commit_info|
          git_commit = commit_info[:commit]
          git_commit_sha = git_commit.sha
          # Don't put merged commits as we consider the changelog should contain the merge commit comment.
          next if commits_to_ignore.include?(git_commit_sha)
          components_bump_levels = commit_info[:components_bump_levels]
          # If we are dealing with a merge commit, consider the components' bump levels of the merged commits
          if merge_commits.key?(git_commit_sha)
            merge_commits[git_commit_sha].each do |merged_commit_sha|
              components_bump_levels = components_bump_levels.merge(
                commits_info.find { |search_commit_info| search_commit_info[:commit].sha == merged_commit_sha }[:components_bump_levels]
              ) do |component, bump_level_1, bump_level_2|
                [bump_level_1, bump_level_2].max
              end
            end
          end
          components_bump_levels.each do |component, bump_level|
            commits_per_component[component] = {} unless commits_per_component.key?(component)
            commits_per_component[component][bump_level] = [] unless commits_per_component[component].key?(bump_level)
            commits_per_component[component][bump_level] << git_commit
          end
        end
        puts "# [v#{new_version}](#{@git_hosting.compare_url(git_url, @local_git.git_from, "v#{new_version}")}) (#{Time.now.utc.strftime('%F %T')})"
        puts
        commits_per_component.sort_by { |component, _component_info| component || '' }.each do |(component, component_info)|
          puts "## #{component.nil? ? 'Global changes' : "Changes for #{component}"}\n" if commits_per_component.size > 1 || !component.nil?
          component_info.each do |bump_level, commits|
            puts "### #{
              case bump_level
              when 0
                'Patches'
              when 1
                'Features'
              when 2
                'Breaking changes'
              else
                raise "Invalid bump level: #{bump_level}"
              end
            }"
            puts
            # Gather an ordered set of commit lines (with the corresponding commit sha) in order to not duplicate the info when there are merge commits
            # Hash< String, String >
            commit_lines = {}
            commits.each do |commit|
              message_lines = commit.message.split("\n")
              commit_line = message_lines.first
              if commit_line =~ /^Merge pull request .+$/
                # Consider the next line as commit line
                next_line = message_lines[1..-1].join("\n").strip.split("\n").first
                commit_line = next_line unless next_line.nil?
              end
              commit_lines[commit_line] = commit.sha
            end
            commit_lines.each do |commit_line, commit_sha|
              puts "* [#{commit_line}](#{@git_hosting.commit_url(git_url, commit_sha)})"
            end
            puts
          end
        end
      end

    end

  end

end
