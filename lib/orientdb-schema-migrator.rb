require "orientdb4r"

require "orientdb_schema_migrator/version"
require "orientdb_schema_migrator/migration"
require "orientdb_schema_migrator/migration_generator"
require "orientdb_schema_migrator/migrator"
require "orientdb_schema_migrator/proxy"

require "orientdb_schema_migrator/railtie" if defined?(Rails)

module OrientdbSchemaMigrator
  ODBClient = Orientdb4r.client
end