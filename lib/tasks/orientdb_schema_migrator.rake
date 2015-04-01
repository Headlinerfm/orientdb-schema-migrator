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

  task :migrate => [:config] do
    OrientdbSchemaMigrator::Migrator.migrate(ENV['schema_version'])
  end

  task :rollback => [:config] do
    OrientdbSchemaMigrator::Migrator.rollback
  end

  task :generate_migration => [:config] do
    OrientdbSchemaMigrator::MigrationGenerator.generate(ENV['migration_name'], OrientdbSchemaMigrator::Migrator.migrations_path)
  end
end
