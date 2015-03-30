module OrientdbSchemaMigrator
  class MigrationError < StandardError; end

  class Migration
    def self.create_class class_name, class_options={}
      # check if class exists first
      if class_exists? class_name
        return false
      else
        ODBClient.create_class class_name, class_options
        if block_given?
          proxy = Proxy.new(self, class_name)
          yield proxy
        end

        return true
      end
    end

    def self.drop_class class_name
      # check if class exists first
      if !class_exists? class_name
        return false
      else
        # delete vertices/edges first
        super_class = ODBClient.get_class(class_name)["superClass"]
        if super_class == "V"
          ODBClient.command "delete vertex #{class_name}"
        elsif super_class == "E"
          ODBClient.command "delete edge #{class_name}"
        end
        # drop class
        ODBClient.command "drop class #{class_name}"
        return true
      end
    end

    def self.rename_class old_name, new_name
      if class_exists? old_name
        ODBClient.command "alter class #{old_name} name #{new_name}"
        return true
      else
        return false
      end
    end

    def self.add_property class_name, property_name, type, property_options={}
      return false unless class_exists?(class_name)
      ODBClient.create_property class_name,property_name,type, property_options
    end

    def self.drop_property class_name, property_name
      return false unless class_exists?(class_name)
      return false unless property_exists?(class_name, property_name)
      ODBClient.command "drop property #{class_name}.#{property_name}"
    end

    def self.alter_property class_name, property_name, attribute_name, new_value
      return false unless class_exists?(class_name)
      return false unless property_exists?(class_name, property_name)
      ODBClient.command "alter property #{class_name}.#{property_name} #{attribute_name} #{new_value}"
    end

    def self.add_index class_name, property_name, index_name, type
      # schema has to exist.
      # check if property exists first, if not ask to create property.
      if property_exists? class_name, property_name
        ODBClient.command "create index #{index_name} on #{class_name} (#{property_name}) #{type}"
        return true
      else
        return false
      end
    end

    def self.drop_index index_name
      ODBClient.command "drop index #{index_name}"
    end

    def self.class_exists? class_name
      ODBClient.class_exists? class_name
    end

    def self.index_exists?(class_name, index_name)
      indexes = ODBClient.get_class(class_name)["indexes"]
      return false unless indexes
      return indexes.any? { |idx| idx['name'] == index_name }
    end

    def self.property_exists? class_name, property_name
      if class_exists? class_name
        properties = ODBClient.get_class(class_name)["properties"]
        if properties
          return properties.collect{|i| i["name"]}.include? property_name
        else
          return false
        end
      else
        return false
      end
    end
  end
end
