require 'spec_helper'

describe 'cmake#buffer' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
    vim.command 'au! cmake.vim'
  end

  describe '#set_options' do
    before(:each) do
      vim.edit 'plugin.cpp'
      vim.command 'echo cmake#buffer#set_options()'
    end

    it 'adds target binary directory for current buffer' do
      bindir = validate_response 'echo b:cmake_binary_dir'
      expect(bindir).to_not be_empty
      expect(Dir.exists? bindir).to eql(true)
    end

    it 'adds target source directory for current buffer' do
      srcdir = validate_response('echo b:cmake_source_dir')
      expect(srcdir).to_not be_empty
      expect(srcdir).to_not start_with('0')
      expect(Dir.exists? srcdir).to eql(true)
    end

    it 'adds target include directories for current buffer' do
      includedirs = validate_json_response 'echo b:cmake_include_dirs'
      expect(includedirs).to_not be_empty

      includedirs.each { | dir | expect(Dir.exist? dir).to eql(true) }
    end

    it 'adds target libraries for current buffer' do
      expected_libs = [ 'dl']
      obtained_libs = validate_json_response 'echo b:cmake_libraries'
      expect(obtained_libs).to_not be_empty
      expect(obtained_libs).to eql(expected_libs)
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
        binary_dir = validate_response('echo g:cmake_root_binary_dir').chomp
        expected_makeprg = "make -C #{binary_dir} #{current_target}"
        expect(makeprg).to_not be_empty
        expect(makeprg).to eql(expected_makeprg)
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

      valid_filetypes = ['c', 'cpp', 'cmake']
      invalid_filetypes = ['cxx', 'foobar', 'bram']

      valid_filetypes.each do | ft |
        it 'matches for those of the "' + ft + '" filetype' do
          vim.command 'set ft=' + ft
          expect(result).to eql('1')
        end
      end

      invalid_filetypes.each do | ft |
        it 'does not match for those of the "' + ft + '" filetype' do
          vim.command 'set ft=' + ft
          expect(result).to eql('0')
        end
      end
    end
  end
end
