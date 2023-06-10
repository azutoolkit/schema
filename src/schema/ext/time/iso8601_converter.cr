require "../../annotations"

@[Schema::Definition::Scalar]
struct Time
  module ISO8601Converter
    # Put *value* as a time timestamp into the *builder* at *key*.
    def self.to_http_param(value : Time, builder : HTTP::Params::Builder, key : String)
      builder.add(key, to_http_param(value))
    end

    # Return *value* as a time timestamp string.
    def self.to_http_param(value : Time)
      value.to_rfc3339
    end

    # Parse `Time` from an HTTP param as time timestamp.
    def self.from_http_param(value : String) : Time
      Time.parse_iso8601(value)
    rescue ArgumentError
      raise TypeCastError.new
    end
  end
end
