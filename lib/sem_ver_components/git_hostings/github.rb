module SemVerComponents
  module GitHostings
    # Plugin providing URLs to a GitHub hosting
    class Github < GitHosting
      # Get the URL to a given commit sha
      #
      # @param git_url [String] The git URL
      # @param commit_sha [String] The commit sha
      # @return [String] The URL to the commit
      def commit_url(git_url, commit_sha)
        "#{git_url}/commit/#{commit_sha}"
      end

      # Get the URL to compare 2 tags
      #
      # @param git_url [String] The git URL
      # @param tag_1 [String] The first tag
      # @param tag_2 [String] The second tag
      # @return [String] The URL to compare the 2 tags
      def compare_url(git_url, tag_1, tag_2)
        "#{git_url}/compare/#{tag_1}...#{tag_2}"
      end
    end
  end
end
