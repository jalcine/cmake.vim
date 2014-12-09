require 'spec_helper'

describe 'cmake#extension#gnumake' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project({
      options: ['-G "Unix Makefiles"']
    })
  end

  describe '#makeprg' do
    context 'function existence' do
      it 'does exist when not called' do
        expect(function_exists? 'cmake#extension#gnumake#makeprg()').to eql(true)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#extension#gnumake#makeprg()'
        expect(function_exists? 'cmake#extension#gnumake#makeprg()').to eql(true)
      end
    end

    it 'generates the pre-processed string for GNU Make' do
      expected_command = 'make -C {{root_build_directory}} {{target}}'
      obtained_command = validate_response 'echo cmake#extension#gnumake#makeprg()'
      expect(obtained_command).to eql(expected_command)
    end
  end

  describe '#find_libraries_for_target' do
    context 'function existence' do
      it 'does exist when not called' do
        expect(function_exists? 'cmake#extension#gnumake#find_files_for_target(target)').to eql(true)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#extension#gnumake#find_files_for_target("sample-binary")'
        expect(function_exists? 'cmake#extension#gnumake#find_files_for_target(target)').to eql(true)
      end
    end

    it 'finds the libraries for an existing target' do
      expected_libraries = ['dl']
      obtained_libraries = validate_json_response 'echo cmake#extension#gnumake#find_libraries_for_target("sample-library")'
      expect(obtained_libraries).to eql(expected_libraries)
    end

    it 'does not find the libraries for an existing target' do
      obtained_libraries = vim.command 'echo cmake#extension#gnumake#find_libraries_for_target("bram")'
      expect(obtained_libraries).to match(/E(\d+)/)
    end

    it 'does not find libraries when outside of a project directory' do
      vim.command 'cd expand(":~")'
      obtained_libraries = vim.command 'echo cmake#extension#gnumake#find_libraries_for_target("bram")'
      expect(obtained_libraries).to match(/E(\d+)/)
    end
  end

  describe '#find_files_for_target' do
    let(:expected_files) { ['plugin.cpp'] }

    context 'function existence' do
      it 'does exist when not called' do
        expect(function_exists? 'cmake#extension#gnumake#find_files_for_target(target)').to eql(true)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#extension#gnumake#find_files_for_target("sample-binary")'
        expect(function_exists? 'cmake#extension#gnumake#find_files_for_target(target)').to eql(true)
      end
    end

    it 'finds the files associated with a target' do
      obtained_files = validate_json_response 'echo cmake#extension#gnumake#find_files_for_target("sample-library")'
      expect(obtained_files).to eql(expected_files)
    end

    it 'does not find the files associated with a target when out of the project directory' do
      vim.command 'cd! ../..' 
      obtained_files = validate_json_response 'echo cmake#extension#gnumake#find_files_for_target("sample-library")'
      expect(obtained_files).to be_empty
    end

    it 'does not find files when outside of a project directory' do
      vim.command 'cd ../../'
      obtained_files = validate_json_response 'echo cmake#extension#gnumake#find_files_for_target("sample-library")'
      expect(obtained_files).to be_empty
    end
  end

  describe '#find_targets' do
    context 'function existence' do
      it 'does exist when not called' do
        expect(function_exists? 'cmake#extension#gnumake#find_files_for_target(target)').to eql(true)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#extension#gnumake#find_files_for_target("sample-binary")'
        expect(function_exists? 'cmake#extension#gnumake#find_files_for_target(target)').to eql(true)
      end
    end

    it 'finds the targets for the project' do
      expected_targets = ['sample-library', 'sample-binary']
      obtained_targets = validate_json_response 'echo cmake#extension#gnumake#find_targets()'
      expect(obtained_targets.sort).to eql(expected_targets.sort)
    end

    it 'does not find the targets for the project when ot configured' do
      FileUtils.remove_dir vim.command('echo cmake#util#binary_dir()'), true
      obtained_targets = validate_json_response 'echo cmake#extension#gnumake#find_targets()'
      expect(obtained_targets).to be_empty
    end

    it 'does not find targets when outside of a project directory' do
      vim.command 'cd ../..'
      obtained_targets = validate_json_response 'echo cmake#extension#gnumake#find_targets()'
      expect(obtained_targets).to be_empty
    end
  end
end
