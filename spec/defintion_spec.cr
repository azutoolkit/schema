require "./spec_helper"
require "json"

struct User
  include JSON::Serializable
  include YAML::Serializable
  include Schema::Definition
  include Schema::Validation

  param email : String
  param name : String
  param age : Int32
  param alive : Bool
  param childrens : Array(String)
  param childrens_ages : Array(Int32)

  schema Address do
    param city : String

    schema Location do
      param latitude : Float32
    end
  end

  schema Phone do
    param number : String
  end
end

describe "Schema::Definition" do
  params = {
    "email"                     => "fake@example.com",
    "name"                      => "Fake name",
    "age"                       => "25",
    "alive"                     => "true",
    "childrens"                 => "Child 1,Child 2",
    "childrens_ages"            => "9,12",
    "phone.number"              => "123456789",
    "address.city"              => "NY",
    "address.location.latitude" => "1234.12",
  }

  it "defines a schema object from Hash(String, Stirng)" do
    subject = User.new(params)

    subject.should be_a User
    subject.email.should eq "fake@example.com"
    subject.name.should eq "Fake name"
    subject.age.should eq 25
    subject.alive.should eq true
    subject.childrens.should eq ["Child 1", "Child 2"]
    subject.childrens_ages.should eq [9, 12]

    p subject
  end

  it "defines a schema from JSON" do
    json = %({ "user": {
      "email": "fake@example.com",
      "name": "Fake name",
      "age": 25,
      "alive": true,
      "childrens": ["Child 1", "Child 2"],
      "childrens_ages": [9, 12],
      "phone": {
        "number": "123456789"
      },
      "address": {
        "city": "NY",
        "location": {
          "latitude": 12345.12
        }
      }
    }})

    subject = User.from_json(json, "user")

    subject.email.should eq "fake@example.com"
    subject.name.should eq "Fake name"
    subject.age.should eq 25
    subject.alive.should eq true
    subject.childrens.should eq ["Child 1", "Child 2"]
    subject.childrens_ages.should eq [9, 12]

    # p subject.to_json
  end
end
