require "./spec_helper"
require "http"

struct ExampleController
  include JSON::Serializable
  include YAML::Serializable
  include Schema::Definition
  include Schema::Validation

  schema do
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
        param longitude : Float64
        param latitude : Float64
        param useful : Bool, eq: true
      end
    end
  end
end

describe Schema do
  it "defines schema from Hash(String, String)" do
    params = HTTP::Params.parse(
      "email=test@example.com&name=john&age=24&alive=true&" +
      "childrens=Child1,Child2&childrens_ages=1,2&" +
      "address.city=NY&address.street=Sleepy Hollow&address.zip=12345&" +
      "address.location.longitude=41.085651&address.location.latitude=-73.858467&address.location.useful=true" +
      ""
    )

    user = ExampleController.new(params.to_h)

    user.valid?.should be_true
    user.address.valid?.should be_true
    user.address.location.valid?.should be_true
  end

  it "defines a schema from JSON" do
    json = %({ "user": {
      "email": "fake@example.com",
      "name": "Fake name",
      "age": 25,
      "alive": true,
      "childrens": ["Child 1", "Child 2"],
      "childrens_ages": [9, 12],
      "address": {
        "city": "NY",
        "street": "sleepy",
        "zip": "12345",
        "location": {
          "longitude": 123.123,
          "latitude": 342454.4321,
          "useful": true
        }
      }
    }})

    subject = ExampleController.from_json(json, "user")

    subject.email.should eq "fake@example.com"
    subject.name.should eq "Fake name"
    subject.age.should eq 25
    subject.alive.should eq true
    subject.childrens.should eq ["Child 1", "Child 2"]
    subject.childrens_ages.should eq [9, 12]
    subject.address.city.should eq "NY"
    subject.address.street.should eq "sleepy"
    subject.address.zip.should eq "12345"
    subject.address.location.longitude.should eq 123.123
  end

  it "validates schema and sub schemas" do
    json = %({ "user": {
      "email": "fake@example.com",
      "name": "Fake name",
      "age": 25,
      "alive": true,
      "childrens": ["Child 1", "Child 2"],
      "childrens_ages": [9, 12],
      "address": {
        "city": "NY",
        "street": "slepy",
        "zip": "12345",
        "location": {
          "longitude": 123.122,
          "latitude": 342454.4321,
          "useful": false
        }
      }
    }})

    subject = ExampleController.from_json(json, "user")

    subject.valid?.should be_falsey
  end
end
