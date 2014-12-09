require 'spec_helper'

describe 'cmake.vim#ctags' do
  before(:each) do
    cmake.create_new
    cmake.configure
    vim.edit 'binary_main.cpp'
  end

  describe '#cache_directory' do
    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#ctags#cache_directory()').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#ctags#cache_directory()'
        expect(function_exists? 'cmake#ctags#cache_directory()').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'lives within the root binary directory' do
      result = validate_response 'echo cmake#ctags#cache_directory()'
      binary_dir = validate_response 'echo cmake#util#binary_dir()'
      expect(result).to_not be_empty
      expect(result).to include(binary_dir)
    end
  end

  describe '#filename' do
    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#ctags#filename(target)').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#ctags#filename("cookie")'
        expect(function_exists? 'cmake#ctags#filename(target)').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'has the target in its basename' do
      path = validate_response 'echo cmake#ctags#filename("sample-binary")'
      expect(path).to end_with('sample-binary.tags')
    end

    it 'leads with the cache directory' do
      cache_dir = validate_response 'echo cmake#ctags#cache_directory()'
      path = validate_response 'echo cmake#ctags#filename("sample-binary")'
      expect(path).to start_with(cache_dir)
    end
  end

  describe '#generate_for_target' do
    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#ctags#generate_for_target(target)').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#ctags#generate_for_target("cookie")'
        expect(function_exists? 'cmake#ctags#generate_for_target(target)').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'populates the cache with the generated ctags filepath' do
      vim.command 'call cmake#ctags#generate_for_target("sample-binary")'
      cache_dir = validate_response 'echo cmake#ctags#cache_directory()'
      path = validate_response 'echo g:cmake_cache.targets["sample-binary"].tags_file'
      expect(path).to end_with('sample-binary.tags')
      expect(path).to start_with(cache_dir)
      expect(File.exists? path).to eql(true)
    end
  end

  describe '#paths_for_target' do
    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#ctags#paths_for_target(target)').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#ctags#paths_for_target("cookie")'
        expect(function_exists? 'cmake#ctags#paths_for_target(target)').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'includes the current target as a tag file' do
      result = validate_json_response 'echo cmake#ctags#paths_for_target("sample-binary")'
      expect(result).to include(/sample-binary/)
    end
  end

  describe '#refresh' do
    context 'function existence' do
      it 'does not exist when not called' do
        expect(function_exists? 'cmake#ctags#refresh()').to eql(false)
      end

      it 'does exist when called' do
        output = validate_response 'echo cmake#ctags#refresh()'
        expect(function_exists? 'cmake#ctags#refresh()').to eql(true)
        expect(output).to_not be_empty
      end
    end

    it 'populates the local "tags" option' do
      vim.command 'call cmake#ctags#refresh()'
      tag_paths = validate_json_response 'echo split(&tags,",")'
      expect(tag_paths).to include(/sample-binary/)
    end
  end

end
