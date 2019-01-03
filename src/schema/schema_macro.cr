macro schema(klass)
  def {{klass.id.downcase}}
    @{{klass.id.downcase}} ||= {{klass.id}}.new(params)
  end

  struct {{klass.id}}
    include Contract::Definition

    {{yield}}
  end
end
