require "./spec_helper"

describe "Integration test of Definitions and Validations" do
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

  it "builds from HTTP::Params and validates" do
    example = Example.from_urlencoded(params)
    example.valid?.should be_true
    example.validate!.should be_true
  end
end
