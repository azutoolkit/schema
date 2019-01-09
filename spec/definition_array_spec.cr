require "./spec_helper"
require "http"

class ConvertTo(T)
  def convert(asType : Address.class)
    p @value.to_f64
    Address.new
  end
end

struct Example
  include JSON::Serializable
  include YAML::Serializable
  include Schema::Definition
  include Schema::Validation

  param addresses : Array(Address)
end

struct Address
  getter city : String?
  getter latitude : Float32?
end

describe Schema do
  params = {
    "addresses[0].city"     => "NY",
    "addresses[0].latitude" => "1234.12",
    "addresses[1].city"     => "NJ",
    "addresses[1].latitude" => "1254.12",
  }

  it "defines a schema from an array of custom types" do
    addresses = Example.new(params.to_h)

    addresses.should be_a Array(Address)
  end
end
