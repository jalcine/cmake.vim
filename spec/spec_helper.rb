require 'rubygems'
require 'spork'
require 'json'
require 'faker'
require 'rspec'

I18n.enforce_available_locales = false

Spork.prefork do
  require 'vimrunner'
  require 'vimrunner/testing'
  require_relative 'lib/cmakevim'
  require_relative 'lib/vimrunner/extras'

  RSpec.configure do | config |
    config.include Vimrunner::Testing
    config.include Vimrunner::Extras
    config.include CMakeVim::Environment
    config.include CMakeVim::RSpec
  end
end

Spork.each_run do
  RSpec.configure do | config |
    config.around(:each) do
      spawn_vim_instance do
        # Give us a new directory to work in.
        dir = Dir.mktmpdir
        Dir.chdir(dir) do
          vim.command('cd ' + dir)
          begin
            example.run
          rescue Exception => e
          end
          cleanup_cmake
        end

        # Clean up our work and Vim.
        FileUtils.rm_r dir
      end
    end
  end
end
