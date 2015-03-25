module OrientdbSchemaMigrator
  class Proxy
    attr_reader :target, :context

    def initialize(target, context)
      @target = target
      @context = context
    end

    def proxy(&block)
      block.call
    end

    def method_missing(type,property, options={})
      puts self.context
      self.target.send :add_property, self.context, property, type, options
    end
  end
end