class AddUsers < OrientdbSchemaMigrator::Migration
  def self.up
    create_class 'users' do |c|
      c.add_property 'age', 'integer'
      c.add_property 'name', 'string'
    end
  end

  def self.down
    drop_class 'users'
  end
end
