module Schema
  class ParseError < Exception
    getter path

    def initialize(message, @path : Array(String))
      super(message)
    end
  end
end