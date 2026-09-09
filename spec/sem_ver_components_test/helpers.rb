require 'English'
require 'fileutils'
require 'git'
require 'tmpdir'

module SemVerComponentsTest
  module Helpers
    # Setup a temporary git repository containing given commits, and execute a block with it.
    # The repository is deleted after the block execution.
    #
    # @param commits [Array<Hash{Symbol => Object}>] List of commits to be created, in order:
    #   - +:comment+ [String] The commit message
    #   - +:files+ [Hash{String => String}] Files to be part of the commit, mapped by path (relative to the repository root)
    # @param default_branch [String, nil] Name of an extra branch to be created on the last commit, so that it can be used as a git ref
    # @yield Code to be executed with the created repository
    # @yieldparam git_repo [String] Path of the created git repository
    # @yieldreturn [Object] The block result
    def with_git_repo(commits:, default_branch: nil, &block)
      Dir.mktmpdir do |temp_dir|
        git_repo = File.join(temp_dir, 'git_repo')
        git = Git.init(git_repo)
        git.config_set('user.email', 'test@example.com')
        git.config_set('user.name', 'Test User')
        commits.each { |commit| create_git_commit(git, git_repo, commit) }
        # Create the extra branch on the last commit if it does not exist already (no checkout needed, the ref is enough)
        git.branch_new(default_branch) unless default_branch.nil? || git.branch_list.map(&:short_name).include?(default_branch)
        block.call(git_repo)
      end
    end

    # Setup a temporary git repository containing an initial commit followed by a single change commit, and execute a block with it.
    # This is a convenient wrapper on top of with_git_repo to test a single change on a fresh repository.
    # The repository is deleted after the block execution.
    #
    # @param comment [String] The commit message of the change, including any enclosing markers like in '[feat] Add a feature'
    # @param files [Hash{String => String}] Files to be part of the change commit, mapped by path (relative to the repository root)
    # @param default_branch [String, nil] Name of an extra branch to be created on the last commit, so that it can be used as a git ref
    # @yield Code to be executed with the created repository
    # @yieldparam git_repo [String] Path of the created git repository
    # @yieldreturn [Object] The block result
    def with_git_change(comment:, files: { 'change.txt' => 'A change' }, default_branch: nil, &block)
      with_git_repo(
        commits: [
          { comment: 'Initial commit', files: { 'README.md' => 'Test repository' } },
          { comment: comment, files: files }
        ],
        default_branch: default_branch,
        &block
      )
    end

    # Run a CLI of the gem with given arguments, and expect it to succeed
    #
    # @param args [String] Command-line arguments to be given to the CLI
    # @return [String] The CLI's standard output
    def run_cli(args)
      bin_sem_ver_git = File.expand_path('../../bin/sem_ver_git', __dir__)
      stdout = `bundle exec ruby "#{bin_sem_ver_git}" #{args}`
      expect($CHILD_STATUS.exitstatus).to eq(0)
      stdout
    end

    private

    # Create a commit in a git repository being setup
    #
    # @param git [Git::Repository] The git repository being setup
    # @param git_repo [String] Path of the git repository
    # @param commit [Hash{Symbol => Object}] The commit to be created:
    #   * +:comment+ (String): The commit message
    #   * +:files+ (Hash{String => String}): Files to be part of the commit, mapped by path (relative to the repository root)
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
