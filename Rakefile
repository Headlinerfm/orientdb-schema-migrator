require "bundler/gem_tasks"

task :console do
  require 'pry'
  require 'orientdb-schema-migrator'
  ARGV.clear
  Pry.start
end

db_namespace = namespace :db do
  require 'orientdb-schema-migrator'
  db = ENV['odb_schema_test_db'] || 'schema_test'
  db_user = ENV['odb_schema_test_user'] || 'test'
  db_pass = ENV['odb_schema_test_pass'] || 'test'
  config = {
    database: db,
    user: db_user,
    password: db_pass
  }

  task :connect do
    OrientdbSchemaMigrator.client.connect(:database => db, :user => db_user, :password => db_pass)
  end

  desc "Verify your orientdb test database setup"
  task :verify_test_db do
    if OrientdbSchemaMigrator.client.database_exists?(config)
      puts "Test database exists"
    else
      raise "Failure: database does not exist"
    end

    db_namespace['connect'].invoke
    if OrientdbSchemaMigrator::Migration.class_exists?('schema_versions')
      puts "`schema_versions` exists"
    else
      raise "Failure: `schema_versions` table does not exist"
    end

    puts "Success"
  end

  desc "Add the `schema_versions` class to your database"
  task :add_schema_class => [:connect] do
    OrientdbSchemaMigrator::Migration.create_class('schema_versions')
    OrientdbSchemaMigrator::Migration.add_property('schema_versions', 'schema_version', 'string')
  end
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end
