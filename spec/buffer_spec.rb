require 'spec_helper'

describe 'cmake#buffer' do
  before(:each) do
   cmake.create_new_project
   cmake.configure_project
  end

  describe '#set_options' do
    before(:each) { vim.edit 'plugin.cpp' }

    it 'adds binary directory for current file\'s target' do
      bindir = validate_response('echo b:cmake_binary_dir')
      expect(bindir).to_not be_empty
      expect(Dir.exists? bindir).to eql(true)
    end

    it 'adds source directory for current file\'s target' do
      srcdir = validate_response('echo b:cmake_source_dir')
      expect(srcdir).to_not be_empty
      expect(Dir.exists? srcdir).to eql(true)
    end

    it 'adds include directories for current file\'s target' do
      includedirs_json = validate_response('echo b:cmake_include_dirs')
      includedirs = JSON.parse(includedirs_json)
      expect(includedirs).to_not be_empty

      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end

    it 'adds libraries for current file\'s target' do
      libdirs_json = validate_response('echo b:cmake_libraries')
      libdirs = JSON.parse(libdirs_json)
      expect(libdirs).to_not be_empty
      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end
  end

  describe '#set_makeprg' do
    before(:each) do
      vim.edit 'plugin.cpp'
    end

    it 'sets the makeprg for this current buffer' do
      makeprg = validate_response('setlocal makeprg').gsub 'makeprg=', ''
      current_target = validate_response('let b:cmake_target')
       current_binary_dir = validate_response('let b:cmake_binary_dir')
      expect(makeprg).to eql("make -C #{current_binary_dir} #{current_target}")
    end
  end

  describe '#has_project' do
    let(:result) { validate_response 'echo cmake#buffer#has_project()' }

    context 'confirming the existence of a project within a buffer where the file' do
      it 'lies inside a CMake source tree' do
        vim.edit 'plugin.cpp'
        expect(result).to eql '1'
      end

      it 'lies outside in a CMake source file' do
        vim.edit Dir.home + '/.vimrc'
        expect(result).to eql '0'
      end
    end

    context 'ensures that the filetype of the file' do
      before(:each) { vim.edit 'plugin.cpp' }

      it 'matches for those of the "cpp" filetype' do
        vim.command 'set ft=cpp'
        expect(result).to eql('1')
      end

      it 'matches for those of the "c" filetype' do
        vim.command 'set ft=c'
        expect(result).to eql('1')
      end

      it 'does not matches for those of the "cmake" filetype' do
        vim.command 'set ft=cmake'
        expect(result).to eql('0')
      end
    end
  end
end
