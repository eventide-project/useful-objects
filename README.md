# The Doctrine of Useful Objects

## Overview

A useful object:

- Is usable immediately upon initialization without any nil reference errors resulting from uninitialized dependencies (eg: `NoMethodError, undefined method for nil:NilClass`)
- Doesn't have any logic in its initializer other than assigning the value of initializer parameters to the object's instance variables
- Formalizes the difference between initializer arguments and setters, and the circumstances when one is used rather than the other
- Doesn't require a foreign mechanism outside of the class's own namespace (including inner namespaces) to initialize it and its dependencies (a.k.a.: an _Inversion of Control container_, etc)
- Doesn't invite the passing nils or _dummy_ values to its initializer for the purposes of setting up the object for testing
- Doesn't rely on test doubles (stubs) to disengage dependencies that would cause undesirable side effects while exercising or otherwise testing it
- Doesn't rely on test doubles (mocks, spies) to be used to inspect an object's execution path

## Implications

An object's dependencies are initialized by default to a _safe_, and _inert_ (in terms of side effects) implementation of the dependency's interface.

An object's class interface provides a means of constructing an instance of the object, including the initialization of its dependencies to _active_, _operational_ implementations of the dependencies' interfaces, eg: an active database connection, an active payment gateway client, etc.

An object may record telemetry about its execution as it is executing. The activation of telemetry instrumentation is optional.

## Example Implementation

This repository includes an example implementation.

## Substitutes

A dependency has an interface. An object that conforms to that interface (and its semantics) is substitutable for the dependency. That object is a _substitute_.

There is no notion of _primary_ or _secondary_ substitutes. All values that can be assigned to a dependency attribute are substitutable for each other. No single substitute has precedence over the other.

There is no _real_ instance of a dependency versus a _fake_ instance. These perspectives are purely circumstantial, and should be drummed out of the designer's mind as quickly as they threaten to alight.

Substitutability guarantees that all implementations of an interface that respect the interface's contract and intended semantics are no more valuable than any other implementation of the interface, and no less _real_ than any other. All substitutes are _real_ substitutes by the very nature of substitutability.

## Null Object Dependencies and Useful Objects

The most basic safe and inert substitute for a dependency is a null object.

A null object substitute assigned as a default value of a dependency allows that dependency to be actuated without causing a nil reference error to be raised - which is a foundational tenet of useful objects.

A null object substitute is a legitimate substitute if all uses of the dependency don't cause a nil reference error to be raised.

Null objects can be either weak or strict. A weak null object responds to any invocation sent to it. A strict null object conforms to a specific interface and will raise no-method errors for any invocations that don't conform to that interface

## An Example

```ruby
class Something
  attr_reader :some_value
  attr_reader :some_other_value

  dependency :some_dependency, SomeDependency

  def initialize(some_value, some_other_value)
    @some_value = some_value
    @some_other_value = some_other_value
  end

  def self.build(some_object)
    new(some_object.some_value, some_object.some_other_value) do |instance|
      SomeDependency.configure instance
    end
  end
end
```

Usage:

```ruby
# Using the initializer results in null object dependencies
something = Something.new(some_value, some_other_value)
puts something.some_dependency.class
# => #<Class:0x007f9dcc0886f0>

# Using the constructor (factory method) results in operational dependencies
something = Something.build(some_obj)
puts something.some_dependency.class
# => SomeDependency
```

## Primitive Initializer and Complex Constructor

The initializer typically accepts _precisely_ the primitive data the object _depends on directly_ to perform its behavior.

Any destructuring of more complex objects is provided by a factory method, or _constructor_, provided by the class interface (the _build_ method, above).

By the time the initializer is invoked, the exact data needed by the object in order to do its work is supplied to the initializer. The initializer is not required to do any other work other than capturing the data as the object's instance variables.

The class constructor provides a _convenience interface_. It's the interface used to make invoking the initializer easier for the developer by not requiring that all of the initializer's individual arguments.

## Secondary, Optional Dependencies

The `some_dependency` dependency is not an appropriate initializer argument. It's a _collaborator_ dependency ( a better term would be _service_ dependency, but that term is too overloaded to be helpful).

An instance of the `Something` class needs the `some_dependency` in order to fulfill its obligations at runtime, but it is not necessary to provide the _operational_ implementation of the dependency in all cases (any substitute implementation - due to substitutability - is also a permissible value).

The `some_dependency` can be _optionally_ set to an _operational_ instance of `SomeDependency`, or to a substitute

