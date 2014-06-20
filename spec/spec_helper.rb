require 'vimrunner'
require 'vimrunner/testing'
require_relative 'lib/cmakevim'
require_relative 'lib/cmakevim/environment'

RSpec.configure do | config |
  # Include some helpers from Vimrunner
  config.include Vimrunner::Testing
  config.include CMakeVim::Environment

  config.around(:each) do | example |
    Dir.mktmpdir do | dir |
      Dir.chdir(dir) do
        vim.command('cd ' + dir)
      end
    end
  end

  config.after(:each) do | example |
    kill_vim_session
    cleanup_cmake
  end
end
