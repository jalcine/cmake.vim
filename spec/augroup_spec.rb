# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#augroup' do
  around(:each) do | example |
    cmake.create_new_project
    cmake.configure_project
    example.run
    cmake.destroy_project
  end

  describe '#on_vim_enter' do
    before(:each) { vim.command('call cmake#augroup#on_vim_enter()') }

    it 'adds the global commands' do
      known_commands = vim.command('command')
      expect(known_commands).to_not be_empty
      expect(known_commands).to match('CMakeCreateBuild')
    end

    it 'ensures that targets are added if a CMake project is available' do
      targets_json = vim.command('call cmake#targets#list()')
      targets = JSON.parse(targets_json)
      expect(targets).to_not be_empty
      expect(targets).to eql(['sample-binary', 'sample-library'])
    end

    it 'caches all of the files related to the known targets' do
      files = {
        'sample-binary' => ['binary_main.cpp'],
        'sample-library' => ['plugin_main.cpp', 'plugin_main.hpp']
      }

      files.keys.each do | target |
        file_json = vim.command('call cmake#targets#files("' + target + '")')
        file_list = JSON.parse(file_json)
        expect(file_list).to_not be_empty
        expect(file_list).to eql(files[target])
      end

    end
  end
  
  describe '#on_buf_read' do
    {
      'source file'  => 'plugin.cpp',
      'header file'  => 'plugin.hpp',
      'CMake source file' => 'CMakeLists.txt'
    }.each do | label, file |
      context "for a #{label}'s buffer" do
        let(:known_commands) { vim.command('command') }

        before(:all) { vim.edit "data/#{file}" }

        [
          'target', 'binary_dir',
          'source_dir', 'include_dirs',
          'libraries',
        ].each do | option |
          it 'sets the option "b:cmake_' + option + '"' do
            expect(vim.command('let b:cmake_' + option)).to_not be_empty
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
        ].each do | buffer_command |
          it 'sets the command ":' + buffer_command + '"' do
            expect(known_commands).to match('b ' + buffer_command)
          end
        end
      end
    end
  end

  describe '#on_buf_enter' do
    before(:each) do
      vim.edit "#{Dir.pwd}/binary_main.cpp"
    end

    it 'sets the makeprg variable for this buffer' do
      makeprg = vim.command('let &l:makeprg')
      expect(makeprg).to_not be_empty
      expect(makeprg).to match 'make'
      expect(makeprg).to match vim.command('let b:cmake_target')
    end

    it 'sets the flags for this file\'s target' do
      flags_json = vim.command('let b:cmake_flags')
      flags = JSON.parse(flags_json)
      filetype = vim.command('let &l:filetype')

      expect(filetype).to_not be_empty
      expect(flags.keys.count).to be(2)
      expect(flags[filetype]).to_not be_empty
    end

    it 'sets the ctags file for this file\'s target' do
      ctags_list = vim.command('let &l:tags')
      known_ctags_files_json = vim.command('call cmake#ctags#paths_for_target(b:cmake_target)')
      expect(known_ctags_files_json).to_not be_empty
      begin
        known_ctags_files = JSON.parse(known_ctags_files_json)
      rescue JSON::ParseError => e
        fail "No target found."
      end

      ctags = ctags_list.split ','

      expect(ctags).to_not be_empty
      known_ctags_files.each do | a_path |
        expect(ctags).to contain(a_path)
      end
    end

    it 'sets the include paths for this file\'s target' do
      path_list = vim.command('let &l:path')
      paths = path_list.split ','

      expect(paths).to_not be_empty
      target_paths = JSON.parse(vim.command('call cmake#targets#include_dirs(b:cmake_target)'))
      target_paths.each do | a_path |
        expect(paths).to contain(a_path)
      end

    end
  end

  describe '#init' do
    let(:aucmds) { vim.command('autocommand') }
    let(:augroups) { vim.command('augroup').split(/(\s)/) }

    it 'loads #on_buf_read() on files that matches the regex *.*pp' do
      expect(aucmds).to match('cmake.vim BufReadPre')
    end

    it 'loads #on_buf_enter() on files that matches the regex *.*pp' do
      expect(aucmds).to match('cmake.vim BufEnter')
    end

    it 'uses a augroup' do
      expect(augroups).to have('cmake.vim')
    end
  end
end
