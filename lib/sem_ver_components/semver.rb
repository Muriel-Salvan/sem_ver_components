module SemVerComponents

  # Helpers giving ways to adapt to semantic versioning conventions
  module Semver

    # Compute next version from an existing one and a bump level
    #
    # Parameters::
    # * *version* (String): Existing version
    # * *bump_level* (Integer): The bump level (0: patch, 1: minor, 2: major)
    # * *pre_release* (Boolean): Should we get a pre-release version (adding a unique metadata)? [default: false]
    # Result::
    # * String: The next version
    def self.next_version_from(version, bump_level, pre_release: false)
      if version =~ /^(\d+)\.(\d+)\.(\d+)$/
        major = Integer($1)
        minor = Integer($2)
        patch = Integer($3)
        case bump_level
        when 0
          patch += 1
        when 1
          minor += 1
          patch = 0
        when 2
          major += 1
          minor = 0
          patch = 0
        else
          raise "Invalid bump level: #{bump_level}"
        end
        "#{major}.#{minor}.#{patch}#{pre_release ? "-#{pre_release_metadata}" : ''}"
      else
        raise "Invalid version: #{version}"
      end
    end

    # Get a version from a git ref
    #
    # Parameters::
    # * *git_ref* (String): The git ref
    # Result::
    # * String: Corresponding version
    def self.version_from_git_ref(git_ref)
      if git_ref.nil?
        '0.0.0'
      elsif git_ref =~ /^v(\d+\.\d+\.\d+)$/
        $1
      else
        raise "Can't assume version from git ref: #{git_ref}"
      end
    end

    private

    # Get a pre-release metadata to be appended to a version
    #
    # Result::
    # * String: The pre-release metadata
    def self.pre_release_metadata
      "#{`whoami`.strip}-#{Time.now.utc.strftime('%Y%m%d%H%M%S')}-SNAPSHOT"
    end

  end

end
