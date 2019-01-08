require "./spec_helper"
require "json"

struct User
  include JSON::Serializable
  include Schema::Definition

  schema Address do
    param city : String
  end

  param email : String
  param name : String
  param age : Int32
  param alive : Bool
  param childrens : Array(String)
  param childrens_ages : Array(Int32)
end

describe "Schema::Definition" do
  params = {
    "email"          => "fake@example.com",
    "name"           => "Fake name",
    "age"            => "25",
    "alive"          => "true",
    "childrens"      => "Child 1,Child 2",
    "childrens_ages" => "9,12",
    "address.city"   => "NY",
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

    p subject.address.city
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
        "city": "NY"
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
