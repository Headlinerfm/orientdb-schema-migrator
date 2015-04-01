require 'spec_helper'

describe 'migration specs' do
  def schema_versions
    OrientdbSchemaMigrator::ODBClient.command("SELECT * from schema_versions")['result']
  end

  def cleanup!(classes)
    classes.each { |class_name| OrientdbSchemaMigrator::Migration.drop_class(class_name) }
    OrientdbSchemaMigrator::ODBClient.command "truncate class schema_versions"
  end

  describe 'simple class addition/removal' do
    before(:each) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'creates then removes the class' do
      OrientdbSchemaMigrator::Migrator.new(nil, '201503290123456', :up).migrate
      expect(class_exists?('users')).to be true
      OrientdbSchemaMigrator::Migrator.rollback
      expect(class_exists?('users')).to be false
    end
  end

  describe 'class addition/removal with properties' do
    before(:each) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'creates then removes the class' do
      OrientdbSchemaMigrator::Migrator.new('201503290123457', '201503290123457', :up).migrate
      expect(class_exists?('users')).to be true
      expect(property_exists?('users', 'age')).to be true
      expect(property_exists?('users', 'name')).to be true
      OrientdbSchemaMigrator::Migrator.rollback
      expect(class_exists?('users')).to be false
    end
  end

  describe 'multiple migrations with class and index' do
    before(:each) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
      OrientdbSchemaMigrator::Migration.drop_index('user_age_idx')
    end

    it 'creates class and index' do
      OrientdbSchemaMigrator::Migrator.new('201503290123457', '201503290123458', :up).migrate
      expect(property_exists?('users', 'age')).to be true
      expect(index_exists?('users', 'user_age_idx')).to be true
      OrientdbSchemaMigrator::Migrator.run(:down, '201503290123457')
      expect(index_exists?('users', 'user_age_idx')).to be false
    end
  end

  describe "integration specs", :integration do
    describe 'passing migrations' do
      before(:each) do
        OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/passing_series'
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
      before(:each) do
        OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/name_conflict'
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
      before(:each) do
        OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/version_conflict'
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
end
