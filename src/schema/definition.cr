require "json"
require "yaml"

module Schema
  module Definition
    macro included
      CONTENT_ATTRIBUTES = {} of Nil => Nil
      FIELD_OPTIONS = {} of Nil => Nil

      macro finished
        __process_params
      end
    end

    macro param(attribute, **options)
      {% FIELD_OPTIONS[attribute.var] = options %}
      {% CONTENT_ATTRIBUTES[attribute.var] = options || {} of Nil => Nil %}
      {% CONTENT_ATTRIBUTES[attribute.var][:type] = attribute.type %}
    end

    private macro __process_params
      {% for name, options in FIELD_OPTIONS %}
        {% type = options[:type] %}
        {% nilable = options[:nilable] != nil ? true : false %}
        {% key = options[:key] != nil ? options[:key] : name.downcase.stringify %}
        @[JSON::Field(emit_null: {{nilable}}, key: {{key}})]
        @[YAML::Field(emit_null: {{nilable}}, key: {{key}})]
        getter {{name}} : {{type}}
      {% end %}

      def initialize(params : Hash(String, String) | HTTP::Params | _, prefix = "")
        {% for name, options in FIELD_OPTIONS %}
          {% field_type = CONTENT_ATTRIBUTES[name][:type] %}
          {% key = name.id %}
          key = "#{prefix}{{key.id}}"

          {% if options[:inner] %}
            @{{name.id}} = {{field_type}}.new(params, "#{key}.")
          {% else %}
            {% if field_type.is_a?(Generic) %}
              {% sub_type = field_type.type_vars %}
              @{{name.id}} = params[key].split(",").map do |item|
                Schema::ConvertTo({{sub_type.join('|').id}}).new(item).value
              end
            {% else %}
              @{{name.id}} = Schema::ConvertTo({{field_type}}).new(params[key]).value
            {% end %}
          {% end %}
        {% end %}
      end
    end
  end
end
