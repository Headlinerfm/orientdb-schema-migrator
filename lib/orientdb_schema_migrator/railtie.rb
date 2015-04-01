require 'orientdb_schema_migrator'
require 'rails'

module OrientdbSchemaMigrator
  class Railtie < Rails::Railtie
    rake_tasks do
      require 'tasks/orientdb_schema_migrator.rake'
    end
  end
end
