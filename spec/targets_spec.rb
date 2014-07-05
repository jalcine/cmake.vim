require 'spec_helper'

describe 'cmake#targets' do
  before(:each) do
    cmake.create_new_project
    cmake.configure_project
    add_plugin_to_vim 'autoload/cmake/targets'
  end

  describe '#binary_dir' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#targets#binary_dir').to eql(true)
      expect(function_exists? 'cmake#targets#binary_dir(target)').to eql(true)
    end

    it 'finds them for existing targets' do
      path = validate_response 'echo cmake#targets#binary_dir("sample-binary")'
      expect(Dir.exists? path).to eql(true)
    end

    it 'doesnt find them for non-existing targets' do
      path = vim.command 'echo cmake#targets#binary_dir("dirty_pig")'
      expect(Dir.exists? path).to eql(false)
    end

  end

  describe '#build' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#targets#build').to eql(true)
      expect(function_exists? 'cmake#targets#build(target)').to eql(true)
    end

    # TODO How do we confirm said output?
    xit 'builds the specified target'
  end

  describe '#exists' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#targets#exists').to eql(true)
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

    it 'exists as a function' do
      expect(function_exists? 'cmake#targets#files').to eql(true)
      expect(function_exists? 'cmake#targets#files(target)').to eql(true)
    end

    it 'procures the files for a known target' do
      file_list = JSON.parse(files.gsub '\'', '"')
      expect(file_list).to_not be_empty
      expect(file_list[0]).to end_with 'plugin.cpp'
    end

    it 'procures nothing for a non-existing target' do
      file_list = JSON.parse(bad_files.gsub '\'', '"')
      expect(file_list).to be_empty
    end
  end

  describe '#flags' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#targets#flags').to eql(true)
      expect(function_exists? 'cmake#targets#flags(target)').to eql(true)
    end

    it 'obtains flags for a known target' do
      flags = validate_response 'echo cmake#targets#flags("sample-library")'
      expect(flags).to_not be_empty

      flags.gsub! '\'', '"'
      flags = JSON.parse(flags)

      expect(flags['c']).to eql([])
      expect(flags['cpp']).to eql(['-fPIC', '-Dsample_library_EXPORTS'])
    end

    it 'obtains flags for a unknown target' do
      flags = validate_response 'echo cmake#targets#flags("sample-kid")'
      expect(flags).to_not be_empty

      flags.gsub! '\'', '"'
      flags = JSON.parse(flags)

      expect(flags['c']).to eql([])
      expect(flags['cpp']).to eql([])
    end
  end

  describe '#for_file' do
    let(:plugin_cpp) { validate_response 'echo cmake#targets#for_file("plugin.cpp")' }
    let(:plugin_hpp) { validate_response 'echo cmake#targets#for_file("plugin.hpp")' }
    let(:just_plugin) { validate_response 'echo cmake#targets#for_file("plugin")' }
    let(:magic_file) { validate_response 'echo cmake#targets#for_file("foobar.main")' }

    it 'exists as a function' do
      expect(function_exists? 'cmake#targets#for_file').to eql(true)
      expect(function_exists? 'cmake#targets#for_file(filepath)').to eql(true)
    end

    it 'doesnt match for non-existent files' do
      expect(magic_file).to eql('0')
    end

    it 'matches for existing files with a known target' do
      expect(plugin_cpp).to eql('sample-library')
    end

    it 'partially matches with files with the same base name' do
      expect(plugin_hpp).to eql('sample-library')
      expect(just_plugin).to eql('sample-library')
    end

  end
  describe '#include_dirs' do
    xit 'exists as a function'
  end
  describe '#libraries' do
    xit 'exists as a function'
  end
  describe '#list' do
    xit 'exists as a function'
  end
  describe '#source_dir' do
    xit 'exists as a function'
  end
end
