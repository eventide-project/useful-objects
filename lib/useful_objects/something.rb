module UsefulObjects
  class Something
    attr_reader :some_value
    attr_reader :some_other_value

    dependency :some_dependency, SomeDependency
    dependency :telemetry, ::Telemetry

    def initialize(some_value, some_other_value)
      @some_value = some_value
      @some_other_value = some_other_value
    end

    def self.build(some_object)
      new(some_object.some_value, some_object.some_other_value).tap do |instance|
        SomeDependency.configure instance
        ::Telemetry.configure instance
      end
    end

    def self.call(some_object)
      instance = build(some_object)
      instance.()
    end

    def call
      do_something
    end

    def do_something
      telemetry.record :something_done, some_value
      do_something_else
    end

    def do_something_else
      some_dependency.do_something
    end

    module Telemetry
      class Sink
        include ::Telemetry::Sink

        record :something_done
      end

      def self.sink
        Sink.new
      end
    end

    def self.register_telemetry_sink(something)
      sink = Telemetry.sink
      something.telemetry.register sink
      sink
    end
  end
end
