module Validators
  module LessThan
    def lt?(value : Int, compare : Int)
      value < compare
    end

    def lt?(value : Float, compare : Float)
      value < compare
    end
  end
end
