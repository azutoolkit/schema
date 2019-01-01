module Validators
  module Size
    def size?(value, size : Int)
      value.size == size
    end

    def size?(value, size : Range)
      size.includes?(value.size)
    end
  end
end
