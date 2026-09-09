require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'output plugin semantic_release_analyze' do
    # All commit comments with their expected bump level
    # Commit comments can either use enclosing markers like in '[feat] Some change' or '[feat(customers)] Some change',
    # or conventional commit style tags at the beginning of the message like in 'feat: Some change' or 'feat(customers): Some change'.
    # See lib/sem_ver_components/local_git.rb for the exhaustive list of commit types.
    comments_and_expected_bumps = {
      '[break] Some change' => 'major',
      '[break(customers)] Some change' => 'major',
      'break: Some change' => 'major',
      'break(customers): Some change' => 'major',
      '[breaking] Some change' => 'major',
      '[breaking(customers)] Some change' => 'major',
      'breaking: Some change' => 'major',
      'breaking(customers): Some change' => 'major',
      '[major] Some change' => 'major',
      '[major(customers)] Some change' => 'major',
      'major: Some change' => 'major',
      'major(customers): Some change' => 'major',
      '[feat] Some change' => 'minor',
      '[feat(customers)] Some change' => 'minor',
      'feat: Some change' => 'minor',
      'feat(customers): Some change' => 'minor',
      '[feature] Some change' => 'minor',
      '[feature(customers)] Some change' => 'minor',
      'feature: Some change' => 'minor',
      'feature(customers): Some change' => 'minor',
      '[minor] Some change' => 'minor',
      '[minor(customers)] Some change' => 'minor',
      'minor: Some change' => 'minor',
      'minor(customers): Some change' => 'minor',
      '[fix] Some change' => 'patch',
      '[fix(customers)] Some change' => 'patch',
      'fix: Some change' => 'patch',
      'fix(customers): Some change' => 'patch',
      '[patch] Some change' => 'patch',
      '[patch(customers)] Some change' => 'patch',
      'patch: Some change' => 'patch',
      'patch(customers): Some change' => 'patch',
      '[chore] Some change' => 'patch',
      '[chore(customers)] Some change' => 'patch',
      'chore: Some change' => 'patch',
      'chore(customers): Some change' => 'patch'
    }

    comments_and_expected_bumps.each do |comment, expected_bump|
      it "reports a #{expected_bump} version bump when using #{comment}" do
        with_git_change(comment: comment) do |git_repo|
          # Analyze its commits using the semantic_release_analyze output plugin
          stdout = run_cli("--repo \"#{git_repo}\" --output semantic_release_analyze")

          # This output plugin only reports the bump level to be applied, independently of being on a release branch or not,
          # so no specific test case is needed for the release branch.
          expect(stdout).to eq("#{expected_bump}\n")
        end
      end
    end
  end
end
