require "./validators/*"

module Schema
  module Validators
    include Equal
    include Exclusion
    include GreaterThan
    include GreaterThanOrEqual
    include Inclusion
    include LessThan
    include LessThanOrEqual
    include RegularExpression
    include Size
    include Presence
  end
end