## Optional Dependencies and Default Null Object Substitutes

By default, the `some_dependency` will be assigned a _strong_ null object that is constructed to conform to the `SomeDependency` interface.

A direct invocation of the initializer will not leave the `some_dependency` attribute uninitialized as `nil`.

The dependency will be assigned the default null object substitute that is constructed dynamically as a function of the `dependency` macro.

The value of `some_dependency` that is needed in live operation (the _operational_ implementation) is provided by the `build` constructor (factory) method.

This constructor (`build`) allows for the most convenient use of the class without commingling construction conveniences and machinations with the initializer, and leaves the initializer free of any responsibilities other than capturing only the essential data needed for the object's operation.

## Not Stubs

It's important to see substitutes as substitutes (in the substitutability property sense) rather than as _stubs_, or any other _test double_.

A _stub_ is a concern of testing. A substitute is a bona fide concern of a class's operational design.

While _stubs_ and _substitutes_ may find themselves in similar roles at test time, the perspective that leads a design toward stubs is very different than the design perspective that leads to substitutes.

The goal of a stub is to remove undesirable side effects from the course of execution during a test. The goal of a substitute is to allow an object to be useful upon initialization of the object, without needing to use any other tool setup but the class's own interface.

The use of test doubles relegates the properties of _usefulness_ and _transparency_ to an afterthought of testing.

A test that uses a stub framework is explicitly calling out the design requirement to allow for an object's dependencies to be _safe_ and _inert_ substitutes. These are legitimate use cases of the object and its dependencies that should be accounted for by the design, and the exercise of them in this way is a priori concern of the design.

## Configuration, not "Configuration"

The term _configuration_ here does not refer to the kind of preference or settings data used to provide system-wide variables during start up of an application or service.

The use of the term _configuration_ here refers to the configuration of an assemblage of collaborators. This is closer to the meaning of _configuration_ more common to the actor model and actor systems. In this context, it refers to the assignment of collaborator dependencies to the objects that depend on them.

## Configuring Dependencies

The job of configuring _actual_ dependencies falls to the class's _constructor_ (or, _factory method_), implemented above as the `build` method.

Furthermore, it's the job of the dependency's class to decide how the dependency should be constructed, and how it should be assigned to the object that has the dependency.

This line of code from the example above is where configuration is happening:

```ruby
SomeDependency.configure instance
```

This form allows `SomeDependency` to decide for itself how it should be constructed and to be assigned.

The simplest implementation would be:

```ruby
class SomeDependency
  def self.configure(receiver)
    instance = new
    receiver.some_dependency = instance
  end
end
```

This pattern is also an example of _Tell, Don't Ask_, which is a helpful pattern in preserving encapsulation, which in turn help limit the effects of some of the more harmful kinds of coupling.

In effect, _tell_ the dependency's class to get an instance of itself (in whichever why it does that, which is not the business of the user of the class), and to assign it back to the instance of the object that has the dependency.

While this property might seem negligible, spread over the breadth of an application or system, and over the weeks, months, or years of a work on a system of objects, the cumulative effects of uncontrolled coupling accounts for much of the productivity slow down and increased costs that teams commonly experience.

## Minimizing the Configuration Implementation

The above configuration implementation can be minimized with a macro.

Here is the `SomeDependency` class's configuration minimized by use of a `configure` macro:

```ruby
class SomeDependency
  configure :some_dependency, constructor: :new
end
```

Be warned, however, that doing this makes the class more obscure to first-glance intelligence - especially in situations where the configuration must be specialized or is more complicated.

It's arguable that pursuing this minimal implementation reduces the usability of this object even while the mechanical details of the boilerplate are reduced.

## Objects are _Behaviors_ First, and Data Second

Most objects in your system should be behavioral. This is a fundamental tenet of Object-Orientation, and really of most programming paradigms.

Behaviors aren't really supposed to be bolted on to data objects (a.k.a.: _entities_) as secondary features of data objects. But it's often the result when designers and developers see the system's _data_ as the purpose of objects. This is more of a common mental quirk than an aspect of design.

The pervasiveness of Object-Relational persistence frameworks, and the use of objects to represent storage structures - especially rows in databases - exacerbates the realization of objects as primarily concerned with behavior rather than data.

The implication for design is that a good deal of the classes in your systems will reflect the _Command Pattern_. However, because this is the _default_ use of objects, it doesn't need to be said that an object _implements the command pattern_. It's enough to say that _an object is an object_. This is the same as saying that an object _is behavioral_, or in other words, that an object is a _command_. In effect, it goes without saying that an object is a _command_. It should be more rare that an object is a _data object_ or an _entity_ (or an ActiveRecord object).

