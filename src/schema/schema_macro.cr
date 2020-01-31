macro schema(name)
  @[JSON::Field(key: "{{name.id.underscore}}", emit_null: true)]
  @{{name.id.underscore}} : {{name.id}}?

  def {{name.id.underscore}}
    @{{name.id.underscore}}.not_nil!
  end

  protected def after_schema_initialize(params : Hash(String, String) | HTTP::Params)
    @{{name.id.underscore}} = {{name.id}}.new(params)
  end

  struct {{name.id}}
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
