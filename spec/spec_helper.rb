require 'json'
require 'faker'
require 'vimrunner'
require 'vimrunner/testing'
require_relative 'lib/cmakevim'
require_relative 'lib/vimrunner/extras'

# Faker makes this happen since it uses i18n.
I18n.enforce_available_locales = false

RSpec.configure do | config |
  # Include some helpers from Vimrunner, we don't use stock.
  config.include Vimrunner::Testing
  config.include Vimrunner::Extras
  config.include CMakeVim::Environment
  config.include CMakeVim::RSpec

  config.around(:each) do | example |
    # Restart Vim.
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
