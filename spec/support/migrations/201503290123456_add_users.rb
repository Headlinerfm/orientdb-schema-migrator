class AddUsers < OrientdbSchemaMigrator::Migration
  def self.up
    create_class 'users'
  end

  def self.down
    drop_class 'users'
  end
end
