require "orientdb4r"
require "yaml"
require "orientdb_schema_migrator/version"
require "orientdb_schema_migrator/migration"
require "orientdb_schema_migrator/migration_generator"
require "orientdb_schema_migrator/migrator"
require "orientdb_schema_migrator/proxy"

require "orientdb_schema_migrator/railtie" if defined?(Rails)

module OrientdbSchemaMigrator
  def self.get_config
    config_file =
      if defined?(Rails)
        Rails.root.to_s + '/config/orientdb.yml'
      elsif ENV['ODB_TEST']
        File.expand_path('../../spec/support/config.yml', __FILE__)
      elsif ENV['odb_config_path']
        ENV['odb_config_path']
      else
        raise "No odb config path defined"
      end
    env =
      if defined?(Rails)
        Rails.env
      elsif ENV['ODB_TEST']
        'test'
      else
        raise "No environment specified to load database connection config"
      end
    YAML.load_file(config_file)[env]
  end

  @client = nil
  def self.client
    @client ||= Orientdb4r.client(:host => get_config["host"])
  end
end
