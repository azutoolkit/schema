<div style="text-align:center"><img src="https://raw.githubusercontent.com/azutoolkit/schema/master/schema2.png" /></div>

# Schema

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/bcab4bfe3c9c4c45a832fd724aa1ffea)](https://app.codacy.com/manual/eliasjpr/schema?utm_source=github.com&utm_medium=referral&utm_content=eliasjpr/schema&utm_campaign=Badge_Grade_Dashboard)

![Crystal CI](https://github.com/eliasjpr/schema/workflows/Crystal%20CI/badge.svg)

Schemas come to solve a simple problem. Sometimes we would like to have type-safe guarantee parameters when parsing HTTP requests or Hash(String, String) for a request. Schema shard resolve precisely this problem with the added benefit of enabling self validating schemas that can be applied to any object, requiring little to no boilerplate code making you more productive from the moment you use this shard.

Self validating Schemas are beneficial, and in my opinion, ideal, for when defining API Requests, Web Forms, JSON.  Schema-Validation Takes a different approach and focuses a lot on explicitness, clarity, and precision of validation logic. It is designed to work with any data input, whether it’s a simple hash, an array or a complex object with deeply nested data.

Each validation is encapsulated by a simple, stateless predicate that receives some input and returns either true or false. Those predicates are encapsulated by rules which can be composed together using predicate logic, meaning you can use the familiar logic operators to build up a validation schema.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  schema:
    github: azutoolkit/schema
```

## Usage

```crystal
require "schema"
```

### Defining Self Validated Schemas

Schemas are defined as value objects, meaning structs, which are NOT mutable,
making them ideal to pass schema objects as arguments to constructors.

```crystal
class Example
  include Schema::Definition
  include Schema::Validation

  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)
  property last_name : String

  use EmailValidator, UniqueRecordValidator
  validate :email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
  validate :name, size: (1..20)
  validate :age, gte: 18, lte: 25, message: "Age must be 18 and 25 years old"
  validate :alive, eq: true
  validate :last_name, presence: true, message: "Last name is invalid"

  predicates do
    def some?(value : String, some) : Bool
      (!value.nil? && value != "") && !some.nil?
    end

    def if?(value : Array(Int32), bool : Bool) : Bool
      !bool
    end
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages, @last_name)
  end
end
```

### Schema class methods

```crystal
Example.from_json
Example.from_urlencoded("&foo=bar")
# Any object that responds to `.each`, `#[]?`, `#[]`, `#fetch_all?`
Example.new(params)
```

### Schema instance methods

```crystal
valid?    - Bool
validate! - True or Raise ValidationError
errors    - Errors(T, S)
```

### Example parsing HTTP Params (With nested params)

Below find a list of the supported params parsing structure and it's corresponding representation in Query String or `application/x-www-form-urlencoded` form data. 

```crystal
http_params = HTTP::Params.build do |p|
  p.add("string", "string_value")
  p.add("optional_string", "optional_string_value")
  p.add("string_with_default", "string_with_default_value")
  p.add("int", "1")
  p.add("optional_int", "2")
  p.add("int_with_default", "3")
  p.add("enum", "Foo")
  p.add("optional_enum", "Bar")
  p.add("enum_with_default", "Baz")
  p.add("array[]", "foo")
  p.add("array[]", "bar")
  p.add("array[]", "baz")
  p.add("optional_array[]", "foo")
  p.add("optional_array[]", "bar")
  p.add("array_with_default[]", "foo")
  p.add("hash[foo]", "1")
  p.add("hash[bar]", "2")
  p.add("optional_hash[foo][]", "3")
  p.add("optional_hash[foo][]", "4")
  p.add("optional_hash[bar][]", "5")
  p.add("hash_with_default[foo]", "5")
  p.add("tuple[]", "foo")
  p.add("tuple[]", "2")
  p.add("tuple[]", "3.5")
  p.add("boolean", "1")
  p.add("optional_boolean", "false")
  p.add("boolean_with_default", "true")
  p.add("nested[foo]", "1")
  p.add("nested[bar]", "3")
  p.add("nested[baz][]", "foo")
  p.add("nested[baz][]", "bar")
