# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#buffer' do
  describe '#set_options' do
    before(:all) do
      vim.edit 'plugin.cpp'
      vim.command 'call cmake#buffer#set_options()'
    end

    it 'adds binary directory for current file\'s target' do
      bindir = vim.command('let b:cmake_binary_dir')
      expect(bindir).to_not be_empty
      expect(Dir.exists? bindir).to eql(true)
    end

    it 'adds source directory for current file\'s target' do
      srcdir = vim.command('let b:cmake_source_dir')
      expect(srcdir).to_not be_empty
      expect(Dir.exists? srcdir).to eql(true)
    end

    it 'adds include directories for current file\'s target' do
      includedirs_json = vim.command('let b:cmake_include_dirs')
      includedirs = JSON.parse(includedirs_json)
      expect(includedirs).to_not be_empty

      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end

    it 'adds libraries for current file\'s target' do
      libdirs_json = vim.command('let b:cmake_libraries')
      libdirs = JSON.parse(libdirs_json)
      expect(libdirs).to_not be_empty
      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end
  end

  describe '#set_makeprg' do
    before(:all) do
      vim.edit 'plugin.cpp'
      vim.command 'call cmake#buffer#set_makeprg()'
    end

    it 'sets the makeprg for this current buffer' do
      makeprg = vim.command('let &l:makeprg')
      current_target = vim.command('let b:cmake_target')
      current_binary_dir = vim.command('let b:cmake_binary_dir')
      expect(makeprg).to match(/^make/)
      expect(makeprg).to match(current_target)
      expect(makeprg).to match("-c #{current_binary_dir}")
      expect(makeprg).to eql("make -C #{current_binary_dir} #{current_target}")
    end
  end

  describe '#has_project' do
    it 'confirms the existence of a project within a buffer where PWD ~= CMake' do
      vim.edit 'plugin.cpp'
      expect(vim.command('call cmake#buffer#has_project()')).to eql('1')
    end

    it 'denies the idea of a CMake project within a buffer where PWD != CMake' do
      vim.edit(Dir.home + "/.vimrc")
      expect(vim.command('call cmake#buffer#has_project()')).to eql('0')
    end
  end
end
