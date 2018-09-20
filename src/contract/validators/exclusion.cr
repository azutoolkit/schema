module Validators
  class Exclusion < Validator
    def valid?
      case expected_value
      when Array
        case value
        when String  then !expected_value.as(Array(String)).includes?(value.as(String))
        when Int32   then !expected_value.as(Array(Float32)).includes?(value.as(Int32))
        when Float32 then !expected_value.as(Array(Float32)).includes?(value.as(Float32))
        end
      when Range
        case value
        when Int32   then !expected_value.as(Range).includes?(value.as(Int32))
        when Float32 then !expected_value.as(Range).includes?(value.as(Float32))
        end
      else
        raise "Invalid Type"
      end
    end

    def message
      @message || "must not be in #{expected_value}"
    end
  end
end
