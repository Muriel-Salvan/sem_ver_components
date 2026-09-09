require 'git'

module SemVerComponents
  # Analyzer of a local git repository
  class LocalGit
    attr_reader :git_from, :git_to, :git

    # Constructor
    #
    # @param git_repo [String] The git repository to analyze
    # @param git_from [String, nil] The git from ref
    # @param git_to [String] The git to ref
    def initialize(git_repo, git_from, git_to)
      @git_repo = git_repo
      @git_from = git_from
      @git_to = git_to
      @git = Git.open(@git_repo)
    end

    # Get full the git log.
    # Keep a cache of it.
    #
    # @return [Git::Log::Result] Full git log (Enumerable of Git::Object::Commit)
    def git_log
      @git_log = @git.log(nil).execute unless defined?(@git_log)
      @git_log
    end

    # Semantically analyze commits.
    #
    # @return [Array<Hash{Symbol => Object}>] The commits information:
    #   - +:components_bump_levels+ [Hash\\{String or nil => Integer}] Set of bump levels (0: patch, 1: minor, 2: major) per component name (nil for global)
    #   - +:commit+ (Git::Object::Commit): Corresponding git commit
    def analyze_commits
      @git.log(nil).between(git_from.nil? ? git_log.last.sha : git_from, git_to).execute.map do |git_commit|
        # Analyze the message
        # Always consider a minimum of global patch bump per commit.
        components_bump_levels = { nil => [0] }
        git_commit.message.scan(/\[([^\]]+)\]/).flatten(1).each do |commit_label|
          commit_type, component = commit_label =~ /^(.+)\((.+)\)$/ ? [::Regexp.last_match(1), ::Regexp.last_match(2)] : [commit_label, nil]
          components_bump_levels[component] = [] unless components_bump_levels.key?(component)
          components_bump_levels[component] <<
            case commit_type.downcase
            when 'break', 'breaking', 'major'
              2
            when 'feat', 'feature', 'minor'
              1
            else
              0
            end
        end
        {
          commit: git_commit,
          components_bump_levels: components_bump_levels.to_h { |component, component_bump_levels| [component, component_bump_levels.max] }
        }
      end
    end

    # Is the git to ref part of a release branch?
    #
    # @return [Boolean] Is the git to ref part of a release branch?
    def on_release_branch?
      # TODO: Handle `main` as well
      @git_to == 'master'
    end
  end
end
