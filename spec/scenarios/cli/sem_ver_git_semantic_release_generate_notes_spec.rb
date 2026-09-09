require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'output plugin semantic_release_generate_notes' do
    # All commit comments with their expected bump level, expected next version (starting from an initial 0.0.0 version)
    # and expected changelog section name.
    # Commit comments can either use enclosing markers like in '[feat] Some change' or '[feat(customers)] Some change',
    # or conventional commit style tags at the beginning of the message like in 'feat: Some change' or 'feat(customers): Some change'.
    # See lib/sem_ver_components/local_git.rb for the exhaustive list of commit types,
    # and lib/sem_ver_components/outputs/semantic_release_generate_notes.rb for the exhaustive list of changelog sections.
    comments_and_expected_versions = {
      '[break] Some change' => ['major', '1.0.0', 'Breaking changes'],
      '[break(customers)] Some change' => ['major', '1.0.0', 'Breaking changes'],
      'break: Some change' => ['major', '1.0.0', 'Breaking changes'],
      'break(customers): Some change' => ['major', '1.0.0', 'Breaking changes'],
      '[breaking] Some change' => ['major', '1.0.0', 'Breaking changes'],
      '[breaking(customers)] Some change' => ['major', '1.0.0', 'Breaking changes'],
      'breaking: Some change' => ['major', '1.0.0', 'Breaking changes'],
      'breaking(customers): Some change' => ['major', '1.0.0', 'Breaking changes'],
      '[major] Some change' => ['major', '1.0.0', 'Breaking changes'],
      '[major(customers)] Some change' => ['major', '1.0.0', 'Breaking changes'],
      'major: Some change' => ['major', '1.0.0', 'Breaking changes'],
      'major(customers): Some change' => ['major', '1.0.0', 'Breaking changes'],
      '[feat] Some change' => ['minor', '0.1.0', 'Features'],
      '[feat(customers)] Some change' => ['minor', '0.1.0', 'Features'],
      'feat: Some change' => ['minor', '0.1.0', 'Features'],
      'feat(customers): Some change' => ['minor', '0.1.0', 'Features'],
      '[feature] Some change' => ['minor', '0.1.0', 'Features'],
      '[feature(customers)] Some change' => ['minor', '0.1.0', 'Features'],
      'feature: Some change' => ['minor', '0.1.0', 'Features'],
      'feature(customers): Some change' => ['minor', '0.1.0', 'Features'],
      '[minor] Some change' => ['minor', '0.1.0', 'Features'],
      '[minor(customers)] Some change' => ['minor', '0.1.0', 'Features'],
      'minor: Some change' => ['minor', '0.1.0', 'Features'],
      'minor(customers): Some change' => ['minor', '0.1.0', 'Features'],
      '[fix] Some change' => ['patch', '0.0.1', 'Patches'],
      '[fix(customers)] Some change' => ['patch', '0.0.1', 'Patches'],
      'fix: Some change' => ['patch', '0.0.1', 'Patches'],
      'fix(customers): Some change' => ['patch', '0.0.1', 'Patches'],
      '[patch] Some change' => ['patch', '0.0.1', 'Patches'],
      '[patch(customers)] Some change' => ['patch', '0.0.1', 'Patches'],
      'patch: Some change' => ['patch', '0.0.1', 'Patches'],
      'patch(customers): Some change' => ['patch', '0.0.1', 'Patches'],
      '[chore] Some change' => ['patch', '0.0.1', 'Patches'],
      '[chore(customers)] Some change' => ['patch', '0.0.1', 'Patches'],
      'chore: Some change' => ['patch', '0.0.1', 'Patches'],
      'chore(customers): Some change' => ['patch', '0.0.1', 'Patches']
    }

    comments_and_expected_versions.each do |comment, (expected_bump, expected_next_version, expected_changelog_section)|
      it "generates release notes for a new #{expected_bump} version when using #{comment}" do
        with_git_change(comment: comment) do |git_repo|
          # This output plugin generates URLs to the git hosting, so give the git repository an origin remote
          Git.open(git_repo).remote_add('origin', 'https://github.com/test/test_repo.git')
          # Generate release notes using the semantic_release_generate_notes output plugin
          stdout = run_cli("--repo \"#{git_repo}\" --output semantic_release_generate_notes")

          # This output plugin always reports a stable next version, whether on a release branch or not,
          # so no specific test case is needed for the release branch.
          # The release date and time are not deterministic, hence the regular expression
          expected_release_notes_header = %r{
            ^\#\ \[v#{Regexp.escape(expected_next_version)}\]
            \(https://github\.com/test/test_repo/compare/\.\.\.v#{Regexp.escape(expected_next_version)}\)
            \ \(\d{4}-\d{2}-\d{2}\ \d{2}:\d{2}:\d{2}\)$
          }x
          expect(stdout).to match(expected_release_notes_header)
          expect(stdout).to include("### #{expected_changelog_section}")
          # Scoped comments also bump the component they reference, which gets its own section in the release notes
          scoped_component = comment[/\(([^)]+)\)/, 1]
          expect(stdout).to include("## Changes for #{scoped_component}") unless scoped_component.nil?
          # Commit's SHA is not deterministic, hence the regular expression
          expect(stdout).to match(%r{^\* \[#{Regexp.escape(comment)}\]\(https://github\.com/test/test_repo/commit/[0-9a-f]{40}\)$})
        end
      end
    end
  end
end
