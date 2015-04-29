require 'yaml'
module OrientdbSchemaMigrator
  class Configuration
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
    env =
      if defined?(Rails)
        Rails.env
      elsif ENV['ODB_TEST']
        'test'
      else
        raise "No environment specified to load database connection config"
      end

    CONFIG = YAML.load_file(config_file)[env]
    DB = CONFIG['db']
    USER = CONFIG['user']
    PASSWORD = CONFIG['password']
    STORAGE = CONFIG['storage']
    HOST = CONFIG['host']
  end
end