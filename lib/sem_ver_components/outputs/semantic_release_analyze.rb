module SemVerComponents
  module Outputs
    # Output plugin reporting the next version bump level in the semantic-release format
    class SemanticReleaseAnalyze < Output
      # Process commits info
      #
      # @param commits_info [Array<Hash{Symbol => Object}>] List of commits info:
      #   - +:components_bump_levels+ [Hash\\{String or nil => Integer}] Set of bump levels (0: patch, 1: minor, 2: major) per component name (nil for global)
      #   - +:commit+ [Git::Object::Commit] Corresponding git commit
      def process(commits_info)
        bump_level = commits_info.map { |commit_info| commit_info[:components_bump_levels].values }.flatten(1).max
        puts(
          case bump_level
          when nil
            # No commit. Return nothing to bump.
            ''
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
