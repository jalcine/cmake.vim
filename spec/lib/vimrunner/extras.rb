module Vimrunner
  module Extras
    # Public: Checks if the Vim server is aware of a specific Ex command.
    def command_exists?(command_string)
      validate_response('command').include? command_string
    end

    # Public: Checks if the Vim server is aware of a specific function.
    def function_exists?(function_string)
      function_string = 'function ' + function_string unless function_string.start_with? 'function '
      validate_response('function').include? function_string
    end

    # Public: Obtains all of the messages that were provided to Vim's message
    # history.
    def message_history
      vim.command('messages')
    end

    # TODO Add logic to install & load in syntastic.
    # TODO Add logic to install & load in vim-dispatch.
    # TODO Add logic to install & load in vimproc.vim.
    # TODO Add logic to install & load in unite.
  end
end
