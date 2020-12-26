module Inclusion
  def in?(value, included : Array)
    included.includes?(value)
  end

  def in?(value, included : Range)
    included.includes?(value)
  end
end
