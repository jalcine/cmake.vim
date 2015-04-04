require 'spec_helper'

describe 'cmake.vim#augroup' do
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
      end

      describe '#init' do
        before(:each) do
          vim.command 'call cmake#targets#cache()'
          vim.command 'call cmake#augroup#init()'
        end

        let(:aucmd_buf_write) { validate_response('autocmd BufWrite') }
        let(:aucmd_buf_enter) { validate_response('autocmd BufEnter') }
        let(:aucmd_file_type) { validate_response('autocmd FileType') }
        let(:aucmd_filewritepost) { validate_response('autocmd FileWritePost') }
        let(:aucmd_vimenter) { validate_response('autocmd VimEnter') }
        let(:augroups) { validate_response('augroup').split(/(\s)/) }
        let(:current_target) { validate_response 'echo b:cmake_target' }

        it 'uses augroup we named "cmake.vim"' do
          expect(augroups).to include('cmake.vim')
        end

        it 'has globals auto commands in all buffers' do
          expect(aucmd_vimenter).to include('cmake.vim')
          expect(aucmd_file_type).to include('cmake.vim')
          expect(aucmd_filewritepost).to include('cmake.vim')
        end

        it 'has buffer auto commands when in buffers w/ targets' do
          vim.edit 'binary_main.cpp'
          target_list = validate_json_response 'echo cmake#targets#list()'
          expect(target_list).to_not be_empty
          expect(aucmd_buf_enter).to include('cmake.vim')
          expect(aucmd_buf_write).to include('cmake.vim')
          expect(current_target).to eql('sample-binary')
        end

        it 'has buffer auto commands when in buffers w/o targets' do
          vim.edit 'magic_toy.cxx'
          vim.write
          expect(aucmd_buf_enter).to include('cmake.vim')
          expect(aucmd_buf_write).to include('cmake.vim')
          expect(vim.echo 'b:cmake_target').to_not eql('sample-binary')
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

      describe '#on_buf_enter' do
        let(:the_paths) { validate_json_response 'echo split(&l:path,",")' }
        let(:obtained_makeprg) { vim.command 'echo &l:makeprg' }

        before(:each) do
          vim.command 'call cmake#targets#cache()'
          vim.command 'call cmake#augroup#init()'
        end

        it 'updates the path for the provided buffer' do
          vim.command "let g:cmake_old_path .= ',/usr/local/include'"
          vim.edit 'plugin.cpp'
          expect(the_paths).to include('/usr/local/include')
        end

        it 'updates the makeprg for the provided buffer' do
          vim.edit 'plugin.cpp'
          old_makeprg = vim.echo '&l:makeprg'
          expect(old_makeprg).to_not be_empty

          vim.command 'let &l:makeprg=""'
          expect(vim.echo '&l:makeprg').to be_empty

          vim.edit 'CMakeLists.txt'
          vim.command 'buffer plugin.cpp'
          expect(obtained_makeprg).to_not be_empty
          expect(obtained_makeprg).to eql(old_makeprg)
        end
      end

      describe '#on_buf_write' do
        let(:tag_list)       { vim.echo 'taglist("function")' }
        let(:current_target) { validate_response 'echo b:cmake_target' }
        let(:known_targets)  { vim.echo 'keys(g:cmake_cache.targets)' }

        it 'updates the ctags for the provided buffer' do
          skip <<PENDING_TEST

  * Update buffer with a new function
  * Confirm new function is in file.
  * Save file
  * Check tag list to see if the new tags has been added.
PENDING_TEST
        end

        it 'reloads target files for target-specific CMakeLists.txt files' do
          skip <<PENDING_TEST
  * Unset list of files for current target.
  * Add new line to buffer.
  * Save file.
  * Check current target's file list to be repopulated with same list.
PENDING_TEST
        end
      end

      describe '#on_file_type' do
        it 'does exists as a function when not called' do
          exist_func = function_exists? 'cmake#augroup#on_file_type(filetype)'
          expect(exist_func).to eql(true)
        end

        context 'for ft="cpp"' do
          before(:each) do
            vim.command 'au! cmake.vim'
            vim.command 'call cmake#targets#cache()'
            vim.command 'call cmake#augroup#init()'
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

            expected_tags.each do |expected_tag|
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
            vim.edit 'CMakeLists.txt'
          end

          it 'does not set tag information' do
            expected_tags = []
            obtained_tags = validate_json_response 'echo split(&l:tags, ",")'

            expect(obtained_tags).to eql(expected_tags)
          end

          xit 'sets the makeprg' do
            obtained_makeprg = vim.command 'echo &makeprg'
            expect(obtained_makeprg).to_not be_empty
            expect(obtained_makeprg).to end_with('all')
          end
        end
      end

      describe '#on_file_write' do
        let(:current_target)  { vim.echo 'b:cmake_target' }
        let(:current_flags)   { validate_json_response 'echo g:cmake_cache.targets[b:cmake_target].flags' }
        let(:current_sources) { validate_json_response 'echo g:cmake_cache.targets[b:cmake_target].files' }
        let(:targets) { validate_json_response 'echo cmake#targets#list()' }

        before(:each) do
          vim.command 'call cmake#targets#cache()'
          vim.command 'call cmake#augroup#init()'
          vim.edit 'CMakeLists.txt'
        end

        it 'updates compile flags when CMake changes' do
          vim.edit 'plugin.cpp'
          old_target = current_target
          old_compile_flags = current_flags

          vim.edit 'CMakeLists.txt'

          vim.insert(<<-FILE)
            ADD_INCLUDE_DIRECTORIES("/usr/local/include")
            ADD_COMPILE_DEFINITIONS(FOOBAR)
            ADD_COMPILE_FLAGS(--std=c++11)
          FILE

          vim.write
          pending 'Check this out.'
          expect(targets).to include(old_target)

          vim.edit 'plugin.cpp'
          new_compile_flags = current_flags
          expect(new_compile_flags).to_not eql(old_compile_flags)
        end
      end

      describe '#on_buf_write' do
        let(:current_target) { validate_response('echo b:cmake_target').chomp }
        let(:current_sources) { validate_json_response 'echo g:cmake_cache[b:cmake_target].files' }

        before(:each) do
          vim.command 'call cmake#targets#cache()'
          vim.command 'call cmake#augroup#init()'
        end

        it 'updates the ctags for the provided buffer' do
          vim.edit 'plugin.cpp'
          tag_file = "build/tags/#{current_target}.tags"
          expect(File.exist? tag_file).to be(true)
          # TODO: Use timestamping changes.
        end
      end

      describe '#on_file_type' do
        let(:current_target) { vim.command 'echo b:cmake_target' }

        before(:each) do
          vim.command 'call cmake#targets#cache()'
          vim.command 'call cmake#augroup#init()'
        end

        it 'sets the target for the current buffer' do
          vim.edit 'plugin.cpp'
          expect(current_target).to eql('sample-library')
        end

        it "doesn't do a check when not within the project directory" do
          vim.edit '/etc/motd'
          expect(current_target).to match(/Undefined variable/)
        end
      end
    end
  end
end
