module Schema
  module CastAs(T)
    def value : T
      convert(T)
    end

    def convert(asType : String.class)
      @value
    end

    def convert(asType : Bool.class)
      [1, "true", "yes"].includes?(@value)
    end

    def convert(asType : Int32.class)
      @value.to_i32
    end

    def convert(asType : Int64.class)
      @value.to_i64
    end

    def convert(asType : Float32.class)
      @value.to_f32
    end

    def convert(asType : Float64.class)
      @value.to_f64
    end
  end

  class ConvertTo(T)
    include CastAs(T)

    def initialize(@value : String)
    end

    def convert(asType : Address.class)
      p @value.to_f64
      Address.new
    end
  end
end
