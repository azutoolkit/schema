module Schema
  class Errors(T, S) < Array(Error(T, S))
    def <<(rule : T)
      self << Error(T, S).from(rule)
    end

    def <<(tuple : Tuple(Symbol, String))
      self << Error(T, S).from_tuple(tuple)
    end

    def <<(error : Error(T, S))
      push error unless includes?(error)
    end
  end
end
