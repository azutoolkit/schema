require "./spec_helper"

class ContractWrapper
  contract("User") do
    param email : String, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"
    param name : String, size: (1..20)
    param age : Int32, gte: 24, lte: 25, message: "Must be 24 and 30 years old"
    param alive : Bool, eq: true
    param childrens : Array(String)
    param childrens_ages : Array(Int32)
  end
end

describe "Contract::Definition" do
  params = {
    "email"          => "fake@example.com",
    "name"           => "Fake name",
    "age"            => "25",
    "alive"          => "true",
    "childrens"      => "Child 1,Child 2",
    "childrens_ages" => "9,12",
  }

  it "defines a contract object" do
    subject = ContractWrapper::User.new(params)

    subject.should be_a ContractWrapper::User
    subject.email.should eq "fake@example.com"
    subject.name.should eq "Fake name"
    subject.age.should eq 25
    subject.alive.should eq true
    subject.childrens.should eq ["Child 1", "Child 2"]
    subject.childrens_ages.should eq [9, 12]

    subject.valid?.should be_truthy
  end
end
