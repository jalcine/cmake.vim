require 'vimrunner'
require 'vimrunner/rspec'

Vimrunner::RSpec.configure do | config |
  config.reuse_server = true
  plugin_path = File.expand_path('..')

  config.start_vim do
    vim = Vimrunner.start
    vim.add_plugin(plugin_path, 'plugin/cmake.vim')
    vim
  end
end

# TODO Test against GUI vim as well.
