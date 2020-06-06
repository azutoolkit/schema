macro schema(name=nil, nilable=false)
  {%if name!=nil%}
  param {{name.id.underscore}} : {{name.id}}, inner: true, nilable: required
  {% end %}

  {%if name!=nil%}
  struct {{name.id}}
  include JSON::Serializable
  include YAML::Serializable
  include Schema::Definition
  include Schema::Validation
  {% end %}

  {{yield}}

  {%if name!=nil%}
  end
  {% end %}
end

macro validation
  include Schema::Validation

  {{yield}}
end
