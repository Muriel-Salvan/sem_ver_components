require 'English'
require 'fileutils'
require 'git'
require 'tmpdir'

module SemVerComponentsTest
  module Helpers
    # Setup a temporary git repository containing given commits, and execute a block with it.
    # The repository is deleted after the block execution.
    #
    # Parameters::
    # * *commits* (Array< Hash<Symbol, Object> >): List of commits to be created, in order:
    #   * *comment* (String): The commit message
    #   * *files* (Hash<String, String>): Files to be part of the commit, mapped by path (relative to the repository root)
    # * *block* (Proc): Code to be executed with the created repository:
    #   * *git_repo* (String): Path of the created git repository
    def with_git_repo(commits:, &block)
      Dir.mktmpdir do |temp_dir|
        git_repo = File.join(temp_dir, 'git_repo')
        git = Git.init(git_repo)
        git.config('user.email', 'test@example.com')
        git.config('user.name', 'Test User')
        commits.each { |commit| create_git_commit(git, git_repo, commit) }
        block.call(git_repo)
      end
    end

    # Run a CLI of the gem with given arguments, and expect it to succeed
    #
    # Parameters::
    # * *args* (String): Command-line arguments to be given to the CLI
    # Result::
    # * String: The CLI's standard output
    def run_cli(args)
      bin_sem_ver_git = File.expand_path('../../bin/sem_ver_git', __dir__)
      stdout = `bundle exec ruby "#{bin_sem_ver_git}" #{args}`
      expect($CHILD_STATUS.exitstatus).to eq(0)
      stdout
    end

    private

    # Create a commit in a git repository being setup
    #
    # Parameters::
    # * *git* (Git::Repository): The git repository being setup
    # * *git_repo* (String): Path of the git repository
    # * *commit* (Hash<Symbol, Object>): The commit to be created:
    #   * *comment* (String): The commit message
    #   * *files* (Hash<String, String>): Files to be part of the commit, mapped by path (relative to the repository root)
    def create_git_commit(git, git_repo, commit)
      commit[:files].each do |file, content|
        file_path = File.join(git_repo, file)
        FileUtils.mkdir_p(File.dirname(file_path))
        File.write(file_path, content)
      end
      git.add
      git.commit(commit[:comment])
    end
  end
end
