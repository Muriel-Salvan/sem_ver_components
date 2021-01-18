module SemVerComponents

  # Base class for all output plugins
  class Output

    # Constructor
    #
    # Parameters::
    # * *local_git* (LocalGit): The git repository
    # * *git_hosting* (GitHosting): The git hosting to be used for URLs
    def initialize(local_git, git_hosting)
      @local_git = local_git
      @git_hosting = git_hosting
    end

  end

end
