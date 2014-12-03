# vim: set ft=ruby tw=78 sts=2 ts=2 :

guard :bundler do
  watch('Gemfile')
end

guard :rspec, cmd: 'bin/rspec', all_on_start: false, all_after_pass: false, failed_mode: :keep do
  watch('.rspec')
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')
  watch(%r{^autoload/cmake/(\w+)\.vim$}) { | m | "spec/#{m[1]}_spec.rb" }
end
