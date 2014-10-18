# vim: set ft=ruby tw=78 sts=2 ts=2 :

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'bin/rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
end

guard :spork, rspec_env: { 'RAILS_ENV' => 'test' } do
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
end
