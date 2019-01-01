# Contracts

Contracts comes to solve a simple problem. Sometime we would like to have type safe
guarantee params when parsing HTTP parameters or Hash(String, String) for a request 
and Contracts are to resolve exactly this problem with the added benefit of performing 
business rules validation having the params to adhere to a contract.

Contracts are very useful, in my opinion ideal, for when defining web services APIs.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  contracts:
    github: your-github-user/contracts
```

## Usage

```crystal
require "contracts"
```

```crystal 
class ExampleController
  getter params : Hash(String, String)

  def initialize(@params)
  end

  contract("User") do
    param email : String, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
    param name : String, size: (1..20)
    param age : Int32, gte: 24, lte: 25, message: "Must be 24 and 30 years old"
    param alive : Bool, eq: true
    param childrens : Array(String)
    param childrens_ages : Array(Int32)

    contract("Address") do
      param street : String, size: (5..15)
      param zip : String, match: /\d{5}/
      param city : String, size: 2, in: %w[NY NJ CA UT]
    end
  end
end

params = HTTP::Params.parse(
  "email=test@example.com&name=john&age=24&alive=true&" +
  "childrens=Child1,Child2&childrens_ages=1,2&" +
  // Nested Params
  "address.city=NY&address.street=Sleepy Hollow&address.zip=12345"
)

subject = ExampleController.new(params.to_h)
user = subject.user
address = user.address

user.valid?.should be_true
address.valid?.should be_true
```

### Casting to Custom Types

This is WIP

```crystal
class CustomType
  include Contract::CastAs(CustomType)

  def initialize(@value : String)
  end

  def value
    convert(self.class)
  end

  // Provide a convert method to handle the casting
  def convert(asType : self.class)
    @value.split(",").map { |i| i.to_i32 }
  end
end
```

### Custom Validations

This is WIP.

Create a module that extends from Validation. 

```crystal
module Validators
  module Equal
    def eq?(value, other)
      value == other
    end
  end
end

contract("User") do 
  param name : String, eq: "John
end
```

Notice that `eq:` corresponds to `eq?`. 
This is how you can use custom validatins

## Development

> Note: This is subject to modifications for improvement. 
> Submit ideas as issues before opening a pull request.


## Contributing

1. Fork it (<https://github.com/your-github-user/contracts/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [your-github-user](https://github.com/your-github-user) Elias J. Perez - creator, maintainer
