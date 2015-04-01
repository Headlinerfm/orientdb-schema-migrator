require 'spec_helper'

describe 'integration specs' do
  def schema_versions
    OrientdbSchemaMigrator::ODBClient.command("SELECT * from schema_versions")['result']
  end

  describe 'passing migrations' do
    before(:all) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/passing_series'
    end

    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'creates then removes the class, properties, index' do
      OrientdbSchemaMigrator::Migrator.migrate
      expect(class_exists?('users')).to be true
      expect(property_exists?('users', 'age')).to be true
      expect(property_exists?('users', 'name')).to be true
      expect(index_exists?('users', 'user_age_idx')).to be true
      expect(schema_versions.size).to eql(2)
      OrientdbSchemaMigrator::Migrator.rollback
      expect(index_exists?('users', 'user_age_idx')).to be false
      expect(class_exists?('users')).to be true
      expect(schema_versions.size).to eql(1)
      OrientdbSchemaMigrator::Migrator.rollback
      expect(class_exists?('users')).to be false
      expect(schema_versions.size).to eql(0)
    end
  end

  describe 'name conflict' do
    before(:all) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/name_conflict'
    end

    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'fails and does not make any entries in the schema table' do
      expect { OrientdbSchemaMigrator::Migrator.migrate }.to raise_exception(OrientdbSchemaMigrator::MigratorConflictError)
      expect(schema_versions.size).to eql(0)
    end
  end

  describe 'version conflict' do
    before(:all) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/version_conflict'
    end

    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'fails and does not make any entries in the schema table' do
      expect { OrientdbSchemaMigrator::Migrator.migrate }.to raise_exception(OrientdbSchemaMigrator::MigratorConflictError)
      expect(schema_versions.size).to eql(0)
    end
  end
end
