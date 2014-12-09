require 'spec_helper'

describe 'cmake.vim' do

  describe 'configuration' do
    context 'sets up all of the options' do

      options = [
        'g:cmake_build_directories',
        'g:cmake_build_shared_libs',
        'g:cmake_build_type',
        'g:cmake_c_compiler',
        'g:cmake_ctags',
        'g:cmake_cxx_compiler',
        'g:cmake_extensions',
        'g:cmake_flags',
        'g:cmake_generator',
        'g:cmake_install_prefix',
        'g:cmake_old_path',
        'g:cmake_set_makeprg',
        'g:loaded_cmake'
      ]

      options.each do | option |
        it "checks if the global option #{option} is set" do
          vim_command = "let #{option}"
          vim_response = validate_response(vim_command)
          expect(vim_response).to_not be_empty
        end
      end

    end
  end

  context 'sourcing' do
    it 'sources in the root plugin file' do
      vim_command = 'scriptnames'
      vim_response = validate_response(vim_command)
      expect(vim_response).to_not be_empty
      expect(vim_response).to match 'plugin/cmake.vim'
    end

    describe 'finds the autoload scripts' do
      before(:each) do
        vim.command 'au! cmake.vim'
        cmake.create_new
        cmake.configure
      end

      functions = [
        [ 'cmake#augroup#init()', 'autoload/cmake/augroup.vim' ],
        [ 'cmake#buffer#has_project()', 'autoload/cmake/buffer.vim'],
        [ 'cmake#cache#read_all()', 'autoload/cmake/cache.vim'],
        [ 'cmake#commands#discover_project()', 'autoload/cmake/commands.vim'],
        [ 'cmake#ctags#cache_directory()', 'autoload/cmake/ctags.vim'],
        [ 'cmake#flags#inject()', 'autoload/cmake/flags.vim'],
        [ 'cmake#path#reset()', 'autoload/cmake/path.vim'],
        [ 'cmake#targets#list()', 'autoload/cmake/targets.vim'],
        [ 'cmake#util#binary_dir()', 'autoload/cmake/util.vim'],
      ]

      functions.each do | function |
        function_name = function[0]
        function_script = function[1]

        it "checks if the function '#{function_name}' was loaded from '#{function_script}'" do
          vim.command 'call ' + function_name
          vim_response = validate_response('scriptnames')
          expect(vim_response).to_not be_empty
          expect(vim_response).to match "#{function_script}"
        end
      end
    end
  end

end
