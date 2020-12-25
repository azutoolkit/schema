module Schema
  abstract class Validator
    include Schema::Validators

    def initialize(@record)
    end

    abstract def valid? : Array(Error)
  end
end
