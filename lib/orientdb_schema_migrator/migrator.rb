module OrientdbSchemaMigrator
  class Migrator
    class << self
      def connect_to_db db, user, password
        ODBClient.connect :database => db, :user => user, :password => password
      end

      def migrate command, db_folder, version
        load_migration_file db_folder, version
        case command
        when "up"
          up
        when "down"
          down
        else
          puts "wrong command"
        end
      end

      def load_migration_file db_folder, version
        file_path = Dir[db_folder + "/#{version}*.rb"]
        if file_path.size > 0
          migration_file_name = file_path[0]
        else
          raise "can't find correct version"
        end

        require migration_file_name
      end

      def up
        ObjectSpace.each_object(Class).select { |klass| klass < OrientdbSchemaMigrator::Migration }[0].up
      end

      def down
        ObjectSpace.each_object(Class).select { |klass| klass < OrientdbSchemaMigrator::Migration }[0].down
      end
    end
  end
end
