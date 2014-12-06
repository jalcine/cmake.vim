require 'spec_helper'

describe 'cmake#extension#ninja' do
  before(:each) do
    vim.command 'au! cmake.vim'
    cmake.create_new_project
    cmake.configure_project
  end

  describe '#makeprg' do
    context 'function existence' do
      it 'exists when called' do
        validate_response 'echo cmake#targets#build("sample-binary")'
        expect(function_exists? 'cmake#targets#build(target)').to eql(true)
      end

      # NOTE: This is due to autocommands invoking this function, thus pulling
      # in all of the extra methods.
      it 'does not exists when not called' do
        expect(function_exists? 'cmake#targets#build(target)').to eql(false)
      end
    end

    it 'generates a Ninja-specific command for the makeprg options' do
      expected_command = 'ninja -C {{root_build_directory}} {{target}}'
      output = validate_response 'echo cmake#extension#ninja#makeprg()'
      expect(output).to match expected_command
    end
  end

  describe '#find_files_for_target' do
    context'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#extension#ninja#find_files_for_target(target)').to eql(false)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#extension#ninja#find_files_for_target("sample-binary")'
        expect(function_exists? 'cmake#extension#ninja#find_files_for_target(target)').to eql(true)
      end
    end

    it 'obtains a list of files for the specified Ninja target' do
      expected_list = ['plugin.cpp']
      obtained_list = validate_json_response 'echo cmake#extension#ninja#find_files_for_target("sample-library")'
      expect(obtained_list).to eql(expected_list)
    end
  end
end
