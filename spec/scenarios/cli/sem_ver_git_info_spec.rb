require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'output plugin info' do
    # All commit comments with their expected bump level and expected next version (starting from an initial 0.0.0 version)
    # See lib/sem_ver_components/local_git.rb for the exhaustive list of commit types.
    comments_and_expected_versions = {
      '[break] Some change' => %w[major 1.0.0],
      '[breaking] Some change' => %w[major 1.0.0],
      '[major] Some change' => %w[major 1.0.0],
      '[feat] Some change' => %w[minor 0.1.0],
      '[feature] Some change' => %w[minor 0.1.0],
      '[minor] Some change' => %w[minor 0.1.0],
      '[fix] Some change' => %w[patch 0.0.1],
      '[patch] Some change' => %w[patch 0.0.1],
      '[chore] Some change' => %w[patch 0.0.1]
    }

    comments_and_expected_versions.each do |comment, (expected_bump, expected_next_version)|
      it "reports a new #{expected_bump} version when using #{comment}" do
        with_git_change(comment: comment) do |git_repo|
          # Analyze its commits using the info output plugin
          stdout = run_cli("--repo \"#{git_repo}\" --output info")

          expect(stdout).to include("Global: Bump #{expected_bump} version")
          # Next version is a pre-release one as we are not on a release branch, and its metadata is not deterministic
          expect(stdout).to match(/Next global version \(not on release branch\): #{Regexp.escape(expected_next_version)}-.+-SNAPSHOT\n\z/)
        end
      end

      # Release branches are the branches on which stable versions are released: master and main.
      release_branches = %w[master main]
      release_branches.each do |release_branch|
        it "reports a new stable #{expected_bump} version when using #{comment} on the #{release_branch} release branch" do
          with_git_change(comment: comment, default_branch: release_branch) do |git_repo|
            # Analyze its commits up to the release branch using the info output plugin
            stdout = run_cli("--repo \"#{git_repo}\" --to #{release_branch} --output info")

            expect(stdout).to include("Global: Bump #{expected_bump} version")
            # Next version is a stable one as we are on the release branch
            expect(stdout).to match(/Next global version: #{Regexp.escape(expected_next_version)}\n\z/)
          end
        end
      end
    end

    it 'reports a pre-release version when the git to ref is not a release branch' do
      with_git_change(comment: '[feat] Some change', default_branch: 'develop') do |git_repo|
        # Analyze its commits up to a non-release branch using the info output plugin
        stdout = run_cli("--repo \"#{git_repo}\" --to develop --output info")

        expect(stdout).to include('Global: Bump minor version')
        # Next version is a pre-release one as we are not on a release branch, and its metadata is not deterministic
        expect(stdout).to match(/Next global version \(not on release branch\): 0\.1\.0-.+-SNAPSHOT\n\z/)
      end
    end
  end
end
