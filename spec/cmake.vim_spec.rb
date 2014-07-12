require 'spec_helper'

describe 'cmake.vim' do
  describe 'configuration' do
    context 'sets up all of the options' do
      options = [
        'g:cmake_cache',
        'g:cmake_cache.targets',
        'g:cmake_cache.files',
        'g:cmake_cxx_compiler',
        'g:cmake_c_compiler',
        'g:cmake_build_type',
        'g:cmake_install_prefix',
        'g:cmake_build_shared_libs',
        'g:cmake_ctags',
        'g:cmake_ctags.project_files',
        'g:cmake_ctags.include_files',
        'g:cmake_ctags.executable',
        'g:cmake_set_makeprg',
        'g:cmake_use_dispatch',
        'g:cmake_filter_flags',
        'g:cmake_inject_flags',
        'g:cmake_inject_flags.syntastic',
        'g:cmake_inject_flags.ycm',
      ]

      options.each do | option |
        it "checks if the global option #{option} is set" do
          expect(validate_response("echo #{option}")).to_not be_empty
        end
      end
    end
  end

  describe 'setting up augroup' do
    it 'has cmake in the augroups' do
      expect(validate_response 'au').to match 'cmake.vim'
    end

    context 'invokes the augroup' do
      let(:known_augroups) { vim.command 'au' }
      augroups = [
        'BufReadPre',
        'BufEnter'
      ]

      augroups.each do | augroup |
        it "uses the augroup #{augroup}" do
          expect(known_augroups).to match "cmake.vim  #{augroup}"
        end
      end
    end
  end
end
