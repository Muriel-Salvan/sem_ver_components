module SemVerComponents
  # Namespace for all git hosting plugins
  module GitHostings
    # Plugin providing URLs to a Bitbucket hosting
    class Bitbucket < GitHosting
      # Get the URL to a given commit sha
      #
      # @param git_url [String] The git URL
      # @param commit_sha [String] The commit sha
      # @return [String] The URL to the commit
      def commit_url(git_url, commit_sha)
        "#{public_url(git_url)}/commits/#{commit_sha}"
      end

      # Get the URL to compare 2 tags
      #
      # @param git_url [String] The git URL
      # @param tag_1 [String] The first tag
      # @param tag_2 [String] The second tag
      # @return [String] The URL to compare the 2 tags
      def compare_url(git_url, tag_1, tag_2)
        "#{public_url(git_url)}/compare/commits?targetBranch=refs%2Ftags%2F#{tag_1}&sourceBranch=refs%2Ftags%2F#{tag_2}"
      end

      private

      # Convert the git remote URL to the public URL
      #
      # @param git_url [String] Git remote URL
      # @return [String] The corresponding public URL
      def public_url(git_url)
        if git_url =~ %r{^(.+)/scm/([^/]+)/(.+)$}
          base_url = ::Regexp.last_match(1)
          project = ::Regexp.last_match(2)
          repo = ::Regexp.last_match(3)
          "#{base_url}/projects/#{project}/repos/#{repo}"
        else
          git_url
        end
      end
    end
  end
end
