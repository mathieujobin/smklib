require File.expand_path('../lib/smklib/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'smklib'
  s.version = SMKLib::VERSION.to_s
  s.platform = Gem::Platform::RUBY

  s.authors = ['Mathieu Jobin']
  s.email = ['mathieu@justbudget.com']
  s.summary = "smklib is somekool's ruby library..."
  s.homepage = 'https://bitbucket.org/somekool/smklib'

  s.files = Dir['{app,lib,vendor}/**/*']
  #s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib', 'vendor']

  s.add_dependency 'railties'
end
