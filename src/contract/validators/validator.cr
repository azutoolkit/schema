module Validators
  abstract class Validator
    property attribute : String | Symbol
    property value : Contract::Validation::Value
    property expected_value : String | Range(Int32, Int32) | Nil | Regex | Int32 | Bool

    def initialize(@attribute, @value, @expected_value = nil, @message : String? = nil)
    end

    def valid?
    end

    def message
      @message || "must be equal to #{expected_value}"
    end
  end
end
