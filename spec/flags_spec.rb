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
      flags = JSON.parse(validate_response('echo cmake#flags#collect("'+flag_file+'", "CXX")').gsub '\'', '"')
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
        res = validate_response('echo cmake#flags#filter(["-magic"])')
        res.gsub! '\'', '"'
        res = JSON.parse res
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
  
  describe '#inject' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#inject').to eql(true)
    end

    it 'populates "b:cmake_flags"' do
      vim.command 'call cmake#flags#inject()'
      flags = JSON.parse(validate_response('echo b:cmake_flags').gsub('\'', '"'))
      expect(flags).to_not be_empty
    end
  end

  describe '#inject_to_syntastic' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#inject_to_syntastic').to eql(true)
    end
  end

  describe '#inject_to_ycm' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#inject_to_ycm').to eql(true)
    end
  end

  describe '#prep_ycm' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#prep_ycm').to eql(true)
    end
  end
end
