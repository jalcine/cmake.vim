require 'spec_helper'

describe 'cmake.vim#util' do
  context 'directory lookup' do
    before(:each) do
      cmake.create_new_project
      cmake.configure_project
    end

    describe '#binary_dir' do
      it 'finds the binary directory' do
        potential_default_path = File.expand_path(vim.command('pwd') + '/build')
        obtained_path = validate_response('echo cmake#util#binary_dir()')

        expect(obtained_path).to eql(potential_default_path)
      end
    end

    describe '#source_dir' do
      it 'can find the source directory' do
        expected_source_dir = File.expand_path(vim.command('pwd'))
        obtained_source_dir = validate_response 'echo cmake#util#source_dir()'

        expect(obtained_source_dir).to eql(expected_source_dir)
      end
    end
  end

  context 'execution' do
    describe '#run_cmake'
    describe '#run_make'
    describe '#shell_bgexec'
    describe '#shell_exec'
  end

  context 'raw utilities' do
    describe '#echo_msg' do
      it 'outputs messages to :messages' do
        payload = Faker::Internet.user_name
        msg = validate_response("echo cmake#util#echo_msg('#{payload}')")
        expect(msg).to start_with(msg)
      end
    end

    describe '#has_project' do
      context 'with a created project' do
        before(:each) { cmake.create_new_project }
        after(:each)  { cmake.destroy_project }

        it 'cannot find projects that have not been configured yet' do
          result = validate_response('echo cmake#util#has_project()')
          expect(result).to eql('0')
        end

        it 'finds projects that have been configured once' do
          cmake.configure_project
          result = validate_response('echo cmake#util#has_project()')
          expect(result.to_i).to eql(1)
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
