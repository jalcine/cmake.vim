require 'spec_helper'

describe 'cmake.vim#flags' do
  build_systems = {
    gnumake: {
      generator: 'Unix\ Makefiles'
    },
    ninja: {
      generator: 'Ninja'
    }
  }
  build_systems.each { | ext, opts |
    context "when using a #{ext} build system" do

      before(:each) do
        vim.command 'au! cmake.vim'
        cmake.create_new_project
        cmake.configure_project
        vim.edit 'plugin.cpp'
        vim.command 'call cmake#targets#cache()'
      end

      describe '#collect_for_target' do

        context 'function existence' do
          it 'does not exist when not called' do
            expect(function_exists? 'cmake#flags#collect_for_target(target)').to eql(false)
          end

          it 'does exist when called' do
            output = validate_response 'echo cmake#flags#collect_for_target("sample-binary")'
            expect(function_exists? 'cmake#flags#collect_for_target(target)').to eql(true)
            expect(output).to_not be_empty
          end
        end

        it 'obtains flags for the provided flag file' do
          flags = validate_json_response('echo cmake#flags#collect_for_target("sample-library")')
          expect(flags).to_not be_empty
          expect(flags).to include '-fPIC'
        end

        it 'does not obtain flags for non-existing projects' do
          flags = validate_json_response('echo cmake#flags#collect_for_target("sample-foobar-library")')
          expect(flags).to be_empty
        end
      end

      describe '#filter' do

        context 'function existence' do
          it 'does not exist when not called' do
            expect(function_exists? 'cmake#flags#filter(flags)').to eql(false)
          end

          it 'does exist when called' do
            output = validate_response 'echo cmake#flags#filter([])'
            expect(function_exists? 'cmake#flags#filter(flags)').to eql(true)
            expect(output).to_not be_empty
          end
        end

        it 'removes uninteresting flags' do
          res = validate_json_response 'echo cmake#flags#filter(["-magic"])'
          expect(res).to be_empty
        end

        flags = [
          '-I/usr/include',
          '-i/usr/src',
          '-Wall',
          '-fPIC',
        ]

        flags.each do | permitted_flag |
          it "permits flags like #{permitted_flag}" do
            command = 'echo cmake#flags#filter(["'+permitted_flag+'"])'
            res = validate_response(command)
            res.gsub! '\'', '"'
            res = JSON.parse(res)
            expect(res).to eql([permitted_flag])
          end
        end
      end

      describe '#inject' do

        context 'function existence' do
          it 'does not exist when not called' do
            expect(function_exists? 'cmake#flags#inject()').to eql(false)
          end

          it 'does exist when called' do
            vim.command 'call cmake#buffer#set_options()'
            output = vim.command 'call cmake#flags#inject()'
            expect(function_exists? 'cmake#flags#inject()').to eql(true)
            expect(output).to be_empty
          end
        end

        it 'adds flags to buffers with targets' do
          vim.command 'call cmake#buffer#set_options()'
          vim.command 'call cmake#flags#inject()'
          flags = validate_json_response 'echo b:cmake_flags'
          expect(flags).to_not be_empty
        end

        it 'does not add flags to buffers without a target' do
          vim.edit 'foobarzilla_test.cpp'
          vim.command 'call cmake#buffer#set_options()'
          vim.command 'call cmake#flags#inject()'
          flags = vim.command 'echo b:cmake_flags'
          expect(flags).to match(/Undefined variable/)
        end
      end
    end
  }
end
