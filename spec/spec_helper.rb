require 'vimrunner'
require 'vimrunner/rspec'
require_relative 'lib/cmakevim'

# We'll need to know where we're working from.
plugin_path = File.expand_path('../..', __FILE__)

Vimrunner::RSpec.configure do | config |
  config.reuse_server = true

  config.start_vim do
    # Start Vim headless.
    vim = Vimrunner.start

    # Run the primary plugin file.
    vim.add_plugin(plugin_path, 'cmake.vim')

    # Give 'em Vim.
    vim
  end
end

# TODO Test against GUI vim as well.
