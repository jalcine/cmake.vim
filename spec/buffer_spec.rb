# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'

describe 'cmake.vim#buffer' do
  describe '#set_options' do
    xit 'adds binary directory for current file\'s target'
    xit 'adds source directory for current file\'s target'
    xit 'adds include directories for current file\'s target'
    xit 'adds libraries for current file\'s target'
  end

  describe '#set_makeprg' do
    xit 'sets the makeprg for this current buffer'
  end

  describe '#has_project' do
    xit 'confirms the existence of a project within a buffer'
  end
end
