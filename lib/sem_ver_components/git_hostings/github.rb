module SemVerComponents

  module GitHostings

    class Github < GitHosting

      # Get the URL to a given commit sha
      #
      # Parameters::
      # * *git_url* (String): The git URL
      # * *commit_sha* (String): The commit sha
      def commit_url(git_url, commit_sha)
        "#{git_url}/commit/#{commit_sha}"
      end

      # Get the URL to compare 2 tags
      #
      # Parameters::
      # * *git_url* (String): The git URL
      # * *tag_1* (String): The first tag
      # * *tag_2* (String): The second tag
      def compare_url(git_url, tag_1, tag_2)
        "#{git_url}/compare/#{tag_1}...#{tag_2}"
      end

    end

  end

end
