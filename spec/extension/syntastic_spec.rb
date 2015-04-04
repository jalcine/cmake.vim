require 'spec_helper'

describe 'cmake#extension#syntastic' do
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
        vim.command 'au! cmake.vim'
        cmake.create_new_project(
          options: ['-G ' + opts[:generator]]
        )
        cmake.configure(
          options: ['-G ' + opts[:generator]]
        )

        plugin_directory = File.expand_path('../../../', __FILE__) +
                           '/spec/plugins/vim/syntastic'
        vim.append_runtimepath(plugin_directory)
      end

      describe '#inject' do
        context 'function existence' do
          it 'does exist when not called' do
            expect(function_exists? 'cmake#extension#syntastic#inject(args)').to eql(true)
          end

          it 'does exist when called' do
            vim.command 'call cmake#extension#syntastic#inject({"target":"sample-binary"})'
            expect(function_exists? 'cmake#extension#syntastic#inject(args)').to eql(true)
          end
        end

        it 'populates the buffers options' do
          vim.command 'call cmake#extension#syntastic#inject({"target":"sample-library"})'
          obtained_includes = vim.echo 'b:syntastic_cpp_includes'
          expect(obtained_includes).to_not be_empty
          expect(obtained_includes).to_not include('[')
          expect(Dir.exist? obtained_includes).to eql(true)
        end
      end
    end
  end
end
