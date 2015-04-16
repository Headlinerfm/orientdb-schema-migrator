require 'spec_helper'

describe OrientdbSchemaMigrator::MigrationGenerator do
  let(:tmp_path) { File.expand_path('../../../../tmp/', __FILE__) }
  def cleanup!
    Dir[File.expand_path('../../../../tmp/', __FILE__)+'/*.rb'].each{|f| File.delete(f)}
  rescue
  end

  after(:all) do
    cleanup!
  end

  around do |example|
    ClimateControl.modify(ODB_TEST: 'true') do
      example.run
    end
  end

  describe '.generate' do
    context 'with malformed name' do
      context 'not camelcase-able' do
        it 'fails' do
          expect do
            OrientdbSchemaMigrator::MigrationGenerator.generate('foo', tmp_path)
          end.to raise_exception(OrientdbSchemaMigrator::InvalidMigrationName)
        end
      end

      context 'containing non-alphabetic characters' do
        it 'fails' do
          expect do
            OrientdbSchemaMigrator::MigrationGenerator.generate('FooBar1', tmp_path)
          end.to raise_exception(OrientdbSchemaMigrator::InvalidMigrationName)
        end
      end
    end

    context 'with valid name' do
      it 'writes the migration template to a file' do
        expect_any_instance_of(File).to receive(:write).with("class FooBar < OrientdbSchemaMigrator::Migration\n  def self.up\n  end\n\n  def self.down\n  end\nend\n")
        OrientdbSchemaMigrator::MigrationGenerator.generate('FooBar', tmp_path)
      end

      it 'appropriately names the migration file' do
        expect(File).to receive(:open).with(match(/[0-9]{14}_foo_bar/), 'w', 0644)
        OrientdbSchemaMigrator::MigrationGenerator.generate('FooBar', tmp_path)
      end
    end
  end
end
