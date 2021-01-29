require 'sem_ver_components/semver'

module SemVerComponents

  module Outputs

    class Info < Output

      # Process commits info
      #
      # Parameters::
      # * *commits_info* (Array< Hash<Symbol, Object> >): List of commits info:
      #   * *components_bump_levels* (Hash<String or nil, Integer>): Set of bump levels (0: patch, 1: minor, 2: major) per component name (nil for global)
      #   * *commit* (Git::Object::Commit): Corresponding git commit
      def process(commits_info)
        # Display bump levels per component
        bumps_per_component = commits_info.inject({}) do |components_bump_levels, commit_info|
          components_bump_levels.merge(commit_info[:components_bump_levels]) do |_component, bump_level_1, bump_level_2|
            [bump_level_1, bump_level_2].max
          end
        end
        bumps_per_component.each do |component, bump_level|
          puts "#{component.nil? ? 'Global' : component}: Bump #{
              case bump_level
              when 0
                'patch'
              when 1
                'minor'
              when 2
                'major'
              else
                raise "Invalid bump level: #{bump_level}"
              end
            } version"
        end
        # Compute new version
        global_bump_level = bumps_per_component.values.max
        if global_bump_level.nil?
          puts 'No next version'
        else
          puts "Next global version#{@local_git.on_release_branch? ? '' : ' (not on release branch)'}: #{
            Semver.next_version_from(Semver.version_from_git_ref(@local_git.git_from), global_bump_level, pre_release: !@local_git.on_release_branch?)
          }"
        end
      end

    end

  end

end
