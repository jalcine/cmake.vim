module CMakeVim
  module RSpec
    def validate_response(command)
      result = vim.command(command)
      expect(result).to_not be_empty
      expect(result).to_not match(/:E(\d+)/)
      result
    end
  end
end
