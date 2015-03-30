module OrientdbSchemaMigrator
  class Proxy
    attr_reader :target, :context

    def initialize(target, context)
      @target = target
      @context = context
    end

    def add_property(property, type, options = {})
      target.public_send(:add_property, context, property, type, options)
    end

    def alter_property(property, attribute_name, new_value)
      target.public_send(:add_property, context, property, attribute_name, new_value)
    end

    def drop_property(property)
      target.public_send(:add_property, context, property)
    end

    def add_index(property, index_name, index_type)
      target.public_send(:add_property, context, property, index_name, index_type)
    end
  end
end
