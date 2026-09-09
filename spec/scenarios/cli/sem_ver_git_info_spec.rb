require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'output plugin info' do
    it 'reports a new minor version when using [feat]' do
      with_git_repo(
        commits: [
          {
            comment: 'Initial commit',
            files: { 'README.md' => 'Test repository' }
          },
          {
            comment: '[feat] Add a feature',
            files: { 'feature.txt' => 'A new feature' }
          }
        ]
      ) do |git_repo|
        # Analyze its commits using the info output plugin
        stdout = run_cli("--repo \"#{git_repo}\" --output info")

        expect(stdout).to include('Global: Bump minor version')
        # Next version is a pre-release one as we are not on a release branch, and its metadata is not deterministic
        expect(stdout).to match(/Next global version \(not on release branch\): 0\.1\.0-.+-SNAPSHOT\n\z/)
      end
    end
  end
end
