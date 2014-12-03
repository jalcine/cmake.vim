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
      short_function_call = 'cmake#flags#collect'
      function_call = 'cmake#flags#collect(flags_file, prefix)'
      expect(function_exists? short_function_call).to eql(true)
      expect(function_exists? function_call).to eql(true)
    end

    it 'obtains flags for the provided flag file' do
      flag_file = validate_response('echo cmake#flags#file_for_target("sample-library")')
      flags = validate_json_response('echo cmake#flags#collect("' + flag_file + '", "CXX")')
      expect(flags).to_not be_empty
      expect(flags).to include '-fPIC'
    end
  end

  describe '#filter' do
    it 'exists as an available function' do
      expect(function_exists? 'cmake#flags#filter').to eql(true)
    end

    it 'removes uninteresting flags' do
      res = validate_json_response 'echo cmake#flags#filter(["-magic"])'
      expect(res).to be_empty
    end

    flags = [
      '-I/usr/include',
      '-i/usr/src',
      '-Wall',
      '-fPIC',
    ]

    flags.each do | permitted_flag |
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
