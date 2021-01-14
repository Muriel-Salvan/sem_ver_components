module SemVerComponents

  module Outputs

    class SemanticReleaseAnalyze < Output

      # Process commits info
      #
      # Parameters::
      # * *commits_info* (Array< Hash<Symbol, Object> >): List of commits info:
      #   * *components_bump_levels* (Hash<String or nil, Integer>): Set of bump levels (0: patch, 1: minor, 2: major) per component name (nil for global)
      #   * *commit* (Git::Object::Commit): Corresponding git commit
      def process(commits_info)
        bump_level = commits_info.map { |commit_info| commit_info[:components_bump_levels].values }.flatten(1).max
        puts(
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
        )
      end

    end

  end

end
