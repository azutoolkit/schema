require "./spec_helper"

describe Contract::Cast do
  [
    {"true", true},
    {"1234", 1234},
    {"123.12", 123.12},
  ].each do |(value, expected)|
    it "casts #{typeof(value)} to #{expected.class}" do
      result = Contract::Cast.convert!(value, expected.class)
      result.should eq expected
    end
  end
end
