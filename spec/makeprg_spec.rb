# vim: set tw=78 sts=2 ts=2 sw=2
require 'spec_helper'
require 'json'

describe 'cmake.vim#makeprg' do
  before(:each) do
    cmake.create_new_project
  end

  let(:target) { validate_response 'echo cmake#targets#for_file("plugin.cpp")' }
  let(:binary_dir) { validate_response "echo cmake#targets#binary_dir('sample-library')" }
  let(:root_binary_dir) { validate_response 'echo cmake#util#binary_dir()' }

  pairs = {
    gnumake: {
      command: 'make -C {{target_build_directory}} {{target}}',
      generator: 'Unix Makefiles'
    },
    ninja: {
      command: 'ninja -C {{root_build_directory}} {{target}}',
      generator: 'Ninja'
    }
  }

  pairs.each do | toolchain, options |
    context "for #{toolchain}" do
      let(:command) { options[:command] }
      let(:generator) { options[:generator] }

      before(:each) do
        cmake.configure_project({
          options: [ "-G '#{generator}'"]
        })
        vim.command "let g:cmake_build_toolchain='#{toolchain}'"
        vim.command 'let &l:makeprg=""'
        vim.edit 'plugin.cpp'
      end

      let(:expected_command) do
        command.gsub('{{target_build_directory}}', binary_dir)
               .gsub('{{root_build_directory}}', root_binary_dir)
               .gsub('{{target}}', target)
      end

      describe '#for_target' do
        it "generates a command string for using in 'makeprg'" do
          obtained_command = validate_response "echo cmake#makeprg#for_target('#{target}')"
          expect(obtained_command).to eql(expected_command)
        end

        it 'generates nothing for non-existing targets' do
          obtained_command = vim.command "echo cmake#makeprg#for_target('sample-foo')"
          expect(obtained_command).to be_empty
        end
      end

      describe '#set_for_buffer' do
        it "sets the 'makeprg' to the buffer" do
          vim.command 'call cmake#makeprg#set_for_buffer()'
          makeprg = validate_response 'echo &l:makeprg'
          expect(makeprg).to eql(expected_command)
        end

        it 'empties out the makeprg for buffers with no corresponding target' do
          vim.edit 'foobar.cpp'
          vim.command 'call cmake#makeprg#set_for_buffer()'
          makeprg = vim.command 'echo &l:makeprg'
          expect(makeprg).to be_empty
        end

        it 'empties out the makeprg for buffers outside of the project' do
          vim.command 'cd $VIMRUNTIME' 
          path = Dir.glob("#{vim.command 'echo getcwd()'}/**.vim")[0]
          vim.edit path
          vim.command 'call cmake#makeprg#set_for_buffer()'
          makeprg = vim.command 'echo &l:makeprg'
          expect(makeprg).to be_empty
        end
      end
    end
  end
end
