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
  end
end
```

Example parsing HTTP Params
```crystal
params = HTTP::Params.parse(
  "email=test@example.com&name=john&age=24&alive=true&" +
  "childrens=Child1,Child2&childrens_ages=1,2&" +
  # Nested Params
  "address.city=NY&address.street=Sleepy Hollow&address.zip=12345"
)

subject = ExampleController.new(params.to_h)
```

Schemas are defined as value objects, meaning structs, which are NOT mutable,
making them ideal to pass schema objects as arguments to constructors.

```crystal
user = subject.user
address = user.address

user.valid?.should be_true
address.valid?.should be_true
```

### Custom Validations

Simply create a {Class}Validator with the following signature

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

Then in your class definition

```crystal
class UserModel
  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)

  validation do
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

Notice that `unique_record:` corresponds to `UniqueRecord`Validator.

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
