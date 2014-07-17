require 'spec_helper'

describe 'cmake.vim#commands' do
  describe '#apply_global_commands' do
    it 'exists as a function' do
      expect(function_exists?('cmake#commands#apply_global_commands')).to eql(true)
      expect(function_exists?('cmake#commands#apply_global_commands()')).to eql(true)
    end

    global_commands = [
      'CMakeCreateBuild',
    ]

    global_commands.each do | global_command |
      it 'has the global command "' + global_command + '"' do
      expect(command_exists?('  ' + global_command)).to eql(true)
    end
    end
  end

  describe '#apply_buffer_commands' do
    before(:each) do
      cmake.create_new
      cmake.configure
      vim.edit 'plugin.cpp'
    end

    it 'exists as a function' do
      expect(function_exists?('cmake#commands#apply_buffer_commands')).to eql(true)
      expect(function_exists?('cmake#commands#apply_buffer_commands()')).to eql(true)
    end

    buffer_commands = [
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
      'CMakeInfoForCurrentFile',
    ]

    buffer_commands.each do | buffer_command |
      it 'has the buffer command "' + buffer_command + '"' do
      expect(command_exists?(buffer_command)).to eql(true)
      expect(command_exists?('b ' + buffer_command)).to eql(true)
      end
    end
  end

  context '(api)' do
    before(:each) do
      cmake.create_new
      cmake.configure
      vim.command 'call cmake#targets#cache()'
      vim.edit 'binary_main.cpp'
    end

    describe '#build' do
      it 'exists as a function' do
        expect(function_exists?('cmake#commands#build')).to eql(true)
      end

      it 'expects messages about building to be reported' do
        output = vim.command 'call cmake#commands#build()'
        expect(output).to include('Building all targets...')
        expect(output).to include('Built all targets.')
      end

      it 'invokes the "all" target' do
        output = vim.command 'call cmake#commands#build()'
        expect(output).to include('Invoking target \'all\'...')
      end
    end

    describe '#build_current' do
      it 'exists as a function' do
        expect(function_exists?('cmake#commands#build_current')).to eql(true)
      end

      it 'invokes the target specified by the current buffer' do
        output = vim.command 'call cmake#commands#build_current()'
        expect(output).to include('[cmake] Invoking target \''+vim.command('echo b:cmake_target')+'\'...')
      end
    end

    describe '#clean' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#clean').to eql(true)
      end
    end

    describe '#clear_ctags' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#clear_ctags').to eql(true)
      end
    end

    describe '#create_build' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#create_build').to eql(true)
      end
    end

    describe '#generate_ctags' do
      it 'exists as a function' do
        expect(function_exists?('cmake#commands#generate_ctags')).to eql(true)
      end
    end

    describe '#generate_local_ctags' do
      it 'exists as a function' do
        expect(function_exists?('cmake#commands#generate_local_ctags')).to eql(true)
      end
    end

    describe '#install' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#install').to eql(true)
      end
    end

    describe '#invoke_target' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#invoke_target').to eql(true)
      end
    end

    describe '#rebuild_cache' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#rebuild_cache').to eql(true)
      end
    end

    describe '#test' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#commands#test').to eql(true)
      end
    end
  end
end
