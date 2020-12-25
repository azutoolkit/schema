module Schema
  class Errors
    @errors = Array(Error).new

    forward_missing_to @errors

    def messages
      @errors.map &.message
    end
  end
end