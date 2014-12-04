# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#extension' do
  describe '#list' do
    it 'obtains a list of extensions' do
      known_extensions = ['vim', 'dispatch', 'ninja', 'gnumake'].sort
      vim_response = validate_json_response 'echo cmake#extension#list()'
      expect(vim_response).to_not be_empty
      expect(vim_response.sort).to eql(known_extensions)
    end
  end

  describe '#default_func' do
    known_extensions = ['dispatch', 'vim']
    existing_types = [
      {
        functions: ['sync', 'async'],
        type: 'exec'
      }
    ]

    known_extensions.each do | extension_name |
      context "checking against the extension #{extension_name}" do
        existing_types.each do | existing_type |
          functions_to_look_for = existing_type[:functions]
          class_to_look_in      = existing_type[:type]

          functions_to_look_for.each do | function |
            it "fetches function #{function} for #{class_to_look_in}" do
              vim.command "let g:cmake_#{class_to_look_in}['#{function}']='#{extension_name}'"
              vim_command = "echo cmake#extension#default_func('#{class_to_look_in}','#{function}')"
              vim_response = validate_response vim_command
              expect(vim_response).to eql("cmake#extension##{extension_name}##{function}")
            end
          end
        end
      end
    end

    context 'checking against unknown extensions' do
      existing_types.each do | existing_type |
        functions_to_look_for = existing_type[:functions]
        class_to_look_in      = existing_type[:type]

        functions_to_look_for.each do | function |
          it "does not fetch function #{function} for #{class_to_look_in}" do
            #vim_command = "echo cmake#extension#default_func('#{class_to_look_in}','#{function}')"
            #vim_response = validate_response vim_command
          end
        end
      end
    end
  end
end
