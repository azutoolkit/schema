require "spec"

class CustomType
  include CastAs(CustomType)

  def initialize(@value : String)
  end

  def value
    convert(self.class)
  end

  def convert(asType : self.class)
    @value.split(",").map { |i| i.to_i32 }
  end
end

describe CustomType do
  it "converts from String to Boolean" do
    converter = ConvertTo(Bool).new("false")
    converter.value.should eq false
  end

  it "converts from String to Int32" do
    converter = ConvertTo(Int32).new("123")
    converter.value.should eq 123
  end

  it "converts from String to Float" do
    converter = ConvertTo(Float32).new("123.321")
    converter.value.should eq 123.321_f32
  end

  it "converts from String to Custom Type" do
    converter = CustomType.new("1,2,3,4,5")
    converter.value.should eq [1, 2, 3, 4, 5]
  end
end
