module Vimrunner
  module Extras
    # Public: Checks if the Vim server is aware of a specific Ex command.
    def command_exists?(command_string)
      vim.command('command').match command_string
    end

    # Public: Checks if the Vim server is aware of a specific function.
    def function_exists?(function_string)
      vim.command('function').match function_string
    end

    # Public: Obtains all of the messages that were provided to Vim's message
    # history.
    def message_history
      vim.command('messages')
    end
  end
end
