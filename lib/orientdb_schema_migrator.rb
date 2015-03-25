gem "json","=1.7.5"
require "orientdb4r"
require "date"
require_relative "orientdb_schema_migrator/version"
require_relative "orientdb_schema_migrator/migration"
require_relative "orientdb_schema_migrator/migration_generator"
require_relative "orientdb_schema_migrator/migrator"
require_relative "orientdb_schema_migrator/proxy"

module OrientdbSchemaMigrator
  ODBClient = Orientdb4r.client
end