The implication is that objects rarely need to have "command" or "service" (just another name for a behavioral object) in their name. Subsequently, it's not necessary to have words like "do" or "execute" or "perform" in a class's name, or in any of its methods' names.

There are always exceptions, but they should be rare. If they're not rare, the design of the namespace should be examined for design flaws.

## Actuators

Unlike a data structure, an object is responsible for a single act. That act is set in motion by a single method. That method is termed, "actuator".

It's not necessary to give this method a name like "run", "perform", etc. Ruby already provides for implementing actuators with a method named `call`. This built-in can be invoked implicitly as `some_object.()` (although `some_object.call()` will also work).

Behavioral objects have _actuators_. The objects' classes also have actuators. This duality parallels the relationship between a class's initializer and its `build` method.

Once an object is instantiated, it is ready to be actuated, ie: to have its `call` method invoked. As a convenience, the class also provides a `call` method. The _class actuator_ constructs the object, and invokes the instance actuator.

## Elaborated Example

The above example elaborated with actuators:

```ruby
class Something
  attr_reader :some_value
  attr_reader :some_other_value

  dependency :some_dependency, SomeDependency

  def initialize(some_value, some_other_value)
    @some_value = some_value
    @some_other_value = some_other_value
  end

  def self.build(some_object)
    new(some_object.some_value, some_object.some_other_value) do |instance|
      SomeDependency.configure instance
    end
  end

  def self.call(some_object)
    instance = build(some_object)
    instance.()
  end

  def call
    # Execute the object's raison d'etre, making use
    # of the object's attributes and dependencies
  end
end
```

## Minimizing the Primitive Initializer

The above primitive initializer is ultimately so simple that it could effectively be replaced with a macro:

```ruby
class Something
  initializer :some_value, :some_other_value

  dependency :some_dependency, SomeDependency

  # ...
end
```

In the above case, the `initializer` macro would both generate the `initialize` method _and_ create the two attributes.

Note: While this is a possibility opened by making sure that initializers _only_ capture initial data and do nothing else, representing an initializer and its attributes with such a macro is a personal choice. It has the drawback of being more obscure and esoteric. Such a thing should be standardized and socialized in a team so that it's self-evident for the developers who experience it.

## Telemetry and Transparency

The ability for an object to provide insight into its own execution is something that should be accounted for by the design, and should be a first class citizen of design.

If the execution of an object is important enough to need to verify the execution in a test, then that _transparency_ is a bona fide element of the design, rather than the responsibility of the user of the object (ie: test code).

Transparency is not _of_ tests. It is _used by_ tests. Transparency is of design.

Said otherwise: the presence of test doubles (mocks, stubs, spies) signifies that an object's deign itself is not accounting for the use cases that it is engaged in. The object is being asked to do things that it's not designed for.

There's no doubt that a Ruby object can be brute-forced into such a thing, but that doesn't solve the problem of a class expressing its uses in its own code.

It should be clear to the reader of the class what the class's user are interested in terms of transparency, what telemetry is published during a class's execution, and how the instrumentation is activated.

Here's an elaboration of the implementation that includes a telemetry mechanism:

Usage:

```ruby
something = Something.build(some_obj)
sink = Something.register_telemetry_sink(something)
something.()
assert(sink.recorded_something_done?)
```

```ruby
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
  end
end
```

## Concrete Substitutes

In addition to having dependencies being initialized to null object implementations, substitutes should also provide a means to override the inert null object with a concrete implementation of a substitute (or to specialize the null object).

Here's an example of a dependency with a concrete substitute substitute implementation (though a naive one that doesn't demonstrate a realistic case):

```ruby
class SomeDependency
  configure :some_dependency, factory_method: :new

  def do_something
    do_some_destructive_side_effect
  end

  module Substitute
    def self.build
      SomeDependency.new
    end

    class SomeDependency < ::SomeDependency
      def do_something
        pretend_to_do_some_destructive_side_effect
      end
    end
  end
end
```

## Concrete Substitutes and Telemetry

If a concrete substitute also needs transparency, it can be instrumented with telemetry to record and expose the details of its execution:

Usage:

```ruby
something = Something.new(some_value, some_other_value)
some_dependency = something.some_dependency
sink = SomeDependency.register_telemetry_sink(some_dependency)
assert(sink.recorded_something_done?)
```

