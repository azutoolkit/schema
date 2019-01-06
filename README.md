# Schemas-Validations

[![Build Status](https://travis-ci.org/eliasjpr/schema-validations.svg?branch=master)](https://travis-ci.org/eliasjpr/schema-validations)

Schemas come to solve a simple problem. Sometimes we would like to have type-safe guarantee params when parsing HTTP parameters or Hash(String, String) for a request moreover; Schemas is to resolve precisely this problem with the added benefit of performing business rules validation to have the params adhere to a `"business schema."`

Schemas are beneficial, in my opinion, ideal, for when defining API Requests, Web Forms, JSON, YAML.  Schema-Validation Takes a different approach and focuses a lot on explicitness, clarity, and precision of validation logic. It is designed to work with any data input, whether it’s a simple hash, an array or a complex object with deeply nested data.

Each validation is encapsulated by a simple, stateless predicate that receives some input and returns either true or false. Those predicates are encapsulated by rules which can be composed together using predicate logic, meaning you can use the familiar logic operators to build up a validation schema.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  schemas:
    github: eliasjpr/schema-validation
```

## Usage

```crystal
require "schemas"
```

## Defining Self Validated Schemas

Schemas are defined as value objects, meaning structs, which are NOT mutable,
making them ideal to pass schema objects as arguments to constructors.

```crystal
class ExampleController
  getter params : Hash(String, String)

  def initialize(@params)
  end

  schema("User") do
    param email : String
    param name : String, size: (1..20)
    param age : Int32, gte: 24, lte: 25, message: "Must be 24 and 30 years old"
    param alive : Bool, eq: true
    param childrens : Array(String)
    param childrens_ages : Array(Int32)

    schema("Address") do
      param street : String, size: (5..15)
      param zip : String, match: /\d{5}/
      param city : String, size: 2, in: %w[NY NJ CA UT]
    end

    def some_method(arg)
      ...do something
    end
  end
end
```

### Schema defined methods

```crystal
ExampleController::User.from_json(pyaload: String)
ExampleController::User.from_yaml(pyaload: String)
ExampleController::User.new(params: Hash(String, String))
```

### Schema instance methods

```crystal
getters for each of the params
valid?
validate!
rules
params
```

## Example parsing HTTP Params

```crystal
params = HTTP::Params.parse(
  "email=test@example.com&name=john&age=24&alive=true&" +
  "childrens=Child1,Child2&childrens_ages=1,2&" +
  # Nested Params
  "address.city=NY&address.street=Sleepy Hollow&address.zip=12345"
)

subject = ExampleController.new(params.to_h)
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

user = ExampleController::User.from_json(json, "user")
```

## Example parsing from YAML

 ```crystal
 ```

# Validations

You can also perform validations for existing objects without the use of Schemas. 

```crystal
class User < Model
  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)

  validation do
    # To use a custom validator, this will enable the predicate `unique_record` 
    # which is derived from the class name minus `validator`
    use UniqueRecordValidator

    # Use the `custom` class name predicate as follow
    validate email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!", unique_record: true
    validate name, size: (1..20)
    validate age, gte: 18, lte: 25, message: "Must be 24 and 30 years old"
    validate alive, eq: true
    validate childrens
    validate childrens_ages
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end
end
```

## Custom Validations

Simply create a class `{Name}Validator` with the following signature:

```crystal
class UniqueRecordValidator
  getter :record, :message

  def initialize(@record : UserModel, @message : String)
  end

  def valid?
    false
  end
end
```

Notice that `unique_record:` corresponds to `UniqueRecord`Validator.

### Existing Validation Predicates

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

### Defining your own predicates

You can define your custom predicates by simply creating a custom validator or creating methods in the `Schema::Validators` module ending with `?` and it should return a `boolean`. For example:

```crystal
module RegularExpression
  def match?(value : String, regex : Regex)
    !value.match(regex).nil?
  end
end

module Schema
  module Validators
    include RegularExpression
  end
end

```

The differences between a custom validator and a method predicate are:

- Custom validators receive an instance of the object as a `record` instance var.
- Method predicates must have 2 arguments. The actual value and the value to compare agaisnt. The comparing value is the value of the predicate. Eg. `match: /\w+@\w+\.\w{2,3}/`, the compare value is `/\w+@\w+\.\w{2,3}/`

## Development

> Note: This is subject to modifications for improvement.
> Submit ideas as issues before opening a pull request.


## Contributing

1. Fork it (<https://github.com/your-github-user/schemas/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [your-github-user](https://github.com/your-github-user) Elias J. Perez - creator, maintainer
