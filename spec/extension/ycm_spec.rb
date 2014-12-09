require 'spec_helper'

describe 'cmake#extension#ycm' do
  describe '#inject' do
    context 'function existence' do
      it 'does exist when not called' do
        expect(function_exists? 'cmake#extension#ycm#inject(args)').to eql(true)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#extension#ycm#inject({})'
        expect(function_exists? 'cmake#extension#ycm#inject(args)').to eql(true)
      end
    end

    it 'generates the pre-processed string for Ninja' do
      expected_response = 'g:cmake_root_binary_dir'
      vim.command 'call cmake#extension#ycm#inject({})'
      obtained_options = validate_json_response 'echomsg string(g:ycm_extra_conf_vim_data)'
      expect(obtained_options).to include(expected_response)
    end
  end
end
