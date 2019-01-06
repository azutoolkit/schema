module Schema
  struct Error(T, S)
    def self.from(rule : T)
      new(rule.record, rule.message)
    end

    def self.from_tuple(tuple : Tuple(Symbol, String))
      new(tuple.first, tuple.last)
    end

    def initialize(@record : S, @message : String)
    end

    def field
      @record
    end

    def message
      @message
    end
  end
end
