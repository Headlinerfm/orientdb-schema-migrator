class AddUsers < OrientdbSchemaMigrator::Migration
  def self.up
    add_class 'users'
  end

  def self.down
    remove_class 'users'
  end
end
