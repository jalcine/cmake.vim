require 'spec_helper'

describe 'cmake.vim#commands' do
  before(:each) do
    vim.edit 'plugin.cpp'
  end

  describe '#apply_global_commands' do
    it 'exists as a function' do
      expect(function_exists('cmake#commands#apply_global_commands')).to be_true
    end

    [
      'CMakeCreateBuild',
    ].each do | global_command |
      it 'has the global command "' + global_command + '"' do
        expect(command_exists('  ' . global_command)).to be_true 
      end
    end
  end

  describe '#apply_buffer_commands' do
    it 'exists as a function' do
      expect(function_exists('cmake#commands#apply_buffer_commands')).to be_true
    end

    [
      'CMakeBuild',
      'CMakeBuildCurrent',
      'CMakeClean',
      'CMakeCleanBuild',
      'CMakeClearBufferOpts',
      'CMakeCtagsBuildAll',
      'CMakeCtagsBuildCurrent',
      'CMakeInstall',
      'CMakeRebuildCache',
      'CMakeTarget',
      'CMakeTest',
      'CMakenfoForCurrentFile',
    ].each do | buffer_command |
      it 'has the buffer command "' + buffer_command + '"' do
        expect(command_exists('b ' + buffer_command)).to be_true 
      end
    end

  end

  describe '#build' do
    it 'exists as a function' do
      expect(function_exists('cmake#commands#build')).to be_true
    end

    it 'expects messages about building to be reported' do
      expect(message_history).to contain('[cmake] Building all targets...')
      expect(message_history).to contain('[cmake] Built all targets.')
    end

    it 'invokes the "all" target' do
      expect(message_history).to contain('[cmake] Invoking target "all"...')
    end
  end

  describe '#build_current' do
    it 'exists as a function' do
      expect(function_exists('cmake#commands#build_current')).to be_true
    end

    it 'invokes the target specified by the current buffer' do
      expect(message_history).to contain('[cmake] Invoking target "'+vim.command('let b:cmake_target')+'"...')
    end
  end

  describe '#build_target_for_file' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#build_target_for_file').to be_true
    end
  end

  describe '#clean' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#clean').to be_true
    end
  end

  describe '#clear_ctags' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#clear_ctags').to be_true
    end
  end

  describe '#create_build' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#create_build').to be_true
    end
  end

  describe '#generate_ctags' do
    it 'exists as a function' do
      expect(function_exists?('cmake#commands#generate_ctags')).to be_true
    end
  end

  describe '#generate_local_ctags' do
    it 'exists as a function' do
      expect(function_exists?('cmake#commands#generate_local_ctags')).to be_true
    end
  end

  describe '#install' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#install').to be_true
    end
  end

  describe '#invoke_target' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#invoke_target').to be_true
    end
  end

  describe '#rebuild_cache' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#rebuild_cache').to be_true
    end
  end

  describe '#test' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#commands#test').to be_true
    end
  end

end
