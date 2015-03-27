require "bundler/gem_tasks"

task :console do
  require 'pry'
  require 'orientdb_schema_migrator'
  ARGV.clear
  Pry.start
end

namespace :db do
  require 'orientdb_schema_migrator'
  db = ENV['odb_schema_test_db'] || 'schema_test'
  db_user = ENV['odb_schema_test_user'] || 'test'
  db_pass = ENV['odb_schema_test_pass'] || 'test'
  config = {
    database: db,
    user: db_user,
    password: db_pass
  }

  task :test_connection do
    if OrientdbSchemaMigrator::ODBClient.database_exists?(config)
      puts "Success! test database exists"
    else
      raise "Failure: database does not exist"
    end
  end
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
