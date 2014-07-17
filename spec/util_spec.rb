require 'spec_helper'

describe 'cmake.vim#util' do
  context 'directory lookup' do
    before(:each) do
      cmake.create_new_project
      cmake.configure_project
    end
    describe '#binary_dir' do

      it 'exists as a function' do
        expect(function_exists? 'cmake#util#binary_dir').to eql(true)
        expect(function_exists? 'cmake#util#binary_dir()').to eql(true)
      end

      it 'finds the binary directory' do
        potential_default_path = File.expand_path(vim.command('pwd') + '/build') + '/'
        obtained_path = validate_response('echo cmake#util#binary_dir()')
        expect(obtained_path).to eql(potential_default_path)
      end
    end

    describe '#source_dir' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#source_dir').to eql(true)
        expect(function_exists? 'cmake#util#source_dir()').to eql(true)
      end

      it 'can find the source directory' do
        potential_default_path = File.expand_path(vim.command('pwd')) + '/'
        obtained_path = validate_response('echo cmake#util#source_dir()')
        expect(obtained_path).to eql(potential_default_path)
      end
    end
  end

  context 'execution' do
    describe '#run_cmake' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#run_cmake').to eql(true)
        expect(function_exists? 'cmake#util#run_cmake(command, binary_dir, source_dir)').to eql(true)
      end
    end

    describe '#run_make' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#run_make').to eql(true)
        expect(function_exists? 'cmake#util#run_make(command)').to eql(true)
      end
    end

    describe '#shell_bgexec' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#shell_bgexec').to eql(true)
        expect(function_exists? 'cmake#util#shell_bgexec(command)').to eql(true)
      end
    end

    describe '#shell_exec' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#shell_exec').to eql(true)
        expect(function_exists? 'cmake#util#shell_exec(command)').to eql(true)
      end
    end
  end

  context 'raw utilities' do
    describe '#echo_msg' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#echo_msg').to eql(true)
        expect(function_exists? 'cmake#util#echo_msg(msg)').to eql(true)
      end

      it 'outputs messages to :messages' do
        payload = Faker::Internet.user_name
        msg = validate_response("echo cmake#util#echo_msg('#{payload}')")
        expect(msg).to start_with(msg)
      end
    end

    describe '#has_project' do
      it 'exists as a function' do
        expect(function_exists? 'cmake#util#has_project').to eql(true)
        expect(function_exists? 'cmake#util#has_project()').to eql(true)
      end

      describe 'determining whether or not this is a CMake powered project' do
        context 'with a created project' do
          before(:each) { cmake.create_new_project }
          after(:each)  { cmake.destroy_project }

          it 'cant find projects that havent been configured yet' do
            result = validate_response('echo cmake#util#has_project()')
            expect(result).to eql('0')
          end

          it 'finds projects that have been configured once' do
            cmake.configure_project
            result = validate_response('echo cmake#util#has_project()')
            expect(result).to eql('1')
          end
        end

        context 'without a created project' do
          it 'cant find projects that havent been created yet' do
            result = validate_response('echo cmake#util#has_project()')
            expect(result).to eql('0')
          end
        end
      end
    end
  end
end
