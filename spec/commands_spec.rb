require 'spec_helper'

describe 'cmake.vim#commands' do
  {
    gnumake: {
      generator: 'Unix\ Makefiles'
    },
    ninja: {
      generator: 'Ninja'
    }
  }.each do | ext, opts |
    context "when using a #{ext} build system" do
      before(:each) do
        vim.command 'au! cmake.vim'
        cmake.create_new_project
        cmake.configure({
          options: ['-G ' + opts[:generator] ]
        })
      end

      describe '#apply_global_commands' do
        it 'does not exists when not called' do
          expect(function_exists?('cmake#commands#apply_global_commands()')).to eql(false)
        end

        global_commands = [
          'CMakeCreateBuild',
          'CMakeClean',
          'CMakeCleanBuild',
          'CMakeBuild',
          'CMakeInstall',
          'CMakeRebuildCache',
          'CMakeCtagsBuildAll',
          'CMakeTest',
        ]

        global_commands.each do | global_command |
          it "has the global command ':#{global_command}'" do
            vim.command 'call cmake#commands#apply_global_commands()'
            expect(command_exists?(global_command)).to eql(true)
          end
        end
      end

      describe '#apply_buffer_commands' do
        before(:each) do
          vim.command 'call cmake#augroup#init()'
          vim.edit 'binary_main.cpp'
        end

        it 'exists as a function when entering a buffer' do
          expect(function_exists?('cmake#commands#apply_buffer_commands()')).to eql(true)
        end

        buffer_commands = [
          'CMakeTarget',
          'CMakeBuildCurrent',
          'CMakeClearBufferOpts',
          'CMakeCtagsBuildCurrent',
          'CMakeInfoForCurrentFile',
        ]

        buffer_commands.each do | buffer_command |
          it "has the buffer command ':#{buffer_command}'" do
            vim.command 'call cmake#commands#apply_buffer_commands()'
            expect(command_exists?('b ' + buffer_command)).to eql(true)
          end
        end
      end

      context 'API' do
        before(:each) do
          vim.edit 'binary_main.cpp'
          vim.command 'call cmake#buffer#set_options()'
        end

        describe '#build' do
          it 'does not exists as a function' do
            expect(function_exists?('cmake#commands#build')).to eql(false)
          end

          it 'expects messages about building to be reported' do
            output = vim.command 'call cmake#commands#build()'
            expect(output).to include('Building all targets...')
            expect(output).to include('Built all targets.')
          end

          it 'invokes the "all" target' do
            output = vim.command 'call cmake#commands#build()'
            expect(output).to include("Invoking target 'all'...")
          end
        end

        describe '#build_current' do
          it 'does not exists as a function' do
            expect(function_exists?('cmake#commands#build_current()')).to eql(false)
          end

          it 'invokes the target specified by the current buffer' do
            output = vim.command 'call cmake#commands#build_current()'
            expect(output).to include("[cmake] Invoking target '#{vim.command('echo b:cmake_target')}'...")
          end
        end

        describe '#clean' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#clean').to eql(false)
          end
        end

        describe '#clear_ctags' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#clear_ctags').to eql(false)
          end
        end

        describe '#create_build' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#create_build').to eql(false)
          end
        end

        describe '#generate_ctags' do
          it 'does not exists as a function' do
            expect(function_exists?('cmake#commands#generate_ctags')).to eql(false)
          end
        end

        describe '#generate_local_ctags' do
          it 'does not exists as a function' do
            expect(function_exists?('cmake#commands#generate_local_ctags')).to eql(false)
          end
        end

        describe '#install' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#install').to eql(false)
          end
        end

        describe '#invoke_target' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#invoke_target').to eql(false)
          end
        end

        describe '#rebuild_cache' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#rebuild_cache').to eql(false)
          end
        end

        describe '#test' do
          it 'does not exists as a function' do
            expect(function_exists? 'cmake#commands#test').to eql(false)
          end
        end
      end
    end
  end
end
