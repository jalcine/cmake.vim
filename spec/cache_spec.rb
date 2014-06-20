require 'spec_helper'

describe 'cmake.vim#cache' do
  let(:cmakevim) { CMakeVim.new(vim: vim) }

  before(:each) { cmakevim.create_new_project and cmakevim.configure_project }
  after(:each)  { cmakevim.destroy_project }

  describe '#read' do
    it 'reads a known variable from the CMake cache' do
      value = vim.command('call cmake#cache#read(\'CMAKE_COLOR_MAKEFILE\')')
      expect(value).to eql('OFF')
    end

    it 'reads an unknown variable from the CMake cache' do
      value = vim.command('call cmake#cache#read(\'CMAKE_MAGIC_MAKEFILE\')')
      expect(value).to eql('')
    end

    xit 'reads a custom variable from the CMake cache' do
      # TODO Add this as part of the configuration process.
      value = vim.command('call cmake#cache#read(\'CMAKE_VIM_LOVER\')')
      expect(value).to eql('OF_COURSE')
    end
  end

  describe '#write' do
    xit 'writes a variable to the CMake cache'
  end
  describe '#file_path' do
    xit 'gets the path of the CMake cache file'
  end
end
