module UsefulObjects
  class SomeDependency
    dependency :telemetry, ::Telemetry

    configure :some_dependency do
      new.tap do |instance|
        ::Telemetry.configure instance
      end
    end

    def do_something
      do_some_destructive_side_effect
    end

    def do_some_destructive_side_effect
      # ...
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

    module Substitute
      def self.build
        SomeDependency.build
      end

      class SomeDependency < UsefulObjects::SomeDependency
        attr_accessor :sink

        def self.build
          new.tap do |instance|
            ::Telemetry.configure instance
          end
        end

        def do_something
          telemetry.record :something_done
          pretend_to_do_some_destructive_side_effect
        end

        def pretend_to_do_some_destructive_side_effect
          # ...
        end
      end
    end
  end
end
