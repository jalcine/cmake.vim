require 'spec_helper'

describe 'cmake.vim#augroup' do

  describe '#on_vim_enter' do

    xit 'adds the global commands'
    xit 'ensures that targets are added if a CMake project is available'
    xit 'caches all of the known targets'
    xit 'caches all of the files related to the known targets'

  end

  describe '#on_buf_read' do

    describe 'sets options for the specific buffer' do

      xit 'for a source file'
      xit 'for a header file'
      xit 'for a CMake source file under a target\'s source directory'

    end

    describe 'add commands for the specific buffer' do

      xit 'for a source file'
      xit 'for a header file'
      xit 'for a CMake source file under a target\'s source directory'

    end

  end

  describe '#on_buf_enter' do

    xit 'sets the makeprg variable for this buffer'
    xit 'sets the flags for this file\'s target'
    xit 'sets the ctags file for this file\'s target'
    xit 'sets the include paths for this file\'s target'

  end

  describe '#init' do

    xit 'loads #on_buf_read() on files that matches the regex *.*pp'
    xit 'loads #on_buf_enter() on files that matches the regex *.*pp'
    xit 'uses a augroup'

  end
end
