require 'spec_helper'

describe 'cmake.vim#flags' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
    vim.command 'call cmake#targets#cache()'
    vim.edit 'plugin.cpp'
  end

  describe '#collect' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#collect').to eql(true)
      expect(function_exists? 'cmake#flags#collect(flags_file, prefix)').to eql(true)
    end

    it 'obtains flags for the provided flag file' do
      flag_file = validate_response('echo cmake#flags#file_for_target("sample-library")')
      flags = validate_json_response('echo cmake#flags#collect("'+flag_file+'", "CXX")')
      expect(flags).to_not be_empty
      expect(flags).to include '-fPIC'
    end
  end

  describe '#filter' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#filter').to eql(true)
    end

    context 'filters out flags' do
      it 'removes uninteresting flags' do
        res = validate_json_response 'echo cmake#flags#filter(["-magic"])'
        expect(res).to be_empty
      end

      [
        '-I/usr/include',
        '-i/usr/src',
        '-Wall',
        '-fPIC',
      ].each do | permitted_flag |
        it "permits flags like #{permitted_flag}" do
        command = 'echo cmake#flags#filter(["'+permitted_flag+'"])'
        res = validate_response(command)
        res.gsub! '\'', '"'
        res = JSON.parse(res)
        expect(res).to eql([permitted_flag])
      end
      end
    end
  end

  context 'injection' do
    before(:each) { vim.command 'call cmake#flags#inject()' }

    describe '#inject' do
      it 'exists as an available function' do
        expect(function_exists? 'cmake#flags#inject').to eql(true)
      end

      it 'populates "b:cmake_flags"' do
        flags = validate_json_response 'echo b:cmake_flags'
        expect(flags).to_not be_empty
      end
    end

    describe '#inject_to_syntastic' do
      it 'exists as an available function' do
        expect(function_exists? 'cmake#flags#inject_to_syntastic').to eql(true)
      end

      it 'updates Syntastic options' do
        vim.command 'call cmake#flags#inject_to_syntastic(b:cmake_target)'
        flag_string = validate_response('echo join(b:cmake_flags, " ")')
        syntastic_options = validate_response('echo g:syntastic_cpp_compiler_options')
        expect(syntastic_options).to eql(flag_string)
      end
    end

    describe '#inject_to_ycm' do
      it 'exists as an available function' do
        expect(function_exists? 'cmake#flags#inject_to_ycm').to eql(true)
      end

      it 'applies options for YouCompleteMe' do
        vim.command 'let g:cmake_inject_flags.ycm = 1'
        ycm_vim_data = validate_json_response 'echo g:ycm_extra_conf_vim_data'
        expect(ycm_vim_data).to_not be_empty
        expect(ycm_vim_data.length).to eql(3)
      end
    end
  end
end
