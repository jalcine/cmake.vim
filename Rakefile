require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do | t |
  t.pattern = 'spec/*spec.rb'
end

task :default => :spec

desc 'Changes the version used in files so far.'
task :bump_version do
    files = Dir.glob 'autoload/cmake/**.vim'
    files += [ 'plugin/cmake.vim', 'README.markdown', 'doc/cmake.txt', 'CONTRIBUTING.markdown']

    files.each do | file |
        old_version = ENV['OLD_VERSION']
        new_version = ENV['NEW_VERSION']

        # TODO: Read in the data for the file.
        # TODO: Replace every occurance of OLD_VERSION with NEW_VERSION.
        # TODO: Write that information back to disk.
    end
end

