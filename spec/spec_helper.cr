require "spec"
require "../src/schema"

struct Example
  include Schema::Definition
  include Schema::Validation

  getter email : String
  getter name : String
  getter age : Int32
  getter alive : Bool
  getter childrens : Array(String)
  getter childrens_ages : Array(Int32)
  getter address : Address

  validate :email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"

  class Address
    include Schema::Definition

    getter street : String
    getter zip : String
    getter city : String
    getter location : Location
  end

  class Location
    include Schema::Definition
    getter longitude : Float64
    getter latitude : Float64
    getter useful : Bool
  end
end


