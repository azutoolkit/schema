macro schema(klass)
  def {{klass.id.downcase}}
    @{{klass.id.downcase}} ||= {{klass.id}}.new(params)
  end

  struct {{klass.id}}
    include Schema::Definition
    include Schema::Validation

    {{yield}}
  end
end

macro validation
   include Schema::Validation

  {{yield}}
end
