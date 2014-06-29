module Vimrunner
  module Extras
    # Public: Checks if the Vim server is aware of a specific Ex command.
    def command_exists?(command_string)
      vim.command('command').index(command_string).nil?
    end

    # Public: Checks if the Vim server is aware of a specific function.
    def function_exists?(function_string)
      function_string = 'function ' + function_string unless function_string.start_with? 'function '
      vim.command('function').index(function_string).nil?
    end

    # Public: Obtains all of the messages that were provided to Vim's message
    # history.
    def message_history
      vim.command('messages')
    end
  end
end
