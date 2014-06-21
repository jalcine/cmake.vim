require 'spec_helper'

describe 'cmake.vim#variables' do
  before(:each) { vim.edit 'plugin.cpp' }

  describe '#exists' do
    it 'exists as a function' do
      expect(vim.command('function')).to contain('function cmake#variables#exist')
      expect(vim.command('function')).to contain('function cmake#variables#exist(variable)')
    end

    it 'determines the existence of a present variable' do
      variable_value = vim.command('call cmake#variables#exists("CMAKE_CXX_COMPILER")')
      variable_json  = JSON.parse(variable_value)
      expect(variable_json).to eql(0)
    end

    it 'determines the non-existence of a non-present variable' do
      variable_value = vim.command('call cmake#variables#exists("CMAKE_JACKY_COMPILER")')
      variable_json  = JSON.parse(variable_value)
      expect(variable_json).to eql(0)
    end
  end

  describe '#get' do
    it 'exists as a function' do
      expect(vim.command('function')).to contain('function cmake#variables#get')
      expect(vim.command('function')).to contain('function cmake#variables#get(variable)')
    end

    it 'gets the value of a known variable' do
      variable_value = vim.command('call cmake#variables#get("CMAKE_COLOR_MAKEFILE")')
      expect(variable_value).to eql('OFF')
    end

    it 'gets the value of an unknown variable' do
      variable_value = vim.command('call cmake#variables#get("CMAKE_JAZZY_MAKEFILE")')
      expect(variable_value).to_not eql('OFF')
      expect(variable_value).to be_a Integer
      expect(variable_value).to eql(0)
    end
  end

  describe '#set' do
    it 'exists as a function' do
      expect(vim.command('function')).to contain('function cmake#variables#get')
      expect(vim.command('function')).to
        contain('function cmake#variables#get(variableName, variableValue)')
    end

    it 'sets the value of a known variable' do
      result = vim.command('call cmake#variables#set("CMAKE_COLOR_MAKEFILE", ON)')
      expect(result).to be_empty
      variable_value = vim.command('call cmake#variables#get("CMAKE_COLOR_MAKEFILE",ON)')
      expect(variable_value).to_not be_a Integer
      expect(variable_value).to eql('ON')
      vim.command('call cmake#variables#get("CMAKE_COLOR_MAKEFILE",OFF)')
    end

    it 'fails to set the value of an unknown variable' do
      result = vim.command('call cmake#variables#set("CMAKE_JAZZY_MAKEFILE", 3)')
      expect(result).to be_a Integer
      expect(result).to eql(0)
    end

  end
end
