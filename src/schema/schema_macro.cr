macro schema(name)
  def {{name.id.downcase}} : {{name.id}}
    @{{name.id.downcase}} ||= {{name.id}}.new(params)
  end

  def {{name.id.downcase}}_from_json(payload : String) : {{name.id}}
    @{{name.id.downcase}} ||= {{name.id}}.from_json(payload)
  end

  def {{name.id.downcase}}_from_yaml(payload : String) : {{name.id}}
    @{{name.id.downcase}} ||= {{name.id}}.from_yaml(payload)
  end

  struct {{name.id}}
    include Schema::Definition
    include Schema::Validation

    {{yield}}
  end
end

macro validation
   include Schema::Validation

  {{yield}}
end
