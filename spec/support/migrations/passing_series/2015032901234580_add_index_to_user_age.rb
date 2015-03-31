class AddIndexToUserAge < OrientdbSchemaMigrator::Migration
  def self.up
    add_index 'users', 'age', 'user_age_idx', 'unique'
  end

  def self.down
    drop_index 'user_age_idx'
  end
end
