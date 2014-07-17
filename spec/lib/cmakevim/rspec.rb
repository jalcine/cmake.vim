require 'json'

module CMakeVim
  module RSpec
    # Public: Santitizes output of Vim command.
    def validate_response(command)
      result = vim.command(command)
      expect(result).to_not be_empty
      expect(result).to_not match(/:E(\d+)/)
      result
    end

    def validate_json_response(command)
      result = validate_response command
      result.gsub! '\'', '"'
      JSON.parse result
    end
  end
end
