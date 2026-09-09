require 'English'

RSpec.describe 'sem_ver_git CLI' do
  describe 'options' do
    it 'displays its version when using --version' do
      stdout = run_cli('--version')

      expect(stdout).to eq("sem_ver_git v#{SemVerComponents::VERSION}\n")
    end

    it 'displays its version when using -v' do
      stdout = run_cli('-v')

      expect(stdout).to eq("sem_ver_git v#{SemVerComponents::VERSION}\n")
    end

    it 'displays its help when using --help' do
      stdout = run_cli('--help')

      expect(stdout).to include('Usage: sem_ver_git [options]')
      expect(stdout).to include('-f, --from GIT_REF')
      expect(stdout).to include('-g, --git_hosting GIT_HOSTING')
      expect(stdout).to include('-h, --help')
      expect(stdout).to include('-o, --output OUTPUT')
      expect(stdout).to include('-r, --repo GIT_URL')
      expect(stdout).to include('-t, --to GIT_REF')
      expect(stdout).to include('-v, --version')
    end

    it 'displays its help when using -h' do
      stdout = run_cli('-h')

      expect(stdout).to include('Usage: sem_ver_git [options]')
    end

    it 'analyzes commits from a given reference when using --from' do
      with_git_change(comment: '[feat] Some change') do |git_repo|
        # Tag the initial commit with a version, and analyze the commits following it using the info output plugin
        git = Git.open(git_repo)
        git.tag_create('v1.2.3', git.log.execute.last.sha)
        stdout = run_cli("--repo \"#{git_repo}\" --from v1.2.3 --output info")

        expect(stdout).to include('Global: Bump minor version')
        # Next version is a pre-release one as we are not on a release branch, and its metadata is not deterministic
        expect(stdout).to match(/Next global version \(not on release branch\): 1\.3\.0-.+-SNAPSHOT\n\z/)
      end
    end

    it 'analyzes commits from the first one when using --from with an empty reference' do
      with_git_change(comment: '[feat] Some change') do |git_repo|
        stdout = run_cli("--repo \"#{git_repo}\" --from '' --output info")

        expect(stdout).to include('Global: Bump minor version')
        expect(stdout).to match(/Next global version \(not on release branch\): 0\.1\.0-.+-SNAPSHOT\n\z/)
      end
    end

    it 'uses the specified git hosting when using --git_hosting' do
      with_git_change(comment: '[feat] Some change') do |git_repo|
        stdout = run_cli("--repo \"#{git_repo}\" --git_hosting github --output info")

        expect(stdout).to include('Global: Bump minor version')
        expect(stdout).to match(/Next global version \(not on release branch\): 0\.1\.0-.+-SNAPSHOT\n\z/)
      end
    end
  end
end
