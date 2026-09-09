require File.expand_path("#{__dir__}/lib/sem_ver_components/version")
require 'date'

Gem::Specification.new do |spec|
  spec.name = 'sem_ver_components'
  spec.version = SemVerComponents::VERSION
  spec.authors = ['Muriel Salvan']
  spec.email = ['muriel@x-aeon.com']
  spec.license = 'BSD-3-Clause'
  spec.summary = 'Apply semantic versioning to various components of a same package'
  spec.description = 'Tools helping in maintaining semantic versioning at a components level instead of a global package-only level.'
  spec.homepage = 'https://github.com/Muriel-Salvan/sem_ver_components'

  spec.files = Dir['{bin,lib}/**/*']
  Dir['bin/**/*'].each do |exec_name|
    spec.executables << File.basename(exec_name)
  end

  spec.required_ruby_version = '>= 3.1'
  spec.add_dependency 'git', '~> 5.4'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
