module Validations
  module RegularExpression
    def match?(value : String, regex : Regex)
      !value.match(regex).nil?
    end
  end
end
