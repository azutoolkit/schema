module GreaterThan
  def gt?(value : Int, compare : Int)
    value > compare
  end

  def gt?(value : Float, compare : Float)
    value > compare
  end

  def gt?(value : Time, compare : Time)
    value > compare
  end
end
