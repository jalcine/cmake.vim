require 'spec_helper'

describe 'cmake#buffer' do
  {
    gnumake: {
      generator: 'Unix\ Makefiles'
    },
    ninja: {
      generator: 'Ninja'
    }
  }.each do |ext, opts|
    context "when using a #{ext} build system" do
      before(:each) do
        vim.command 'let g:cmake_build_toolchain="' + ext.to_s + '"'
        cmake.create_new_project(
          options: ['-G ' + opts[:generator]]
        )
        cmake.configure(
          options: ['-G ' + opts[:generator]]
        )
        vim.command 'au! cmake.vim'
        vim.command 'call cmake#targets#cache()'
      end

      describe '#set_options' do
        before(:each) do
          vim.edit 'plugin.cpp'
          vim.command 'echo cmake#buffer#set_options()'
        end

        it 'adds target binary directory for current buffer' do
          bindir = validate_response 'echo b:cmake_binary_dir'
          expect(bindir).to_not be_empty
          expect(Dir.exist? bindir).to eql(true)
        end

        it 'adds target source directory for current buffer' do
          srcdir = validate_response('echo b:cmake_source_dir')
          expect(srcdir).to_not be_empty
          expect(srcdir).to_not start_with('0')
          expect(Dir.exist? srcdir).to eql(true)
        end

        it 'adds target include directories for current buffer' do
          includedirs = validate_json_response 'echo b:cmake_include_dirs'
          expect(includedirs).to_not be_empty
          # FIXME: Consider checking for existence of directories.
          # includedirs.each { |dir| expect(Dir.exist? dir).to eql(true) }
        end

        it 'adds target libraries for current buffer' do
          expected_libs = ['dl']
          obtained_libs = validate_json_response 'echo b:cmake_libraries'
          expect(obtained_libs).to_not be_empty
          expect(obtained_libs).to eql(expected_libs)
        end
      end

      describe '#has_project' do
        let(:result) { validate_response 'echo cmake#buffer#has_project()' }

        context 'confirm existence of project within buffer where file' do
          it 'lies inside a CMake source tree' do
            vim.edit 'plugin.cpp'
            expect(result).to eql '1'
          end

          it 'lies outside in a CMake source file' do
            vim.edit Dir.home
            expect(result).to eql '0'
          end
        end

        context 'ensures that the filetype of the file' do
          before(:each) { vim.edit 'plugin.cpp' }

          context 'invalid filetypes' do
            %w(cxx foobar).each do |ft|
              it 'does match for those of the "' + ft + '" filetype' do
                vim.command 'set ft=' + ft
                expect(result).to eql('1')
              end
            end
          end

          context 'valid filetypes' do
            %w(c cpp cmake).each do |ft|
              it 'matches for those of the "' + ft + '" filetype' do
                vim.command 'set ft=' + ft
                expect(result).to eql('1')
              end
            end
          end
        end
      end
    end
  end
end
