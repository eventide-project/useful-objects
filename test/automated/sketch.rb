require_relative './automated_init'
require 'ostruct'

some_value = 'some value'
some_other_value = 'some other value'

some_obj = OpenStruct.new
some_obj.some_value = some_value
some_obj.some_other_value = some_other_value

something = UsefulObjects::Something.build some_obj

assert(something.some_value == 'some value')
assert(something.some_other_value == 'some other value')

assert(something.some_dependency.instance_of? SomeDependency)

sink = Something.register_telemetry_sink(something)
something.()
assert(sink.recorded_something_done?)


# - - -
# Concrete dependency and telemetry

something = UsefulObjects::Something.new(some_value, some_other_value)

sink = SomeDependency.register_telemetry_sink(something.some_dependency)
something.()
assert(sink.recorded_something_done?)
