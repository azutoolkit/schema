require "spec"
require "../src/schema"

macro assert_raise(object, query, error, message, path)
  expect_raises {{error}} do
    begin
      {{object}}.from_query({{query}})
    rescue ex : {{error}}
      ex.message.should eq {{message}}
      ex.path.should eq {{path}}
      raise ex
    end
  end
end

def escape(string : String)
  String.build do |io|
    URI.encode(string, io) do |byte|
      URI.unreserved?(byte) || byte.chr == '=' || byte.chr == '&'
    end
  end
end

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
  getter subnested : Array(SubNested)

  validate :email, match: /\w+@\w+\.\w{2,3}/, message: "Email must be valid!"

  struct Address
    include Schema::Definition

    getter street : String
    getter zip : String
    getter city : String
    getter location : Location
  end

  struct Location
    include Schema::Definition
    getter longitude : Float64
    getter latitude : Float64
    getter useful : Bool
  end

  struct SubNested
    include Schema::Definition
    getter name : String
  end
end
