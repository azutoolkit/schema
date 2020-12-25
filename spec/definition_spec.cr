require "./spec_helper"

describe Schema::Definition do
  params = HTTP::Params.build do |p|
    p.add("email", "test@example.com")
    p.add("name", "john")
    p.add("age", "24")
    p.add("alive", "true")
    p.add("childrens[]", "Child1,Child2")
    p.add("childrens_ages[]", "12")
    p.add("childrens_ages[]", "18")
    p.add("address[city]", "NY")
    p.add("address[street]", "Sleepy Hollow")
    p.add("address[zip]", "12345")
    p.add("address[location][longitude]", "41.085651")
    p.add("address[location][latitude]", "-73.858467")
    p.add("address[location][useful]", "true")
  end

  p params
  
  it "defines schema from Hash(String, String)" do
    user = Example.from_urlencoded(params)
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

    subject = Example.from_json(json, "user")

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

    subject = Example.from_json(json, "user")
  end
end
