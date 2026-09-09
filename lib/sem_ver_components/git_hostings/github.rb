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
      # @param tag1 [String] The first tag
      # @param tag2 [String] The second tag
      # @return [String] The URL to compare the 2 tags
      def compare_url(git_url, tag1, tag2)
        "#{git_url}/compare/#{tag1}...#{tag2}"
      end
    end
  end
end
