module Schema
  abstract class Validator
    include Schema::Predicates

    def initialize(@record)
    end

    abstract def valid? : Array(Error)
  end
end
