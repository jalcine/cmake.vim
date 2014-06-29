require 'spec_helper'

describe 'cmake.vim#cache' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
    vim.edit 'binary_main.cpp'
  end

  describe '#read' do

    it 'reads a known variable from the CMake cache' do
      value = vim.command("echo cmake#cache#read('CMAKE_COLOR_MAKEFILE')")
      message_history
      expect(value).to_not be_empty
      expect(value).to_not match(/:E(\d+)/)
      expect(value).to match(/(OFF|ON)/)
    end

    it 'attempts to reads an non-existent variable from the CMake cache' do
      value = vim.command("echo cmake#cache#read('CMAKE_MAGIC_MAKEFILE')")
      message_history
      expect(value).to_not match(/:E(\d+)/)
      expect(value).to eql("0")
    end

    it 'reads a custom variable from the CMake cache' do
      variable_name  = Faker::Internet.user_name.upcase.gsub(/(\.|_)/, '')
      variable_value = Faker::Internet.user_name

      cmake.configure_project({
        definitions: {
          "#{variable_name}" => variable_value
        }
      })

      value = vim.command("echo cmake#cache#read('" + variable_name + "')")
      expect(value).to_not eql("0")
      expect(value).to_not match(/:E(\d+)/)
      expect(value).to eql(variable_value)
    end
  end

  describe '#write' do
    it 'writes a known variable to the CMake cache' do
      vim.command("echo cmake#cache#write('CMAKE_COLOR_MAKEFILE','ON')")
      result = vim.command("echo cmake#cache#read('CMAKE_COLOR_MAKEFILE')")
      expect(result).to_not be_empty
      expect(result).to_not match(/:E(\d+)/)
      expect(result).to eql('ON')
    end

    xit 'writes a custom variable to the CMake cache' do
      vim.command("echo cmake#cache#write('CMAKE_COLOR_MAKEMOVE','Purple')")
      result = vim.command("echo cmake#cache#read('CMAKE_COLOR_MAKEMOVE')")
      expect(result).to_not be_empty
      expect(result).to_not match(/:E(\d+)/)
      expect(result).to eql('Purple')
    end
  end

  describe '#file_path' do
    let(:path) { vim.command('echo cmake#cache#file_path()') }
    let(:potential_path) { File.expand_path(vim.command('pwd') + '/build/CMakeCache.txt') }

    it 'gets the path of the CMake cache file' do
      expect(path).to_not be_empty
      expect(path).to_not match(/:E(\d+)/)
      expect(path).to eql(potential_path)
    end
  end
end
