require 'spec_helper'

describe 'migration specs' do
  def cleanup!(classes)
    classes.each { |class_name| OrientdbSchemaMigrator::Migration.drop_class(class_name) }
    OrientdbSchemaMigrator::ODBClient.command "truncate class schema_versions"
  end

  before(:all) do
    OrientdbSchemaMigrator::Migrator.migrations_path = migrations_path
  end

  describe 'simple class addition/removal' do
    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'creates then removes the class' do
      OrientdbSchemaMigrator::Migrator.new(nil, '201503290123456', :up).migrate
      expect(OrientdbSchemaMigrator::Migration.class_exists?('users')).to be true
      OrientdbSchemaMigrator::Migrator.rollback
      expect(OrientdbSchemaMigrator::Migration.class_exists?('users')).to be false
    end
  end

  describe 'class addition/removal with properties' do
    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
    end

    it 'creates then removes the class' do
      OrientdbSchemaMigrator::Migrator.new('201503290123457', '201503290123457', :up).migrate
      expect(OrientdbSchemaMigrator::Migration.class_exists?('users')).to be true
      expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'age')).to be true
      expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'name')).to be true
      OrientdbSchemaMigrator::Migrator.rollback
      expect(OrientdbSchemaMigrator::Migration.class_exists?('users')).to be false
    end
  end

  describe 'multiple migrations with class and index' do
    before(:each) do
      cleanup!(['users'])
    end

    after(:each) do
      cleanup!(['users'])
      OrientdbSchemaMigrator::Migration.drop_index('user_age_idx')
    end

    it 'creates class and index' do
      OrientdbSchemaMigrator::Migrator.new('201503290123457', '201503290123458', :up).migrate
      expect(OrientdbSchemaMigrator::Migration.property_exists?('users', 'age')).to be true
      expect(OrientdbSchemaMigrator::Migration.index_exists?('users', 'user_age_idx')).to be true
      OrientdbSchemaMigrator::Migrator.run(:down, '201503290123457')
      expect(OrientdbSchemaMigrator::Migration.index_exists?('users', 'user_age_idx')).to be false
    end
  end
end
