require 'spec_helper'

describe 'cmake.vim#commands' do
  {
    gnumake: {
      generator: 'Unix\ Makefiles'
    },
    ninja: {
      generator: 'Ninja'
    }
  }.each do |ext, opts|
    context "in #{ext}" do
      before(:each) do
        vim.command 'au! cmake.vim'
        vim.command 'let g:cmake_build_toolchain="' + ext.to_s + '"'
        cmake.create_new_project(
          options: ['-G ' + opts[:generator]]
        )
        cmake.configure(options: ['-G ' + opts[:generator]])
      end

      describe '#apply' do
        before(:each) do
          vim.command 'call cmake#augroup#init()'
          vim.command 'call cmake#augroup#on_vim_enter()'
          vim.edit 'binary_main.cpp'
        end

        it 'exists' do
          vim.command 'call cmake#commands#apply()'
          expect(function_exists? 'cmake#commands#apply').to eql(true)
        end

        commands = %w(CMakeBuild CMakeBuildCurrent CMakeClean CMakeCleanBuild CMakeClearBufferOpts CMakeCreateBuild CMakeCtagsBuildAll CMakeCtagsBuildCurrent CMakeInfoForCurrentFile CMakeInstall CMakeRebuildCache CMakeTarget CMakeTest)

        context do
          commands.each do |cmake_command|
            it "has the command ':#{cmake_command}'" do
              expect(command_exists? cmake_command).to eql(true)
            end
          end
        end
      end

      context 'API' do
        before(:each) do
          vim.command 'call cmake#augroup#init()'
          vim.command 'call cmake#augroup#on_vim_enter()'
          vim.edit 'binary_main.cpp'
        end

        describe '#build' do
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
          it 'invokes the target specified by the current buffer' do
            target = vim.echo 'b:cmake_target'
            output = validate_response 'call cmake#commands#build_current()'
            expect(output).to include('[cmake] Invoking target')
          end
        end

        describe '#clean' do
          it 'invokes the "clean" target for CMake' do
            cmake.build_project
            output = validate_response 'call cmake#commands#clean()'
            expect(output).to include('[cmake] Cleaning build...')
            expect(output).to include('[cmake] Cleaned build.')
          end
        end

        describe '#clear_ctags' do
          it 'clears the generated ctags' do
            cmake.build_project
            output = validate_response 'call cmake#commands#clear_ctags()'
            expect(output).to include('[cmake] Cleared all of the generated tags')
          end
        end

        describe '#create_build' do
          xit 'creates a build'
        end

        describe '#generate_ctags' do
          it 'generates ctags for project' do
            output = validate_response 'call cmake#commands#generate_ctags()'
            expect(output).to include('[cmake] Generated tags for all targets.')
            expect(File.exist? 'build/tags/sample-library.tags').to eql(true)
            expect(File.exist? 'build/tags/sample-binary.tags').to eql(true)
          end
        end

        describe '#generate_local_ctags' do
          it 'generate ctags for a specific project' do
            output = validate_response 'call cmake#commands#generate_local_ctags()'
            expect(output).to include('[cmake] Generated tags for sample-binary.')
            expect(File.exist? 'build/tags/sample-binary.tags').to eql(true)
          end
        end

        describe '#install' do
          it 'invokes the installation target' do
            output = validate_response 'call cmake#commands#install()'
            expect(output).to include('Installed project.')
          end
        end

        describe '#invoke_target' do
          it 'invokes the target specified' do
            output = validate_response "call cmake#commands#invoke_target('all')"
            expect(output).to include("Invoking target 'all'...")
          end
        end

        describe '#rebuild_cache' do
          it 're-generates cache for CMake' do
            output = validate_response 'call cmake#commands#rebuild_cache()'
            expect(output).to include("Invoking target 'rebuild_cache'...")
          end
        end

        describe '#test' do
          it 'invokes the "test" target' do
            output = validate_response 'call cmake#commands#test()'
            expect(output).to include("Invoking target 'test'...")
          end
        end
      end
    end
  end
end
