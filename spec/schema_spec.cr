require "./spec_helper"
require "http"

class ExampleController
  getter params : Hash(String, String)

  def initialize(@params)
  end

  schema User do
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
        param longitude : Float32
        param latitute : Float32
      end
    end
  end
end

describe Schema do
  context "for Hash(String, String)" do
    it "validates params" do
      params = HTTP::Params.parse(
        "email=test@example.com&name=john&age=24&alive=true&" +
        "childrens=Child1,Child2&childrens_ages=1,2&" +
        "address.city=NY&address.street=Sleepy Hollow&address.zip=12345&" +
        "address.location.longitude=41.085651&address.location.latitute=-73.858467"
      )

      subject = ExampleController.new(params.to_h)
      user = subject.user
      address = user.address
      location = address.location

      user.valid?.should be_true
      address.valid?.should be_true
      location.valid?.should be_true
    end
  end
end
