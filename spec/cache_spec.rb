require 'spec_helper'

describe 'cmake.vim#cache' do
  before(:each) do 
    cmake.create_new_project and cmake.configure_project
  end

  describe '#read' do
    it 'reads a known variable from the CMake cache' do
      value = vim.command('call cmake#cache#read(\'CMAKE_COLOR_MAKEFILE\')')
      expect(value).to eql('OFF')
    end

    it 'attempts to reads an non-existent variable from the CMake cache' do
      value = vim.command('call cmake#cache#read(\'CMAKE_MAGIC_MAKEFILE\')')
      expect(value).to eql('')
    end

    it 'reads a custom variable from the CMake cache' do
      # TODO Use faker to make this random each time it's run
      cmake.configure_project({
        definitions: {
          CMAKE_VIM_LOVER: :OF_COURSE
        }
      })

      value = vim.command('call cmake#cache#read(\'CMAKE_VIM_LOVER\')')
      expect(value).to eql('OF_COURSE')
    end
  end

  describe '#write' do
    it 'writes a known variable to the CMake cache' do
      vim.command('call cmake#cache#write(\"CMAKE_COLOR_MAKEFILE\",\"ON\")')
      result = vim.command('call cmake#cache#read(\"CMAKE_COLOR_MAKEFILE\")')
      expect(result).to_not be_empty
      expect(result).to eql('ON')
    end

    it 'writes a custom variable to the CMake cache' do
      vim.command('call cmake#cache#write(\"CMAKE_COLOR_RAINBOW\",\"Purple\")')
      result = vim.command('call cmake#cache#read(\"CMAKE_COLOR_RAINBOW\")')
      expect(result).to_not be_empty
      expect(result).to eql('Purple')
    end

  end

  describe '#file_path' do
    it 'gets the path of the CMake cache file' do
      path = vim.command('call cmake#cache#file_path()')
      expect(path).to_not be_empty
      expect(path).to eql(Dir.pwd + '/build/CMakeCache.txt')
    end
  end
end
