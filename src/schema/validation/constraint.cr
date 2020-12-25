module Schema
  class Constraint
    include Schema::Validators
    @errors = Array(Schema::Error).new

    def initialize(&block : Constraint, Array(Schema::Error) -> Nil)
      @block = block
    end

    def valid? : Array(Schema::Error)
      @block.call(self, @errors)
      @errors
    end
  end
end
