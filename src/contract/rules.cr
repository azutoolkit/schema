require "./validators"

class Rule
  include Validators
  getter :field, :message

  def initialize(@field : Symbol, @message : String, &block : Rule -> Bool)
    @block = block
  end

  def valid?
    @block.call(self)
  end
end

struct Error
  def self.from(rule : Rule)
    new(rule.field, rule.message)
  end

  def initialize(field : Symbol, error : String)
  end
end

class Rules < Array(Rule)
  def errors
    errors = [] of Error
    reduce(errors) do |errors, rule|
      errors << Error.from(rule) unless rule.valid?
      errors
    end
  end
end
