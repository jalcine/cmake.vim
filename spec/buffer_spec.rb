require 'spec_helper'

describe 'cmake#buffer' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
  end

  describe '#set_options' do
    before(:each) do
      vim.edit 'plugin.cpp'
      vim.command 'echo cmake#buffer#set_options()'
    end

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
      includedirs_json = validate_response 'echo b:cmake_include_dirs'
      includedirs_json.gsub! '\'', '"'
      includedirs = JSON.parse(includedirs_json)
      expect(includedirs).to_not be_empty

      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end

    it 'adds libraries for current file\'s target' do
      skip 'cmake#targets#libraries returns empty all of the time'
      libdirs_json = validate_response 'echo b:cmake_libraries'
      libdirs = JSON.parse(libdirs_json)
      expect(libdirs).to_not be_empty
      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end
  end

  describe '#set_makeprg' do
    before(:each) do
      vim.edit 'plugin.cpp'
      vim.command 'call cmake#buffer#set_options()'
      vim.command 'call cmake#buffer#set_makeprg()'
    end

    let(:makeprg) { validate_response('setlocal makeprg').gsub 'makeprg=', '' }

    context 'with a known target file' do
      it 'sets the makeprg for this current buffer' do
        current_target = validate_response('echo b:cmake_target').chomp
        current_binary_dir = validate_response('echo b:cmake_binary_dir').chomp
        expect(makeprg).to_not be_empty
        expect(makeprg).to eql("make -C #{current_binary_dir} #{current_target}")
      end
    end

    context 'with a unknown target file' do
      it 'does not set the makeprg' do
        vim.edit 'candy_mountain.cpp'
        expect(makeprg).to be_empty
      end
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
