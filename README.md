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

  schema User do
    param email : String, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
    param name : String, size: (1..20)
    param age : Int32, gte: 24, lte: 25, message: "Must be 24 and 30 years old"
    param alive : Bool, eq: true
    param childrens : Array(String)
    param childrens_ages : Array(Int32)

    schema Address do
      param street : String, size: (5..15)
      param zip : String, match: /\d{5}/
      param city : String, size: 2, in: %w[NY NJ CA UT]

      schema Location do
        param longitude : Float32
        param latitute : Float32
      end
    end

    def some_method(arg)
      ...do something
    end
  end
end
```

### Schema class methods

```crystal
ExampleController::User.from_json(pyaload: String)
ExampleController::User.from_yaml(pyaload: String)
ExampleController::User.new(params: Hash(String, String))
```

### Schema instance methods

```crystal
getters   - For each of the params
valid?    - Bool
validate! - True or Raise Error
errors    - Errors(T, S)
rules     - Rules(T, S)
params    - Original params payload
to_json   - Outputs JSON
to_yaml   - Outputs YAML
```

## Example parsing HTTP Params (With nested params)

```crystal
params = HTTP::Params.parse(
        "email=test@example.com&name=john&age=24&alive=true&" +
        "childrens=Child1,Child2&childrens_ages=1,2&" +
        # Nested params
        "address.city=NY&address.street=Sleepy Hollow&address.zip=12345&" +
        "address.location.longitude=41.085651&address.location.latitute=-73.858467"
      )

subject   = ExampleController.new(params.to_h)
```

Accessing the generated schemas:

```crystal
user      = subject.user     - ExampleController::User
address   = user.address     - ExampleController::User::Address
location  = address.location - ExampleController::User::Address::Location
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

### Defining Your Own Predicates

You can define your custom predicates by simply creating a custom validator or creating methods in the `Schema::Validators` module ending with `?` and it should return a `boolean`. For example:

```crystal
class User < Model
  property email : String
  property name : String
  property age : Int32
  property alive : Bool
  property childrens : Array(String)
  property childrens_ages : Array(Int32)

  validation do
    ...
    params password : String, presence: true

    predicates do
      def presence?(password : String, _other : String) : Bool
        !value.nil?
      end
    end
  end

  def initialize(@email, @name, @age, @alive, @childrens, @childrens_ages)
  end
end
```

The differences between a custom validator and a method predicate are:

- Custom validators receive an instance of the object as a `record` instance var.
- Custom validators allow for more control over validations.
- Predicates are assertions against the class properties (instance var).
- Predicates matches property value with predicate value.

### Built in Predicates

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

Additional params

```crystal
message - Error message to display
nilable - Allow nil, true or false
```

## Development (Help Wanted!)

API subject to change until marked as released version

Things left to do:

- [ ] Validate nested - When calling `valid?(:nested)` validates sub schemas.
- [ ] Build nested yaml/json- Currently json and yaml do not support the sub schemas.
- [ ] Document Custom Parser for custom types. Currently the library supports parsing to Custom Types, but yet needs to be documented with a working example

## Contributing

1. Fork it (<https://github.com/your-github-user/schemas/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [@eliasjpr](https://github.com/eliasjpr) Elias J. Perez - creator, maintainer
