require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'output plugin semantic_release_generate_notes' do
    # Changelog section name per bump level
    # See lib/sem_ver_components/outputs/semantic_release_generate_notes.rb for the exhaustive list of changelog sections.
    changelog_section_per_bump = {
      'major' => 'Breaking changes',
      'minor' => 'Features',
      'patch' => 'Patches'
    }

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
      it "generates release notes for a new #{expected_bump} version when using #{comment}" do
        with_git_change(comment: comment) do |git_repo|
          # This output plugin generates URLs to the git hosting, so give the git repository an origin remote
          Git.open(git_repo).remote_add('origin', 'https://github.com/test/test_repo.git')
          # Generate release notes using the semantic_release_generate_notes output plugin
          stdout = run_cli("--repo \"#{git_repo}\" --output semantic_release_generate_notes")

          # This output plugin always reports a stable next version, whether on a release branch or not,
          # so no specific test case is needed for the release branch.
          expect(stdout).to match(%r{^# \[v#{Regexp.escape(expected_next_version)}\]\(https://github\.com/test/test_repo/compare/\.\.\.v#{Regexp.escape(expected_next_version)}\) \(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\)$})
          expect(stdout).to include("### #{changelog_section_per_bump[expected_bump]}")
          # Commit's SHA is not deterministic, hence the regular expression
          expect(stdout).to match(%r{^\* \[#{Regexp.escape(comment)}\]\(https://github\.com/test/test_repo/commit/[0-9a-f]{40}\)$})
        end
      end
    end
  end
end