end
```

```crystal
params = HTTP::Params.parse("email=test%40example.com&name=john&age=24&alive=true&childrens%5B%5D=Child1%2CChild2&childrens_ages%5B%5D=12&childrens_ages%5B%5D=18&address%5Bcity%5D=NY&address%5Bstreet%5D=Sleepy+Hollow&address%5Bzip%5D=12345&address%5Blocation%5D%5Blongitude%5D=41.085651&address%5Blocation%5D%5Blatitude%5D=-73.858467&address%5Blocation%5D%5Buseful%5D=true")

# HTTP::Params responds to `#[]`, `#[]?`, `#fetch_all?` and `.each`
subject = ExampleController.new(params)
```

Accessing the generated schemas:

```crystal
user      = subject.user     - Example
address   = user.address     - Example::Address
location  = address.location - Example::Address::Location
```

## Example parsing from JSON

```crystal
json = %({ "user": {
      "email": "fake@example.com",
      "name": "Fake name",
      "age": 25,
      "alive": true,
      "childrens": ["Child 1", "Child 2"],
      "childrens_ages": [9, 12]
    }})

user = Example.from_json(json, "user")
```
## Validations

You can also perform validations for existing objects without the use of Schemas.

```crystal
class User < Model
  include Schema::Validation

  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)

  # To use a custom validator. UniqueRecordValidator will be initialized with an `User` instance
  use UniqueRecordValidator

  # Use the `custom` class name predicate as follow
  validate email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!", unique_record: true
  validate name, size: (1..20)
  validate age, gte: 18, lte: 25, message: "Must be 24 and 30 years old"
  validate alive, eq: true

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end
end
```

### Custom Validations

Simply create a class `{Name}Validator` with the following signature:

```crystal
class EmailValidator < Schema::Validator
  getter :record, :field, :message

  def initialize(@record : UserModel)
    @field = :email
    @message = "Email must be valid!"
  end

  def valid? : Array(Schema::Error)
    [] of Schema::Error
  end
end

class UniqueRecordValidator < Schema::Validator
  getter :record, :field, :message

  def initialize(@record : UserModel)
    @field = :email
    @message = "Record must be unique!"
  end

  def valid? : Array(Schema::Error)
    [] of Schema::Error
  end
end
```

### Defining Predicates

You can define your custom predicates by simply creating a custom validator or creating methods in the `Schema::Predicates` module ending with `?` and it should return a `boolean`. For example:

```crystal
class User < Model
  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)

  ...

  # Uses a `presense` predicate
  validate password : String, presence: true

  # Use the `predicates` macro to define predicate methods
  predicates do
    # Presence Predicate Definition
    def presence?(password : String, _other : String) : Bool
      !value.nil?
    end
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end
end
```

### Differences: Custom Validator vs Predicates

The differences between a custom validator and a method predicate are:

**Custom Validators**
-   Must be inherited from `Schema::Validator` abstract
-   Receives an instance of the object as a `record` instance var.
-   Must have a `:field` and `:message` defined.
-   Must implement a `def valid? : Array(Schema::Error)` method.

**Predicates**
-   Assertions of the property value against an expected value.
-   Predicates are light weight boolean methods.
-   Predicates methods must be defined as `def {predicate}?(property_value, expected_value) : Bool` .

### Built in Predicates

These are the current available predicates.

```crystal
gte   - Greater Than or Equal To
lte   - Less Than or Equal To
gt    - Greater Than
lt    - Less Than
size  - Size
in    - Inclusion
regex - Regular Expression
eq    - Equal
```

> **CONTRIBUTE** - Add more predicates to this shards by contributing a Pull Request. 

Additional params

```crystal
message - Error message to display
nilable - Allow nil, true or false
```

## Contributing

1.  Fork it (<https://github.com/your-github-user/schemas/fork>)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new Pull Request

## Contributors

-   [@eliasjpr](https://github.com/eliasjpr) Elias J. Perez - creator, maintainer
