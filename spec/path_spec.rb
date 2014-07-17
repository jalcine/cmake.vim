require 'spec_helper'

describe 'cmake.vim#path' do
  before(:each) do
    cmake.create_new
    cmake.configure
    vim.edit 'binary_main.cpp'
  end

  context 'refreshing' do
    it 'has the wrapping refresh() function' do
      expect(function_exists? 'cmake#path#refresh').to eql(true)
      expect(function_exists? 'cmake#path#refresh()').to eql(true)
    end

    describe '#refresh_global_paths' do
      let(:paths) { validate_json_response 'echo split(&l:paths, ",")' }
      let(:binary_dir) { validate_response 'echo cmake#util#binary_dir()'}
      let(:source_dir) { validate_response 'echo cmake#util#source_dir()'}

      it 'exists as a function' do
        expect(function_exists? 'cmake#path#refresh_global_paths').to eql(true)
        expect(function_exists? 'cmake#path#refresh_global_paths()').to eql(true)
      end

      it 'adds the root binary directory for CMake to "path"' do
        expect(binary_dir).to_not be_empty
        expect(paths).to include(binary_dir)
      end

      it 'adds the root source directory for CMake to "path"' do
        expect(source_dir).to_not be_empty
        expect(paths).to include(source_dir)
      end
    end

    describe '#refresh_target_paths' do
      let(:paths) { validate_json_response 'echo split(&l:paths, ",")' }
      let(:binary_dir) { validate_response 'echo cmake#targets#for_file("binary_main.cpp")'}
      let(:source_dir) { validate_response 'echo cmake#targets#for_file("binary_main.cpp")'}

      it 'exists as a function' do
        expect(function_exists? 'cmake#path#refresh_global_paths').to eql(true)
        expect(function_exists? 'cmake#path#refresh_global_paths()').to eql(true)
      end

      it 'adds the root binary directory for CMake to "path"' do
        expect(binary_dir).to_not be_empty
        expect(paths).to include(binary_dir)
      end

      it 'adds the root source directory for CMake to "path"' do
        expect(source_dir).to_not be_empty
        expect(paths).to include(source_dir)
      end
    end

    describe '#reset_path' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#path#refresh_path').to eql(true)
        expect(function_exists? 'cmake#path#refresh_path()').to eql(true)
      end

      it 'flushes out to default with no g:cmake_old_path' do
        vim.command 'let g:cmake_old_path=""'
        vim.command 'call cmake#path#reset_path()'
        paths = validate_response('echo &l:path').gsub ','
        expect(paths).to include '/usr/include'
      end

      it 'sets itself to g:cmake_old_path' do
        vim.command 'let g:cmake_old_path="foo,bar,baz"'
        vim.command 'call cmake#path#reset_path()'
        paths = validate_response('echo &l:path').gsub ','
        expect(paths).to include 'foo'
      end
    end
  end

  describe '#update' do
    it 'exists as a function' do
      expect(function_exists? 'cmake#path#update').to eql(true)
      expect(function_exists? 'cmake#path#update(paths)').to eql(true)
    end
  end
end
