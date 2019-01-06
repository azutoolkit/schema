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

      macro finished
        __process_params
      end
    end

    private macro __process_params
      JSON.mapping(
        {% for name, options in FIELD_OPTIONS %}
          {% type = options[:type] %}
          {% nilable = options[:nilable] != nil ? true : false %}
          {% key = options[:key] != nil ? options[:key] : name.downcase.stringify %}
          {{name}}: { type: {{type}}, nilable: {{nilable}}, getter: true,  },
        {% end %}
      )

      YAML.mapping(
        {% for name, options in FIELD_OPTIONS %}
          {% type = options[:type] %}
          {% nilable = options[:nilable] != nil ? true : false %}
          {% key = options[:key] != nil ? options[:key] : name.downcase.stringify %}
          {{name}}: { type: {{type}}, nilable: {{nilable}}, getter: true, },
        {% end %}
      )

      getter params = {} of String => String
      private getter path : Array(String)?

      def initialize(params : Hash(String, String))
        @params = params.not_nil!
        {% for name, options in FIELD_OPTIONS %}
          {% field_type = CONTENT_ATTRIBUTES[name][:type] %}
          {% key = name.id %}
          @path = self.class.name.split("::").not_nil!
          @path.not_nil!.shift(2)

          field_{{name.id}} =
            @params[{{key.stringify}}]? || @params["#{path.not_nil!.join(".").downcase}.{{key}}"]

          {% if field_type.is_a?(Generic) %}
            {% sub_type = field_type.type_vars %}
            @{{name.id}} = field_{{name.id}}.split(",").map do |item|
              Schema::ConvertTo({{sub_type.join('|').id}}).new(item).value
            end
          {% else %}
            @{{name.id}} = Schema::ConvertTo({{field_type}}).new(field_{{name.id}}).value
          {% end %}
        {% end %}
      end
    end
  end
end
