module Presence
  def presence?(value, other)
    (!value.nil? && !value.empty?)
  end
end
