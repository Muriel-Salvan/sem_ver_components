require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'output plugin info' do
    it 'reports a new minor version when using [feat]' do
      with_git_change(comment: '[feat] Add a feature', files: { 'feature.txt' => 'A new feature' }) do |git_repo|
        # Analyze its commits using the info output plugin
        stdout = run_cli("--repo \"#{git_repo}\" --output info")

        expect(stdout).to include('Global: Bump minor version')
        # Next version is a pre-release one as we are not on a release branch, and its metadata is not deterministic
        expect(stdout).to match(/Next global version \(not on release branch\): 0\.1\.0-.+-SNAPSHOT\n\z/)
      end
    end

    # All commit comments with their expected bump level and expected next version (starting from an initial 0.0.0 version)
    # See lib/sem_ver_components/local_git.rb for the exhaustive list of commit types.
    {
      '[break] Some change' => %w[major 1.0.0],
      '[breaking] Some change' => %w[major 1.0.0],
      '[major] Some change' => %w[major 1.0.0],
      '[feature] Some change' => %w[minor 0.1.0],
      '[minor] Some change' => %w[minor 0.1.0],
      '[fix] Some change' => %w[patch 0.0.1],
      '[patch] Some change' => %w[patch 0.0.1],
      '[chore] Some change' => %w[patch 0.0.1]
    }.each do |comment, (expected_bump, expected_next_version)|
      it "reports a new #{expected_bump} version when using #{comment}" do
        with_git_change(comment: comment) do |git_repo|
          # Analyze its commits using the info output plugin
          stdout = run_cli("--repo \"#{git_repo}\" --output info")

          expect(stdout).to include("Global: Bump #{expected_bump} version")
          # Next version is a pre-release one as we are not on a release branch, and its metadata is not deterministic
          expect(stdout).to match(/Next global version \(not on release branch\): #{Regexp.escape(expected_next_version)}-.+-SNAPSHOT\n\z/)
        end
      end
    end
  end
end
