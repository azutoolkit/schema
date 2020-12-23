require "./spec_helper"

struct User
  include Schema::Definition

  getter email : String
  getter name : String
  getter age : Int32
  getter alive : Bool
  getter childrens : Array(String)
  getter childrens_ages : Array(Int32)

  class Address
    include Schema::Definition

    getter city : String
    getter location : Location
    getter phone : Phone

    class Location
      include Schema::Definition
      getter latitude : Float32
    end
  
    class Phone
      include Schema::Definition
      getter number : String
    end
  end
end

describe "Schema::Definition" do
  it "defines a schema from JSON" do
    json = %({"user": {
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
  end
end
