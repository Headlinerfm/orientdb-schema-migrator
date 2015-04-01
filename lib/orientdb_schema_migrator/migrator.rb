require 'active_support/inflector'

module OrientdbSchemaMigrator
  class MigratorConflictError < StandardError; end

  class Migrator
    @migrations_path = nil

    class << self
      def migrations_path= path
        @migrations_path = path
      end

      def migrations_path
        @migrations_path
      end

      def connect_to_db db, user, password
        ODBClient.connect :database => db, :user => user, :password => password
      end

      def migrate(target_version = nil)
        run(:up, target_version)
      end

      def migrations
        files = Dir[@migrations_path + '/[0-9]*_*.rb']
        seen = Hash.new false
        migrations = files.map do |f|
          version, name = f.scan(/(\d+)_([^\.]+)/).first
          if seen[version] || seen[name]
            fail MigratorConflictError.new("Duplicate migration name/version: #{name}, #{version}")
          else
            seen[version] = seen[name] = true
          end
          {
            name: name,
            version: version,
            path: f
          }
        end
        migrations.sort_by { |m| m[:version] }
      end

      def run(command, target_version)
        new(current_version, target_version, command).migrate
      end

      def rollback(options = {})
        new(current_version, nil, nil).rollback
      end

      def current_version
        response = ODBClient.command "SELECT schema_version FROM schema_versions ORDER BY @rid DESC LIMIT 1"
        results = response['result']
        results.any? ? results.first['schema_version'] : nil
      end
    end

    def initialize(current_version, target_version, direction)
      @current_version = current_version
      @target_version = target_version
      @direction = direction
    end

    def migrations
      return @migrations if defined?(@migrations)
      if @direction == :down
        @migrations = self.class.migrations.reverse
      else
        @migrations = self.class.migrations
      end
    end

    def migrate
      migrations[start..finish].each do |m|
        require m[:path]
        m[:name].camelize.constantize.public_send(@direction)
        if up?
          record_migration(m)
        else
          drop_migration(m)
        end
      end
    end

    def rollback
      migrations.find { |m| m[:version] == @current_version }.tap do |m|
        require m[:path]
        m[:name].camelize.constantize.down
        drop_migration(m)
      end
    end

    private

    def start
      @current_version.nil? ? 0 : migrations.find_index { |m| m[:version] == @current_version }
    end

    def finish
      @target_version.nil? ? migrations.size - 1 : migrations.find_index { |m| m[:version] == @target_version }
    end

    def record_migration(migration)
      ODBClient.command "INSERT INTO schema_versions (schema_version) VALUES (#{migration[:version]})"
    end

    def drop_migration(migration)
      ODBClient.command "DELETE FROM schema_versions WHERE schema_version = '#{migration[:version]}'"
    end

    def up?
      @direction == :up
    end

    def down?
      @direction == :down
    end
  end
end
