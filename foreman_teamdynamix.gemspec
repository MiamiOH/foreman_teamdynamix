require File.expand_path('lib/foreman_teamdynamix/version', __dir__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_teamdynamix'
  s.version     = ForemanTeamdynamix::VERSION
  s.date        = Date.today.to_s # rubocop:disable Rails/Date
  s.license     = 'GPL-3.0'
  s.authors     = ['Nipendar Tyagi']
  s.email       = ['nippu.tyagi@gmail.com']
  s.homepage    = 'https://github.com/MiamiOH/foreman_teamdynamix'
  s.summary     = 'Creates TeamDynamix Asset when a host is created in Foreman'
  # also update locale/gemspec.rb
  s.description = 'A Foreman Plugin to create a configurable TeamDynamix Asset when a host is created in Foreman'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'deface', '< 2.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'webmock'
end
