require 'spec_helper'
require 'support/shared_contexts/rake'

describe 'odb:migrate' do
  include_context 'rake'
  let(:task_path) { 'lib/tasks/orientdb_schema_migrator' }
  subject { rake['odb:migrate'] }

  around do |example|
    ClimateControl.modify(ODB_TEST: 'true') do
      example.run
    end
  end

  context 'with passing migrations' do
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
      subject.invoke
      expect(OrientdbSchemaMigrator::Migration.class_exists?('users')).to be true
      expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'age')).to be true
      expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'name')).to be true
      expect(OrientdbSchemaMigrator::Migration.index_exists?('users', 'user_age_idx')).to be true
    end

    context 'with specific version targeted' do
      it 'only migrates to that version' do
        ClimateControl.modify(schema_version: '201503290123456') do
          subject.invoke
        end
        expect(OrientdbSchemaMigrator::Migration.class_exists?('users')).to be true
        expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'age')).to be true
        expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'name')).to be true
        expect(OrientdbSchemaMigrator::Migration.index_exists?('users', 'user_age_idx')).to be false
      end
    end
  end
end

describe 'odb:rollback' do
  include_context 'rake'
  let(:task_path) { 'lib/tasks/orientdb_schema_migrator' }

  around do |example|
    ClimateControl.modify(ODB_TEST: 'true') do
      example.run
    end
  end

  context 'with passing migrations' do
    before(:all) do
      OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path + '/passing_series'
    end

    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'creates then removes the index' do
      rake['odb:migrate'].invoke
      expect(OrientdbSchemaMigrator::Migration.index_exists?('users', 'user_age_idx')).to be true
      rake['odb:rollback'].invoke
      expect(OrientdbSchemaMigrator::Migration.index_exists?('users', 'user_age_idx')).to be false
    end
  end
end
