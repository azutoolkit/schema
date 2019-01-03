module Validations
  module Inclusion
    def in?(value, in : Array)
      in.includes?(value)
    end

    def in?(value, in : Range)
      in.includes?(value)
    end
  end
end
