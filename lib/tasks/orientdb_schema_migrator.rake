require 'yaml'

namespace :odb do
  task :config do
    if !ENV['ODB_TEST']
      migrations_path =
        if ENV['odb_migrations_path']
          migrations_path = ENV['odb_migrations_path']
        elsif defined?(Rails)
          Rails.root.to_s + '/db/orientdb/migrate'
        else
          raise "No migrations path defined"
        end

      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path
    end
  end

  def with_connection &block
    config_file =
      if defined?(Rails)
        Rails.root.to_s + '/config/orientdb.yml'
      elsif ENV['ODB_TEST']
        File.expand_path('../../../spec/support/config.yml', __FILE__)
      elsif ENV['odb_config_path']
        ENV['odb_config_path']
      else
        raise "No odb config path defined"
      end

    config = YAML.load_file(config_file)['test']
    OrientdbSchemaMigrator::Migrator.connect_to_db(config['db'], config['user'], config['password'])
    yield
    OrientdbSchemaMigrator::Migrator.disconnect
  end

  task :migrate => [:config] do
    with_connection do
      OrientdbSchemaMigrator::Migrator.migrate(ENV['schema_version'])
    end
  end

  task :rollback => [:config] do
    with_connection do
      OrientdbSchemaMigrator::Migrator.rollback(ENV['schema_version'])
    end
  end

  task :generate_migration => [:config] do
    OrientdbSchemaMigrator::MigrationGenerator.generate(ENV['migration_name'], OrientdbSchemaMigrator::Migrator.migrations_path)
  end
end
