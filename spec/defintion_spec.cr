require "./spec_helper"

describe "Schema::Definition" do
  params = {
    "email"          => "fake@example.com",
    "name"           => "Fake name",
    "age"            => "25",
    "alive"          => "true",
    "childrens"      => "Child 1,Child 2",
    "childrens_ages" => "9,12",
  }

  it "defines a schema object from Hash(String, Stirng)" do
    subject = SchemaWrapper::User.new(params)

    subject.should be_a SchemaWrapper::User
    subject.email.should eq "fake@example.com"
    subject.name.should eq "Fake name"
    subject.age.should eq 25
    subject.alive.should eq true
    subject.childrens.should eq ["Child 1", "Child 2"]
    subject.childrens_ages.should eq [9, 12]
    subject.valid?.should be_truthy
  end

  it "defines a schema from JSON" do
    json = %({ "user": {
      "email": "fake@example.com",
      "name": "Fake name",
      "age": 25,
      "alive": true,
      "childrens": ["Child 1", "Child 2"],
      "childrens_ages": [9, 12]
    }})

    subject = SchemaWrapper::User.from_json(json, "user")

    subject.email.should eq "fake@example.com"
    subject.name.should eq "Fake name"
    subject.age.should eq 25
    subject.alive.should eq true
    subject.childrens.should eq ["Child 1", "Child 2"]
    subject.childrens_ages.should eq [9, 12]
    subject.valid?.should be_truthy
  end
end
