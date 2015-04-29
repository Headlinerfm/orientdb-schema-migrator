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
    config = OrientdbSchemaMigrator.get_config
    OrientdbSchemaMigrator::Migrator.connect_to_db(config['db'], config['user'], config['password'])
    begin
      yield
    ensure
      OrientdbSchemaMigrator::Migrator.disconnect
    end
  end

  desc "Migrate"
  task :migrate => [:config] do
    with_connection do
      OrientdbSchemaMigrator::Migrator.migrate(ENV['schema_version'])
    end
  end

  desc "Rollback one migration"
  task :rollback => [:config] do
    with_connection do
      OrientdbSchemaMigrator::Migrator.rollback(ENV['schema_version'])
    end
  end

  desc "Generate a new migration"
  task :generate_migration => [:config] do
    OrientdbSchemaMigrator::MigrationGenerator.generate(ENV['migration_name'], OrientdbSchemaMigrator::Migrator.migrations_path)
  end
end
