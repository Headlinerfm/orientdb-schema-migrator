require 'erb'
module OrientdbSchemaMigrator
  class MigrationGenerator
    class << self
      def create_migration_file name, path
        time = DateTime.now.strftime("%Y%m%d%H%M%S")
        file_name = name.scan(/[A-Z][a-z]+/).map{|i| i.downcase}.join("_")
        file_path = path + "/" + time + "_" + file_name + ".rb"
        migration_class_name = name
        template_path = File.expand_path("../templates/migration_template.rb", __FILE__)
        File.open(file_path,"w") do |f|
          f.write ERB.new(File.read(template_path)).result(binding)
        end
      end
    end
  end
end