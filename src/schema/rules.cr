require "./validation"

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

struct Error(T, S)
  def self.from(rule : T)
    new(rule.record, rule.message)
  end

  def initialize(record : S, error : String)
  end
end

class Rules(T, S) < Array(T)
  def errors
    reduce([] of Error(T, S)) do |errors, rule|
      errors << Error(T, S).from(rule) unless rule.valid?
      errors
    end
  end
end
