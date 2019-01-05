require "./spec_helper"
require "http"

describe Schema do
  context "for Hash(String, String)" do
    it "validates params" do
      params = HTTP::Params.parse(
        "email=test@example.com&name=john&age=24&alive=true&" +
        "childrens=Child1,Child2&childrens_ages=1,2&" +
        "address.city=NY&address.street=Sleepy Hollow&address.zip=12345"
      )

      subject = ExampleController.new(params.to_h)
      user = subject.user
      address = user.address

      user.valid?.should be_true
      address.valid?.should be_true
    end
  end
end
