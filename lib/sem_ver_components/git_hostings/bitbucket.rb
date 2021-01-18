module SemVerComponents

  module GitHostings

    class Bitbucket < GitHosting

      # Get the URL to a given commit sha
      #
      # Parameters::
      # * *git_url* (String): The git URL
      # * *commit_sha* (String): The commit sha
      def commit_url(git_url, commit_sha)
        "#{public_url(git_url)}/commits/#{commit_sha}"
      end

      # Get the URL to compare 2 tags
      #
      # Parameters::
      # * *git_url* (String): The git URL
      # * *tag_1* (String): The first tag
      # * *tag_2* (String): The second tag
      def compare_url(git_url, tag_1, tag_2)
        "#{public_url(git_url)}/compare/commits?targetBranch=refs%2Ftags%2F#{tag_1}&sourceBranch=refs%2Ftags%2F#{tag_2}"
      end

      private

      # Convert the git remote URL to the public URL
      #
      # Parameters::
      # * *git_url* (String): Git remote URL
      # Result::
      # * String: The corresponding public URL
      def public_url(git_url)
        if git_url =~ /^(.+)\/scm\/([^\/]+)\/(.+)$/
          base_url = $1
          project = $2
          repo = $3
          "#{base_url}/projects/#{project}/repos/#{repo}"
        else
          git_url
        end
      end

    end

  end

end
