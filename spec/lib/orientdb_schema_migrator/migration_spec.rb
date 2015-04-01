require 'spec_helper'

describe OrientdbSchemaMigrator::Migration do
  def cleanup!
    OrientdbSchemaMigrator::Migration.drop_class(test_class_name)
  rescue
  end

  after(:each) do
    cleanup!
  end

  before(:each) do
    cleanup!
  end

  let(:test_class_name) { 'user' }

  describe '.class_exists?' do
    context 'when class does not exist' do
      it 'returns false' do
        expect(class_exists?(test_class_name)).to be false
      end
    end

    context 'when class does exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      it 'returns true' do
        expect(class_exists?(test_class_name)).to be true
      end
    end
  end

  describe '.create_class' do
    context 'when class does not exist' do
      it 'creates the class' do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
        expect(class_exists?(test_class_name)).to be true
      end
    end

    context 'when class already exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      it 'returns false' do
        expect(OrientdbSchemaMigrator::Migration.create_class(test_class_name)).to be false
      end
    end
  end

  describe '.rename_class' do
    let(:renamed_class) { 'foo' }
    context 'when class does not exist' do
      it 'returns false' do
        expect(OrientdbSchemaMigrator::Migration.rename_class(test_class_name, renamed_class)).to be false
      end
    end

    context 'when class exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      after do
        begin
          OrientdbSchemaMigrator::Migration.drop_class(renamed_class)
        rescue
        end
      end

      it 'returns true' do
        expect(OrientdbSchemaMigrator::Migration.rename_class(test_class_name, renamed_class)).to be true
      end

      it 'renames the class' do
        OrientdbSchemaMigrator::Migration.rename_class(test_class_name, renamed_class)
        expect(class_exists?(test_class_name)).to be false
        expect(class_exists?(renamed_class)).to be true
      end
    end
  end

  describe '.add_property' do
    let(:prop_name) { 'name' }
    context 'when class exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      it 'adds the new property' do
        OrientdbSchemaMigrator::Migration.add_property(test_class_name, prop_name, 'integer')
        expect(property_exists?(test_class_name, prop_name)).to be true
      end

      context 'with invalid property type' do
        it 'raises an exception' do
          expect { OrientdbSchemaMigrator::Migration.add_property(test_class_name, prop_name, 'symbol') }.to raise_exception(Orientdb4r::ServerError)
        end
      end
    end

    context 'when class does not exist' do
      it 'returns false' do
        expect { OrientdbSchemaMigrator::Migration.add_property(test_class_name, prop_name, 'integer') }.to raise_exception(OrientdbSchemaMigrator::MigrationError)
      end
    end
  end

  describe '.drop_property' do
    let(:prop_name) { 'age' }
    context 'when class exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      context 'and property exists' do
        before do
          OrientdbSchemaMigrator::Migration.add_property(test_class_name, prop_name, 'integer')
        end

        it 'drops the property' do
          expect(property_exists?(test_class_name, prop_name)).to be true
          OrientdbSchemaMigrator::Migration.drop_property(test_class_name, prop_name)
          expect(property_exists?(test_class_name, prop_name)).to be false
        end
      end

      context 'and property does not exist' do
        it 'returns false' do
          expect(OrientdbSchemaMigrator::Migration.drop_property(test_class_name, prop_name)).to be false
        end
      end
    end

    context 'when class does not exist' do
      it 'returns false' do
        expect { OrientdbSchemaMigrator::Migration.drop_property(test_class_name, prop_name) }.to raise_exception(OrientdbSchemaMigrator::MigrationError)
      end
    end
  end

  describe '.alter_property' do
    let(:prop_name) { 'age' }
    context 'when class exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      context 'and property exists' do
        before do
          OrientdbSchemaMigrator::Migration.add_property(test_class_name, prop_name, 'integer')
        end

        it 'succeeds' do
          OrientdbSchemaMigrator::Migration.alter_property(test_class_name, prop_name, 'name', 'old_age')
        end

        it 'alters the property' do
          OrientdbSchemaMigrator::Migration.alter_property(test_class_name, prop_name, 'name', 'old_age')
          expect(property_exists?(test_class_name, prop_name)).to be false
          expect(property_exists?(test_class_name, 'old_age')).to be true
        end
      end

      context 'and property does not exist' do
        it 'returns false' do
          expect(OrientdbSchemaMigrator::Migration.alter_property(test_class_name, prop_name, 'name', 'old_age')).to be false
        end
      end
    end

    context 'when class does not exist' do
      it 'returns false' do
        expect { OrientdbSchemaMigrator::Migration.alter_property(test_class_name, prop_name, 'name', 'old_age') }.to raise_exception(OrientdbSchemaMigrator::MigrationError)
      end
    end
  end

  describe '.add_index' do
    let(:index_name) { 'user_age_idx' }
    context 'when class exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
      end

      context 'when property exists' do
        before do
          OrientdbSchemaMigrator::Migration.add_property('user', 'age', 'integer')
        end

        it 'adds the index' do
          OrientdbSchemaMigrator::Migration.add_index(test_class_name, 'age', index_name, 'unique')
          expect(index_exists?(test_class_name, index_name)).to be true
        end
      end

      context 'when property does not exist' do
        it 'fails' do
          expect { OrientdbSchemaMigrator::Migration.add_index(test_class_name, 'age', index_name, 'unique') }.to raise_exception(OrientdbSchemaMigrator::MigrationError)
        end
      end
    end

    context 'class does not exist' do
      it 'returns false' do
        expect { OrientdbSchemaMigrator::Migration.add_index(test_class_name, 'age', index_name, 'unique') }.to raise_exception(OrientdbSchemaMigrator::MigrationError)
      end
    end
  end

  describe '.drop_index' do
    let(:index_name) { 'user_age_idx' }
    context 'when index exists' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
        OrientdbSchemaMigrator::Migration.add_property('user', 'age', 'integer')
        OrientdbSchemaMigrator::Migration.add_index('user', 'age', index_name, 'unique')
      end

      it 'drops the index' do
        expect(OrientdbSchemaMigrator::ODBClient.get_class(test_class_name)['indexes']).not_to be_nil
        OrientdbSchemaMigrator::Migration.drop_index(index_name)
        expect(OrientdbSchemaMigrator::ODBClient.get_class(test_class_name)['indexes']).to be_nil
      end
    end

    context 'when index does not exist' do
      before do
        OrientdbSchemaMigrator::Migration.create_class(test_class_name)
        OrientdbSchemaMigrator::Migration.add_property('user', 'age', 'integer')
      end

      # seems like strange behaviour, but this is what we get from the server
      it 'it fails' do
        pending 'returns a hash...?'
        expect(OrientdbSchemaMigrator::Migration.drop_index(index_name)).to be false
      end
    end
  end
end
