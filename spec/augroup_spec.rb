# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#augroup' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
  end

  describe '#on_vim_enter' do
    before(:each) { vim.command('call cmake#augroup#on_vim_enter()') }

    it 'adds the global commands' do
      expect(command_exists? 'CMakeCreateBuild').to eql(true)
    end

    it 'ensures that targets are added if a CMake project is available' do
      targets_json = validate_response('echo cmake#targets#list()')
      targets_json.gsub! '\'', '"'
      targets = JSON.parse(targets_json)
      expect(targets).to_not be_empty
      expect(targets.sort).to eql(['sample-binary', 'sample-library'])
    end

    it 'caches all of the files related to the known targets' do
      srcdir = validate_response('echo cmake#util#source_dir()')
      files = {
        'sample-binary'  => ["#{srcdir}binary_main.cpp"],
        'sample-library' => ["#{srcdir}plugin.cpp"]
      }

      files.keys.each do | target |
        file_json = validate_response("echo cmake#targets#files('#{target}')").gsub('\'', '"')
        file_json.gsub! '\'', '"'
        file_list = JSON.parse(file_json)
        expect(file_list).to_not be_empty
        expect(file_list.sort).to eql(files[target].sort)
      end

    end
  end

  describe '#on_buf_read' do
    {
      'source file'  => 'plugin.cpp',
      'header file'  => 'plugin.hpp',
      #'CMake source file' => 'CMakeLists.txt'
    }.each do | label, file |
      context "for a #{label}'s buffer" do
        before(:each) { vim.edit file }

        [
          'target',
          'binary_dir',
          'source_dir',
          'include_dirs',
          'libraries',
        ].shuffle.each do | option |
          it 'sets the option "b:cmake_' + option + '"' do
            expect(validate_response('echo b:cmake_' + option)).to_not be_empty
          end
        end

        [
          'CMakeBuild',
          'CMakeRebuildCache',
          'CMakeClean',
          'CMakeCleanBuild',
          'CMakeTest',
          'CMakeInstall',
          'CMakeClearBufferOpts',
          'CMakeCtagsBuildAll',
          'CMakeCtagsBuildCurrent',
          'CMakeInfoForCurrentFile',
        ].shuffle.each do | buffer_command |
          it 'sets the command ":' + buffer_command + '"' do
            expect(command_exists? buffer_command).to eql(true)
            expect(command_exists? ('b ' + buffer_command)).to eql(true)
          end
        end
      end
    end
  end

  describe '#on_buf_enter' do
    before(:each) do
      vim.edit 'plugin.cpp'
    end

    it 'sets the makeprg variable for this buffer' do
      makeprg = vim.command('setl makeprg')
      expect(makeprg).to_not be_empty
      expect(makeprg).to match 'make'
      expect(makeprg).to match vim.command('echo b:cmake_target')
      expect(makeprg).to match vim.command('echo b:cmake_binary_dir')
    end

    xit 'sets the flags for this file\'s target' do
      flags_json = vim.command('let b:cmake_flags')
      flags_json.gsub! '\'', '"'
      flags = JSON.parse(flags_json)
      filetype = vim.command('let &l:filetype')

      expect(filetype).to_not be_empty
      expect(flags.keys.count).to be(2)
      expect(flags[filetype]).to_not be_empty
    end

    it 'sets the ctags file for this file\'s target' do
      ctags_list = vim.command('echo &l:tags')
      known_ctags_files_json = validate_response('echo cmake#ctags#paths_for_target(b:cmake_target)')
      known_ctags_files_json.gsub! '\'', '"'
      expect(known_ctags_files_json).to_not be_empty
      begin
        known_ctags_files = JSON.parse(known_ctags_files_json)
      rescue Exception => e
        fail 'No target found.' + e.message
      end

      ctags = ctags_list.split ','

      expect(ctags).to_not be_empty
      known_ctags_files.each do | a_path |
        expect(ctags).to include(a_path)
      end
    end

    it 'sets the include paths for this file\'s target to :path' do
      path_list = vim.command('echo &l:path')
      paths = path_list.split ','

      expect(paths).to_not be_empty
      target_paths = validate_response('echo cmake#targets#include_dirs(b:cmake_target)')
      target_paths.gsub! '\'', '"'
      target_paths = JSON.parse(target_paths)
      target_paths.each do | a_path |
        expect(paths).to include(a_path)
      end

    end
  end

  describe '#init' do
    let(:aucmd_bufread)  { validate_response('autocmd BufRead') }
    let(:aucmd_bufenter) { validate_response('autocmd BufEnter') }
    let(:augroups) { validate_response('augroup').split(/(\s)/) }

    it 'loads #on_buf_read() on files that matches the regex *.*pp' do
      expect(aucmd_bufread).to include('cmake.vim  BufRead')
      expect(aucmd_bufread).to include('*.*pp')
      expect(aucmd_bufread).to include('cmake#augroup#on_buf_read()')
    end

    it 'loads #on_buf_enter() on files that matches the regex *.*pp' do
      expect(aucmd_bufenter).to include('cmake.vim  BufEnter')
      expect(aucmd_bufenter).to include('*.*pp')
      expect(aucmd_bufenter).to include('cmake#augroup#on_buf_enter()')
    end

    it 'uses a augroup' do
      expect(augroups).to include('cmake.vim')
    end
  end
end
