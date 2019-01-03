module Validations
  module LessThanOrEqual
    def lte?(value : Int, compare : Int)
      value <= compare
    end

    def lte?(value : Float, compare : Float)
      value <= compare
    end
  end
end
