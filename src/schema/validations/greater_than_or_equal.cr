module GreaterThanOrEqual
  def gte?(value : Int, compare : Int)
    value >= compare
  end

  def gte?(value : Float, compare : Float)
    value >= compare
  end
end
