require 'rubygems'
require 'spork'
require 'faker'
require 'rspec'
require 'timeout'
require 'awesome_print'
require 'pry'
require 'fileutils'

I18n.enforce_available_locales = false

plugin_directory = File.expand_path('../../', __FILE__)

Spork.prefork do
  require 'vimrunner'
  require 'vimrunner/testing'
  require 'vimrunner/rspec'
  require_relative 'lib/cmakevim'
  require_relative 'lib/vimrunner/extras'

  RSpec.configure do | config |
    config.include Vimrunner::Testing
    config.include Vimrunner::Extras
    config.include CMakeVim::Environment
    config.include CMakeVim::RSpec
  end

  Vimrunner::RSpec.configure do | config |
    config.reuse_server = false

    config.start_vim do
      vim = Vimrunner.start
      msg = vim.add_plugin(plugin_directory, 'plugin/cmake.vim')
      puts "Error loading plugin: #{msg}" unless msg.empty?
      vim
    end
  end
end

Spork.each_run do
  RSpec.configure do | config |
    config.around do | example |
      # Give us a new directory to work in.
      dir = Dir.mktmpdir
      Dir.chdir(dir) do
        @dir = dir
        vim.command('cd ' + dir)
        example.instance_variable_set :@dir, dir

        begin
          example.run
        rescue Exception => e
          puts "[cmake.vim] Error running test: #{e}"
        end

        example.instance_variable_set :@dir, nil
        cleanup_cmake
      end

      # Clean up our work and Vim.
      FileUtils.rm_r dir
    end
  end
end
