require 'active_support/inflector'
require 'erb'

module OrientdbSchemaMigrator
  class InvalidMigrationName < StandardError; end

  class MigrationGenerator

    class MigrationGeneratorBinding
      attr_reader :name
      def initialize(name)
        @name = name
      end

      def get_binding
        binding
      end
    end

    def self.generate(name, path)
      mg = new(name, path)
      mg.write_file
    end

    def initialize(name, path)
      @name = name
      validate_name!
      time = Time.now.strftime("%Y%m%d%H%M%S")
      file_name = @name.underscore
      @file_path = path + "/" + time + "_" + file_name + ".rb"
    end

    def write_file
      template_path = File.expand_path("../templates/migration_template.rb", __FILE__)
      File.open(@file_path, "w", 0644) do |f|
        f.write ERB.new(File.read(template_path)).result(MigrationGeneratorBinding.new(name).get_binding)
      end
    end

    private

    attr_reader :name

    def validate_name!
      if name.underscore.camelcase != name
        fail InvalidMigrationName.new("Name must be convertible between CamelCase and snake_case: #{name}")
      end
      if name.match(/[^a-zA-Z]+/)
        fail InvalidMigrationName.new("Name must consist only of alphabetic characters: #{name}")
      end
    end
  end
end
