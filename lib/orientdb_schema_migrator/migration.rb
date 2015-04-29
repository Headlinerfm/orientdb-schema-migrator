module OrientdbSchemaMigrator
  class MigrationError < StandardError; end

  class Migration
    def self.create_class class_name, class_options={}
      # check if class exists first
      assert_class_not_exists!(class_name)
      OrientdbSchemaMigrator.client.create_class class_name, class_options
      if block_given?
        proxy = Proxy.new(self, class_name)
        yield proxy
      end
    end

    def self.drop_class class_name
      # check if class exists first
      if class_exists?(class_name)
        # delete vertices/edges first
        super_class = OrientdbSchemaMigrator.client.get_class(class_name)["superClass"]
        if super_class == "V"
          OrientdbSchemaMigrator.client.command "delete vertex #{class_name}"
        elsif super_class == "E"
          OrientdbSchemaMigrator.client.command "delete edge #{class_name}"
        end
        # drop class
        OrientdbSchemaMigrator.client.command "drop class #{class_name}"
        return true
      else
        return false
      end
    end

    def self.rename_class old_name, new_name
      assert_class_exists!(old_name)
      OrientdbSchemaMigrator.client.command "alter class #{old_name} name #{new_name}"
    end

    def self.add_property class_name, property_name, type, property_options={}
      assert_class_exists!(class_name)
      assert_property_not_exists!(class_name, property_name)
      OrientdbSchemaMigrator.client.create_property class_name,property_name,type, property_options
    end

    def self.drop_property class_name, property_name
      assert_class_exists!(class_name)
      assert_property_exists!(class_name, property_name)
      OrientdbSchemaMigrator.client.command "drop property #{class_name}.#{property_name}"
    end

    def self.alter_property class_name, property_name, attribute_name, new_value
      assert_class_exists!(class_name)
      assert_property_exists!(class_name, property_name)
      OrientdbSchemaMigrator.client.command "alter property #{class_name}.#{property_name} #{attribute_name} #{new_value}"
    end

    def self.add_index class_name, property_name, index_name, type
      assert_class_exists!(class_name)
      assert_property_exists!(class_name, property_name)
      assert_index_not_exists!(class_name, index_name)
      OrientdbSchemaMigrator.client.command "create index #{index_name} on #{class_name} (#{property_name}) #{type}"
    end

    def self.drop_index index_name
      OrientdbSchemaMigrator.client.command "drop index #{index_name}"
    end

    def self.class_exists? class_name
      OrientdbSchemaMigrator.client.class_exists? class_name
    end

    def self.index_exists?(class_name, index_name)
      return false unless class_exists?(class_name)
      indexes = OrientdbSchemaMigrator.client.get_class(class_name)["indexes"]
      return false unless indexes
      return indexes.any? { |idx| idx['name'] == index_name }
    end

    def self.property_exists? class_name, property_name
      if class_exists? class_name
        properties = OrientdbSchemaMigrator.client.get_class(class_name)["properties"]
        if properties
          return properties.collect{|i| i["name"]}.include? property_name
        else
          return false
        end
      else
        return false
      end
    end

    def self.assert_class_exists!(class_name)
      fail MigrationError.new("Class #{class_name} does not exist") unless class_exists?(class_name)
    end

    def self.assert_class_not_exists!(class_name)
      fail MigrationError.new("Class #{class_name} already exists") unless !class_exists?(class_name)
    end

    def self.assert_property_exists!(class_name, property)
      fail MigrationError.new("#{class_name}.#{property} does not exist") unless property_exists?(class_name, property)
    end

    def self.assert_property_not_exists!(class_name, property)
      fail MigrationError.new("#{class_name}.#{property} already exists") unless !property_exists?(class_name, property)
    end

    def self.assert_index_not_exists!(class_name, index)
      fail MigrationError.new("#{class_name},#{index} already exists") unless !index_exists?(class_name, index)
    end
  end
end
