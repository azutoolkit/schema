macro contract(klass)
  def {{klass.id.downcase}}
    @{{klass.id.downcase}} ||= {{klass.id}}.new(params)
  end

  struct {{klass.id}}
    include Definition

    {{yield}}
  end
end
