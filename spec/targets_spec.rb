require 'spec_helper'

describe 'cmake#targets' do
  before(:each) do
    vim.command 'au! cmake.vim'
    cmake.create_new_project
    cmake.configure_project
  end

  describe '#build' do
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

    it 'builds the specified target' do
      vim.edit 'plugin.cpp'
      output = validate_response 'echo cmake#targets#build("sample-binary")'
      expect(output).to match 'sample-binary'
    end
  end

  describe '#exists' do
    context'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#exists(target)').to eql(false)
      end

      it 'does exist when called' do
        vim.command 'call cmake#targets#cache()'
        validate_response 'echo cmake#targets#exists("sample-binary")'
        expect(function_exists? 'cmake#targets#exists(target)').to eql(true)
      end
    end

    it 'confirms the existence of known targets' do
      resp = validate_response('echo cmake#targets#exists("sample-library")').to_i
      expect(resp).to eql(1)
    end

    it 'confirms the lack of a unknown targets' do
      resp = validate_response('echo cmake#targets#exists("kid-robot")').to_i
      expect(resp).to eql(0)
    end
  end

  describe '#files' do
    let(:files) { validate_response 'echo cmake#targets#files("sample-library")' }
    let(:bad_files) { validate_response 'echo cmake#targets#files("iron-load")' }

    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#files(target)').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#targets#files("sample-binary")'
        expect(function_exists? 'cmake#targets#files(target)').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'procures the files for a known target' do
      file_list = JSON.parse(files.gsub '\'', '"')
      expect(file_list).to_not be_empty
      expect(file_list.count).to eql(1)
      expect(file_list[0]).to end_with 'plugin.cpp'
    end

    it 'procures nothing for a non-existing target' do
      file_list = JSON.parse(bad_files.gsub '\'', '"')
      expect(file_list).to be_empty
    end
  end

  describe '#flags' do

    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#flags(target)').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#targets#flags("sample-binary")'
        expect(function_exists? 'cmake#targets#flags(target)').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'obtains flags for a known target' do
      flags = validate_response 'echo cmake#targets#flags("sample-library")'
      expect(flags).to_not be_empty

      flags.gsub! '\'', '"'
      flags = JSON.parse(flags)
      source_dir = vim.command('echo cmake#util#source_dir()').gsub(/\/$/,'')

      expected_c_flags = []
      expected_cpp_flags = [
        '-fPIC',
        "-I#{source_dir}",
        '-Dsample_library_EXPORTS',
      ].sort

      expect(flags['c'].sort).to eql(expected_c_flags)
      expect(flags['cpp'].sort).to eql(expected_cpp_flags)
    end

    it 'fails to obtains flags for a unknown target' do
      flags = validate_response 'echo cmake#targets#flags("sample-kid")'
      expect(flags).to_not be_empty

      flags.gsub! '\'', '"'
      flags = JSON.parse(flags)

      expected_c_flags = []
      expected_cpp_flags = []

      expect(flags['c']).to eql(expected_c_flags)
      expect(flags['cpp']).to eql(expected_cpp_flags)
    end
  end

  describe '#for_file' do
    it 'does not exist when not called' do
      expect(function_exists? 'cmake#targets#for_file(filepath)').to eql(false)
    end

    let(:plugin_cpp) { vim.command 'echo cmake#targets#for_file("plugin.cpp")' }
    let(:plugin_hpp) { vim.command 'echo cmake#targets#for_file("plugin.hpp")' }
    let(:just_plugin) { vim.command 'echo cmake#targets#for_file("plugin")' }
    let(:magic_file) { vim.command 'echo cmake#targets#for_file("foobar.main")' }

    it 'does exist when called' do
      output = validate_response 'echo cmake#targets#for_file("plugin.cpp")'
      expect(function_exists? 'cmake#targets#for_file(filepath)').to eql(true)
      expect(output).to_not be_empty
    end

    it 'does not match for non-existent files' do
      expect(magic_file).to be_empty
    end

    it 'matches for existing files with a known target' do
      expect(plugin_cpp).to eql('sample-library')
    end

    it 'partially matches with files with the same base name' do
      vim.command 'call cmake#targets#cache()'
      expect(plugin_hpp).to eql('sample-library')
      expect(just_plugin).to eql('sample-library')
    end

  end

  describe '#list' do

    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#list()').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#targets#list()'
        expect(function_exists? 'cmake#targets#list()').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'obtains a list of all known targets' do
      targets = validate_response('echo cmake#targets#list()').gsub '\'', '"'
      targets = JSON.parse(targets)
      expected_targets = ['sample-binary', 'sample-library']
      expect(targets).to_not be_empty
      expect(targets.sort).to eql(expected_targets)
    end
  end

  describe '#libraries' do
    let(:libs) { validate_json_response 'echo cmake#targets#libraries("sample-library")' }

    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#libraries(target)').to eql(false)
      end

      it 'does exist when called' do
        libs
        expect(function_exists? 'cmake#targets#libraries(target)').to eql(true)
      end
    end

    it 'obtains the libraries for a target' do
      expect(libs).to_not be_empty
      expect(libs).to include 'dl'
    end
  end

  describe '#include_dirs' do
    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#include_dirs(target)').to eql(false)
      end

      it 'does exist when called' do
        validate_response 'echo cmake#targets#include_dirs("sample-binary")'
        expect(function_exists? 'cmake#targets#include_dirs(target)').to eql(true)
      end
    end


    it 'obtains the include directories for a target' do
      include_dirs = validate_json_response('echo cmake#targets#include_dirs("sample-library")')
      expected_path = Dir.pwd

      expect(include_dirs).to_not be_empty
      expect(include_dirs).to include expected_path
    end
  end

  describe '#binary_dir' do
    context 'function existence' do
      it 'exists when called' do
        validate_response 'echo cmake#targets#binary_dir("sample-binary")'
        expect(function_exists? 'cmake#targets#binary_dir(target)').to eql(true)
      end

      it 'does not exists when not called' do
        expect(function_exists? 'cmake#targets#binary_dir(target)').to eql(false)
      end
    end

    it 'finds them for existing targets' do
      path = validate_response 'echo cmake#targets#binary_dir("sample-binary")'
      expect(path).to_not end_with '/'
      expect(path).to include 'build'
      expect(Dir.exists? path).to eql(true)
    end

    it 'does not find paths for non-existing targets' do
      path = vim.command 'echo cmake#targets#binary_dir("dirty_pig")'
      expect(Dir.exists? path).to eql(false)
    end

  end

  describe '#source_dir' do

    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#targets#source_dir(target)').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#targets#source_dir("sample-binary")'
        expect(function_exists? 'cmake#targets#source_dir(target)').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'finds them for existing targets' do
      path = vim.command 'echo cmake#targets#source_dir("sample-library")'
      bin_path = vim.command 'echo cmake#targets#binary_dir("sample-library")'
      expect(path).to_not include 'build'
      expect(path).to_not end_with '/'
      expect(path).to_not eql(bin_path)
      expect(Dir.exists? path).to eql(true)
    end

    it 'does not find them for non-existing targets' do
      path = vim.command 'echo cmake#targets#source_dir("dirty_pig")'
      expect(Dir.exists? path).to eql(false)
    end
  end
end
