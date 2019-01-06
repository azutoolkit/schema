require "./validation"

module Schema
  class Rules(T, S) < Array(T)
    @errors = Errors(T, S).new

    def errors
      reduce(@errors) do |errors, rule|
        errors << rule unless rule.valid?
        errors
      end
    end
  end
end
