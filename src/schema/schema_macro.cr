macro schema(name)
  @[JSON::Field(key: "{{name.id.downcase}}", emit_null: true)]
  @{{name.id.downcase}} : {{name.id.capitalize}}?

  def {{name.id.downcase}}
    @{{name.id.downcase}}.not_nil!
  end

  protected def after_schema_initialize(params : Hash(String, String) | HTTP::Params)
    @{{name.id.downcase}} = {{name.id.capitalize}}.new(params)
  end

  struct {{name.id.capitalize}}
    include JSON::Serializable
    include YAML::Serializable
    include Schema::Definition
    include Schema::Validation

    {{yield}}
  end
end

macro validation
  include Schema::Validation

  {{yield}}
end
