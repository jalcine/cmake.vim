module CMakeVim
  module RSpec
    # Public: Santitizes output of Vim command.
    def validate_response(command)
      result = vim.command(command)
      expect(result).to_not be_empty
      expect(result).to_not match(/:E(\d+)/)
      result
    end
  end
end
