# Tests
namespace :test do
  desc 'Test Foreman Team Dynamix'
  Rake::TestTask.new(:foreman_teamdynamix) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :foreman_teamdynamix do
  task rubocop: :environment do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_foreman_teamdynamix) do |task|
        task.patterns = ["#{ForemanTeamdynamix::Engine.root}/app/**/*.rb",
                         "#{ForemanTeamdynamix::Engine.root}/lib/**/*.rb",
                         "#{ForemanTeamdynamix::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError => e
      puts "Rubocop not loaded #{e.message}"
    end

    Rake::Task['rubocop_foreman_teamdynamix'].invoke
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:foreman_custom_tab'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance do
    Rake::Task['test:foreman_custom_tab'].invoke
    Rake::Task['foreman_custom_tab:rubocop'].invoke
  end
end
