require 'spec_helper'
require 'support/shared_contexts/rake'

describe 'odb:migrate', :integration do
  include_context 'rake'
  let(:task_path) { 'lib/tasks/orientdb_schema_migrator' }
  subject { rake['odb:migrate'] }

  context 'with passing migrations' do
    before(:all) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/passing_series'
    end

    before(:each) do
      with_test_db_connection do
        cleanup!(['users'])
      end
    end

    after(:each) do
      with_test_db_connection do
        cleanup!(['users'])
      end
    end

    it 'creates then removes the class, properties, index' do
      subject.invoke
      with_test_db_connection do
        expect(class_exists?('users')).to be true
        expect(property_exists?('users', 'age')).to be true
        expect(property_exists?('users', 'name')).to be true
        expect(index_exists?('users', 'user_age_idx')).to be true
      end
    end

    context 'with specific version targeted' do
      it 'only migrates to that version' do
        ClimateControl.modify(schema_version: '201503290123456') do
          subject.invoke
        end
        with_test_db_connection do
          expect(class_exists?('users')).to be true
          expect(property_exists?('users', 'age')).to be true
          expect(property_exists?('users', 'name')).to be true
          expect(index_exists?('users', 'user_age_idx')).to be false
        end
      end
    end
  end
end

describe 'odb:rollback', :integration do
  include_context 'rake'
  let(:task_path) { 'lib/tasks/orientdb_schema_migrator' }

  around do |example|
    ClimateControl.modify(ODB_TEST: 'true') do
      example.run
    end
  end

  context 'with passing migrations' do
    before(:each) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/passing_series'
    end

    before(:each) do
      with_test_db_connection do
        cleanup!(['users'])
      end
    end

    after(:each) do
      with_test_db_connection do
        cleanup!(['users'])
      end
    end

    it 'creates then removes the index' do
      rake['odb:migrate'].invoke
      rake['odb:rollback'].invoke
      with_test_db_connection do
        expect(index_exists?('users', 'user_age_idx')).to be false
      end
    end
  end
end

describe 'odb:generate_migration' do
  include_context 'rake'
  let(:task_path) { 'lib/tasks/orientdb_schema_migrator' }

  around do |example|
    ClimateControl.modify(ODB_TEST: 'true') do
      example.run
    end
  end

  before(:each) do
    OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path
  end

  context 'with valid name' do
    it 'writes the migration template to a file' do
      ClimateControl.modify(migration_name: 'FooBar') do
        expect(File).to receive(:open).with(match(/[0-9]{14}_foo_bar/), 'w', 0644)
        rake['odb:generate_migration'].invoke
      end
    end
  end
end
