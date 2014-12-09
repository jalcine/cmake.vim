# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#augroup' do
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

      describe '#init' do
        before(:each) do
          vim.command 'au! cmake.vim'
          vim.command 'call cmake#augroup#init()'
          vim.command 'call cmake#targets#cache()'
        end

        let(:aucmd_buf_write)      { validate_response('autocmd BufWrite') }
        let(:aucmd_buf_enter)      { validate_response('autocmd BufEnter') }
        let(:aucmd_file_type)      { validate_response('autocmd FileType') }
        let(:aucmd_file_readpost)  { validate_response('autocmd FileReadPost') }
        let(:aucmd_vimenter)       { validate_response('autocmd VimEnter') }
        let(:augroups)             { validate_response('augroup').split(/(\s)/) }

        it 'uses a augroup we named "cmake.vim"' do
          expect(augroups).to include('cmake.vim')
        end

        it 'has our globals auto commands in all buffers' do
          expect(aucmd_vimenter).to include('cmake.vim')
          expect(aucmd_file_type).to include('cmake.vim')
          expect(aucmd_file_readpost).to include('cmake.vim')
        end

        it 'has our buffer-specific auto commands when in buffers with targets' do
          vim.edit 'binary_main.cpp'
          expect(validate_response 'echo b:cmake_target').to eql('sample-binary')
          expect(aucmd_buf_enter).to include('cmake.vim')
          expect(aucmd_buf_write).to include('cmake.vim')
        end
      end

      describe '#on_vim_enter' do
        it 'exists as a function' do
          expect(function_exists? 'cmake#augroup#on_vim_enter()').to eql(true)
        end

        it 'fills up the cache' do
          vim.command 'call cmake#augroup#on_vim_enter()'
          obtained_hash = validate_json_response 'echo g:cmake_cache'
          expect(obtained_hash['files']).to_not be_empty
          expect(obtained_hash['targets']).to_not be_empty
        end
      end

      describe '#on_file_type' do
        it 'does exists as a function when not called' do
          expect(function_exists? 'cmake#augroup#on_file_type(filetype)').to eql(true)
        end

        context 'for ft="cpp"' do
          before(:each) do
            vim.edit 'plugin.cpp'
          end

          let(:obtained_target) { validate_response 'echo b:cmake_target' }
          let(:expected_target) { 'sample-library' }

          it 'sets the current target' do
            expect(obtained_target).to eql(expected_target)
          end

          it 'sets tags for the project' do
            expected_tags = validate_json_response 'echo cmake#ctags#paths_for_target("sample-library")'
            obtained_tags = validate_json_response 'echo split(&l:tags, ",")'

            expect(obtained_tags).to_not be_empty

            expected_tags.each do | expected_tag |
              expect(obtained_tags).to include(expected_tag)
            end
          end

          it 'sets the makeprg' do
            obtained_makeprg = vim.command 'echo &makeprg'

            expect(obtained_makeprg).to_not be_empty
          end

          it 'sets the path' do
            obtained_source_dir = validate_response "echo cmake#targets#source_dir('#{expected_target}')"
            obtained_binary_dir = validate_response "echo cmake#targets#binary_dir('#{expected_target}')"
            obtained_path = vim.command 'echo split(&l:path,",")'

            expect(obtained_path).to include(obtained_binary_dir)
            expect(obtained_path).to include(obtained_source_dir)
          end
        end

        context 'for ft="cmake"' do
          before(:each) do
            begin
              vim.edit 'CMakeLists.txt'
            rescue
              puts message_history
            end
          end

          it 'does not set tag information' do
            expected_tags = []
            obtained_tags = validate_json_response 'echo split(&l:tags, ",")'

            expect(obtained_tags).to eql(expected_tags)
          end
        end
      end

      describe '#on_buf_enter' do
        let(:obtained_paths)    { validate_json_response 'echo split(&l:path,",")' }
        let(:obtained_makeprg)  { vim.command 'echo &l:makeprg' }

        it 'updates the path for the provided buffer' do
          vim.command  "let g:cmake_old_path .= ',/usr/local/include'"
          vim.edit 'plugin.cpp'
          expect(obtained_paths).to include('/usr/local/include')
        end

        it 'updates the makeprg for the provided buffer' do
          vim.edit 'plugin.cpp'
          old_makeprg = vim.command 'echo &l:makeprg'
          expect(old_makeprg).to_not be_empty

          vim.command 'let &l:makeprg=""'
          expect(vim.command 'echo &l:makeprg').to be_empty

          vim.edit 'CMakeLists.txt'
          vim.command 'buffer plugin.cpp'
          expect(obtained_makeprg).to_not be_empty
          expect(obtained_makeprg).to eql(old_makeprg)
        end
      end

      describe '#on_buf_write' do
        it 'updates the ctags for the provided buffer' do

        end
      end
    end
  end
end
