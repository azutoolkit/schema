module Schema
  struct Error
    getter :field, :message

    def initialize(@field : Symbol, @message : String)
    end
  end
end