```ruby
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
```

Note: The registration of telemetry can also be done during the construction of the substitute.

## Addendum

### Class Interface and Convenience Versus Object Interface and Precision

Illustrated by both the class constructor and class actuator, a _class interface_ is a convenience affordance. It allows for instantiation or actuation of an object in a way that is most convenient to the developer.

The instance interface is structured to express the greatest extent of precision and exactness without consideration for developer convenience.

The object interface is _correct_. The class interface is an _ease of use_ provision that does the work of providing more exact and precise arguments to the object interface.

The class interface insulates the object interface from the encroachment of imprecision that comes from a developer's desire to have ease of use.

For example, it's common (while imprecise and _incorrect_) for ruby developers to pass a hash of values to an initializer, and then copy the hash's values to the instantiated object's instance variables. This would be an example of an initializer that does not offer the precision appropriate to an instance interface.

Instead, an initializer should only receive exactly the data that will be assigned to the object's instance variables, without any _destructuring_ of more complex objects, like a hash.

By providing a class constructor, the initializer's precision can be preserved, while also providing a convenience on the class's interface that can destructure the hash and invoke the initializer with the appropriate level of exactitude and precision.

The following example illustrates the principles:

```ruby
class Something
  def initialize(some_arg, some_other_arg, another_arg)
    @some_arg = some_arg
    @some_other_arg = some_other_arg
    @another_arg = another_arg
  end

  def self.build(hash)
    new(
      hash[:some_arg],
      hash[:some_other_arg],
      hash[:another_arg]
    )
  end
end
```

### Anticipated Objection: This Approach Causes Too Much Boilerplate Code

Boilerplate can be seen as _clutter_ that is obscuring the deeper meaning and purpose of the implementation. However, there's a tipping point beyond which further reduction of mechanical code makes the object's operation incomprehensible.

While counter-intuitive to many developers, the reduction of in the amount of code is usually not a factor in increasing productivity. In fact, the opposite is true, and is often plainly observable through static analysis of design and code.

The unavoidable side-effect of reducing certain kinds of boilerplate is an increase in abstractness. With an increase in abstractness comes the increase of afferent coupling to abstract members, and with that comes the rigidity that has a compounding effect on the time it takes to get work done. Abstractness is not a _gift that keeps on giving_. It's a specific countermeasure for a specific set of problems. Used outside of those problems, it creates more problems than it solves.

It can't be over-emphasized that the things that need to be done to a design to reduce mechanical boilerplate code can be as harmful to design as they are helpful.

There is only a certain amount of boilerplate reduction that can be afforded before efforts to reduce boilerplate create more subtle, but more costly and more entrenched problems.

Seeing the same _patterns_ of code repeatedly can trigger the _Don't Repeat Yourself_ instinct. Deeper inspection of design factors as well as the _Don't Repeat Yourself_ adage itself can show that boilerplate reduction is _not_ the intention of the guidance provided by the adage.

Rather than reduce mere boilerplate code, look for variations on patterns and see if you can eliminate them. Even if the result is that the same _pattern_ is repeated throughout your code. It's the _special variation_ that is more costly to work with.

Any programmer at any level can reduce perceived duplication. It's not difficult, and it's not an unassailable goal of design - except when it does not create countervailing problems. And that assessment is a matter of a judgment call that has to take into effect the unique conditions of the particular system being worked.

If you reduce duplication of code patterns indiscriminately, you'll end up creating a _framework_ from which critical business logic cannot be extricated when the framework becomes too cumbersome to continue justifying its use. While not _all_ frameworks end up facing this fate, it's far more common than not, as framework developers struggle to maintain adoption and relevance as time goes passes by adding more features and specializations through abstraction rather than by extension (ie: plain old _vendor lock-in_).

In effect, the abstractions created by the pre-mature boilerplate reduction can cause the use of the programming language to diverge so far from the language's own foundations that learning the framework becomes an exercise in effectively learning a new language. This in itself is an example of the kind of _special variation_ that must be rigorously controlled rather than automatically indulged.

While having to code boilerplate code can seen tedious and annoying, that's all it is. The avoidance of tedium is not a sufficient risk to the design's structural qualities to warrant its indulgence reflexively.

Necessary, irreducible boilerplate is just one of those things that we need to face as programmers with increased patience and a shift in focus from short term gains to long-term sustainability and continuity.

Boilerplate - as long as its instances in various classes have avoided variation, and as long as consistency is rigorously protected - is a very minimal impact on productivity and quality.
