module Validators
  module Exclusion
    private def exclude?(value, exclusion : Array)
      !exclusion.includes?(value)
    end

    private def exclude?(value, exclusion : Range)
      !exclusion.includes?(value)
    end
  end
end
