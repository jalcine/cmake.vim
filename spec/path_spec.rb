require 'spec_helper'

describe 'cmake.vim#path' do
  before(:each) do
    cmake.create_new
    cmake.configure
    vim.edit 'binary_main.cpp'
  end

  let(:vim_paths)  { validate_json_response 'echo split(&l:path,",")' }
  let(:binary_dir) { validate_response 'echo cmake#util#binary_dir()' }
  let(:source_dir) { validate_response 'echo cmake#util#source_dir()' }

  describe '#reset' do
    it 'flushes out to default with no g:cmake_old_path' do
      vim.command 'let g:cmake_old_path=""'
      vim.command 'call cmake#path#reset()'

      expect(vim_paths).to include '/usr/include'
      expect(vim_paths).to include '/usr/local/include'
    end

    it 'sets itself to g:cmake_old_path' do
      extra_paths = [ '/usr/local/include/', '/usr/include/' ]
      vim.command "let g:cmake_old_path='#{extra_paths.join(',')}'"
      vim.command 'call cmake#path#reset()'
      expect(vim_paths).to_not be_empty
      expect(extra_paths).to eql(vim_paths)
    end
  end

  describe '#refresh_global_paths' do
    before(:each) do
      vim.command 'call cmake#path#refresh_global_paths()'
    end

    it 'adds the root binary directory for CMake to "path"' do
      expect(binary_dir).to_not be_empty
      expect(vim_paths).to include(binary_dir)
    end

    it 'adds the root source directory for CMake to "path"' do
      expect(vim_paths).to include(source_dir)
      expect(source_dir).to_not be_empty
    end
  end

  describe '#refresh_target_paths' do
    it 'adds the target-specific binary directory for CMake to "path"' do
      expect(binary_dir).to_not be_empty
      expect(vim_paths).to include(binary_dir)
    end

    it 'adds the target-specific source directory for CMake to "path"' do
      expect(source_dir).to_not be_empty
      expect(vim_paths).to include(source_dir)
    end

  end

  describe '#update' do
    it 'sets the path to the buffer-local path variable' do
      new_paths = [ Dir.mktmpdir, Dir.mktmpdir, Dir.mktmpdir ]
      vim.command "call cmake#path#update(#{new_paths.to_json})"
      new_paths.each { | new_path | expect(vim_paths).to include(new_path) }
    end

    it 'sets old paths stored in "g:cmake_old_path"' do
      cmake_old_paths = validate_json_response 'echo split(g:cmake_old_path, ",")'
      cmake_old_paths.uniq!
      cmake_old_paths.each { | a_path | expect(vim_paths).to include(a_path) unless a_path.empty? }
    end

    it 'ensures that the path list is composed only of unique paths' do
      unique_vim_paths = vim_paths.uniq
      expect(vim_paths).to eql(unique_vim_paths)
    end
  end
end
