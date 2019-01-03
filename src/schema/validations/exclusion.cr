module Validations
  module Exclusion
    def exclude?(value, exclusion : Array)
      !exclusion.includes?(value)
    end

    def exclude?(value, exclusion : Range)
      !exclusion.includes?(value)
    end
  end
end
