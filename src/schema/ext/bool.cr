@[Schema::Definition::Scalar]
# :nodoc:
struct Bool
  # Put `self` as an HTTP param into the *builder* at *key*.
  def to_http_param(builder : HTTP::Params::Builder, key : String)
    builder.add(key, to_http_param)
  end

  # Return `self` as an HTTP param string.
  def to_http_param
    to_s
  end

  # Parse `self` from an HTTP param, returning
  # - `true` on `"true"` or `"1"`
  # - `false` on `"false"` or `"0"`
  def self.from_http_param(value : String)
    case value.downcase
    when "1", "true"  then true
    when "0", "false" then false
    else
      raise TypeCastError.new
    end
  end
end
