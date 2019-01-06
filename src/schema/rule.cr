module Schema
  class Rule
    include Schema::Validators

    getter :record, :message

    def initialize(@record : Symbol, @message : String, &block : Rule -> Bool)
      @block = block
    end

    def valid?
      @block.call(self)
    end
  end
end
