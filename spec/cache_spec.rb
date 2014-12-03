require 'spec_helper'

describe 'cmake.vim#cache' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
  end

  describe '#read' do

    it 'reads a known variable from the CMake cache' do
      value = validate_response "echo cmake#cache#read('CMAKE_CXX_COMPILER')"
      expect(value).to_not match(/:E(\d+)/)
      expect(value).to match(/c++/)
    end

    it 'attempts to reads an non-existent variable from the CMake cache' do
      value = vim.command("echo cmake#cache#read('CMAKE_MAGIC_MAKEFILE')")
      expect(value).to_not match(/:E(\d+)/)
      expect(value).to be_empty
    end

    it 'reads a custom variable from the CMake cache' do
      variable_name  = Faker::Internet.user_name.upcase.gsub(/(\.|_)/, '')
      variable_value = Faker::Internet.user_name

      cmake.configure_project({
        definitions: {
          "#{variable_name}" => variable_value
        }
      })

      value = vim.command("echo cmake#cache#read('#{variable_name}')")
      expect(value).to_not be_empty
      expect(value).to_not match(/:E(\d+)/)
      expect(value).to eql(variable_value)
    end
  end

  describe '#write' do
    it 'writes a known variable to the CMake cache' do
      vim.command "echo cmake#cache#write('CMAKE_COLOR_MAKEFILE','ON')"
      result = vim.command("echo cmake#cache#read('CMAKE_COLOR_MAKEFILE')")
      expect(result).to_not be_empty
      expect(result).to_not match(/:E(\d+)/)
      expect(result).to eql('ON')
    end

    it 'writes a custom variable to the CMake cache' do
      vim.command "echo cmake#cache#write('CMAKE_COLOR_MAKEMOVE','Purple')"
      result = validate_response "echo cmake#cache#read('CMAKE_COLOR_MAKEMOVE')"
      expect(result).to eql('Purple')
    end
  end
end
