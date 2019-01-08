require "json"
require "yaml"

module Schema
  module Definition
    macro param(attribute, **options)
      {% FIELD_OPTIONS[attribute.var] = options %}
      {% CONTENT_ATTRIBUTES[attribute.var] = options || {} of Nil => Nil %}
      {% CONTENT_ATTRIBUTES[attribute.var][:type] = attribute.type %}
    end

    macro included
      CONTENT_ATTRIBUTES = {} of Nil => Nil
      FIELD_OPTIONS = {} of Nil => Nil

      # Custom hook method to initialize dependents schemas
      protected def after_schema_initialize(params : Hash(String, String))
      end

      macro finished
        __process_params
      end
    end

    private macro __process_params
      {% sub_schema = "" %}
      {% path = @type.stringify.split("::") || "" %}

      {% if path.size > 1 %}
        {% sub_schema = path[2..-1].join(".").downcase %}
      {% end %}

      {% for name, options in FIELD_OPTIONS %}
        {% type = options[:type] %}
        {% nilable = options[:nilable] != nil ? true : false %}
        {% key = options[:key] != nil ? options[:key] : name.downcase.stringify %}
        @[JSON::Field(emit_null: {{nilable}}, key: {{key}})]
        @[YAML::Field(emit_null: {{nilable}}, key: {{key}})]
        getter {{name}} : {{type}}
      {% end %}

      def initialize(params : Hash(String, String))
        {% for name, options in FIELD_OPTIONS %}
          {% field_type = CONTENT_ATTRIBUTES[name][:type] %}
          {% key = name.id %}

          field_{{name.id}} =
            params[{{key.stringify}}]? ||
            params["{{sub_schema.id unless sub_schema.starts_with?(".") || sub_schema.empty?}}.{{key}}"]

          {% if field_type.is_a?(Generic) %}
            {% sub_type = field_type.type_vars %}
            @{{name.id}} = field_{{name.id}}.split(",").map do |item|
              Schema::ConvertTo({{sub_type.join('|').id}}).new(item).value
            end
          {% else %}
            @{{name.id}} = Schema::ConvertTo({{field_type}}).new(field_{{name.id}}).value
          {% end %}
        {% end %}

        after_schema_initialize(params)
      end
    end
  end
end
