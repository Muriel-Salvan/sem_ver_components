require 'git'

module SemVerComponents

  class LocalGit

    attr_reader *%i[git_from git_to git]

    # Constructor
    #
    # Parameters::
    # * *git_repo* (String): The git repository to analyze
    # * *git_from* (String or nil): The git from ref
    # * *git_to* (String): The git to ref
    def initialize(git_repo, git_from, git_to)
      @git_repo = git_repo
      @git_from = git_from
      @git_to = git_to
      @git = Git.open(@git_repo)
    end

    # Get full the git log.
    # Keep a cache of it.
    #
    # Result::
    # * Array< Git::Object::Commit >: Full git log
    def git_log
      @git_log = @git.log(nil) unless defined?(@git_log)
      @git_log
    end

    # Semantically analyze commits.
    #
    # Result::
    # * Array< Hash<Symbol, Object> >: The commits information:
    #   * *components_bump_levels* (Hash<String or nil, Integer>): Set of bump levels (0: patch, 1: minor, 2: major) per component name (nil for global)
    #   * *commit* (Git::Object::Commit): Corresponding git commit
    def analyze_commits
      git_log.between(git_from.nil? ? git_log.last.sha : git_from, git_to).map do |git_commit|
        # Analyze the message
        # Always consider a minimum of global patch bump per commit.
        components_bump_levels = { nil => [0] }
        git_commit.message.scan(/\[([^\]]+)\]/).flatten(1).each do |commit_label|
          commit_type, component = commit_label =~ /^(.+)\((.+)\)$/ ? [$1, $2] : [commit_label, nil]
          components_bump_levels[component] = [] unless components_bump_levels.key?(component)
          components_bump_levels[component] <<
            case commit_type.downcase
            when 'feat', 'feature'
              1
            when 'break', 'breaking'
              2
            else
              0
            end
        end
        {
          commit: git_commit,
          components_bump_levels: Hash[components_bump_levels.map { |component, component_bump_levels| [component, component_bump_levels.max] }]
        }
      end
    end

  end

end
