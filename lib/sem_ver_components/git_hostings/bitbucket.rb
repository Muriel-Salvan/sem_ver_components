module SemVerComponents

  module GitHostings

    class Bitbucket < GitHosting

      # Get the URL to a given commit sha
      #
      # Parameters::
      # * *git_url* (String): The git URL
      # * *commit_sha* (String): The commit sha
      def commit_url(git_url, commit_sha)
        "#{git_url}/commits/#{commit_sha}"
      end

      # Get the URL to compare 2 tags
      #
      # Parameters::
      # * *git_url* (String): The git URL
      # * *tag_1* (String): The first tag
      # * *tag_2* (String): The second tag
      def compare_url(git_url, tag_1, tag_2)
        "#{git_url}/compare/commits?targetBranch=refs%2Ftags%2F#{tag_2}&sourceBranch=refs%2Ftags%2F#{tag_1}"
      end

    end

  end

end
