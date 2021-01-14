require File.expand_path("#{__dir__}/lib/sem_ver_components/version")
require 'date'

Gem::Specification.new do |spec|
  spec.name = 'sem_ver_components'
  spec.version = SemVerComponents::VERSION
  spec.date = Date.today.to_s
  spec.authors = ['Muriel Salvan']
  spec.email = ['muriel@x-aeon.com']
  spec.license = 'BSD-3-Clause'
  spec.summary = 'Apply semantic versioning to various components of a same package'
  spec.description = 'Tools helping in maintaining semantic versioning at a components level instead of a global package-only level.'
  spec.homepage = 'https://github.com/Muriel-Salvan/sem_ver_components'
  spec.license = 'BSD-3-Clause'

  spec.files = Dir['{bin,lib}/**/*']
  Dir['bin/**/*'].each do |exec_name|
    spec.executables << File.basename(exec_name)
  end

  spec.add_dependency 'git', '~> 1.8'

  # Development dependencies (tests, build)
  # Test framework
  spec.add_development_dependency 'rspec', '~> 3.10'
  # Automatic semantic releasing
  spec.add_development_dependency 'sem_ver_components', '~> 0.0'
end
