require "./spec_helper"

class ContractWrapper
  contract("User") do
    param email : String, length: (50..50), regex: /\w+@\w+\.\w{2,}/
    param name : String, length: (1..20)
    param age : Int32, gte: 58, eq: 24
    param alive : Bool, eq: false
    param childrens : Array(String)
    param childrens_ages : Array(Int32)
  end

  def initialize(@params : Hash(Contract::Key, Contract::Validation::Value))
  end
end

describe "Contract::Definition" do
  params = {} of Contract::Key => Contract::Validation::Value
  params["email"] = "fake_email@example.com"
  params["name"] = "Fake name"
  params["age"] = 37
  params["alive"] = true
  params["childrens"] = ["Child 1", "Child 2"]
  params["childrens_ages"] = [9, 12]

  it "defines a contract object" do
    subject = ContractWrapper.new(params)

    subject.user.should be_a ContractWrapper::User

    subject.user.responds_to?(:valid?).should be_true
    subject.user.responds_to?(:valid!).should be_true
    subject.user.responds_to?(:error).should be_true
    subject.user.responds_to?(:errors).should be_true
    subject.user.responds_to?(:validate).should be_true
  end
end
