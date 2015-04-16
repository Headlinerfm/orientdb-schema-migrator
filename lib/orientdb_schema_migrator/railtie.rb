require 'orientdb-schema-migrator'
require 'rails'

module OrientdbSchemaMigrator
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/orientdb_schema_migrator.rake'
    end
  end
end
