# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#extension' do
  describe '#list' do
    it 'obtains a list of extensions' do
      known_extensions = ['vim', 'dispatch', 'ninja', 'gnumake', 'vimux', 'syntastic', 'ycm'].sort
      vim_response = validate_json_response 'echo cmake#extension#list()'
      expect(vim_response).to_not be_empty
      expect(vim_response.sort).to eql(known_extensions)
    end
  end

  describe '#function_for' do
    it 'crafts the signature of the function for an extension that should provide it' do
      vim.command 'let g:cmake_exec.sync="vim"'
      expected_response = 'cmake#extension#dispatch#sync'
      obtained_response = validate_response "echo cmake#extension#function_for('sync', 'dispatch')"
      expect(obtained_response).to eql(expected_response)
    end
  end

  describe '#functions_for' do
    it 'crafts the signature of functions for extensions that should provide it' do
      obtained_response = validate_json_response "echo cmake#extension#functions_for('find_files_for_target')"
      expect(obtained_response).to_not be_empty
    end
  end
end
