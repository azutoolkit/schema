module Contract
  module Definition
    macro param(attribute, **options)
      {% FIELD_OPTIONS[attribute.var] = options %}
      {% CONTENT_attributes[attribute.var] = options || {} of Nil => Nil %}
      {% CONTENT_attributes[attribute.var][:type] = attribute.type %}
    end

    macro included
      CONTENT_attributes = {} of Nil => Nil
      FIELD_OPTIONS = {} of Nil => Nil

      macro finished
        __process_params
      end
    end

    private macro __process_params
      {% for name, options in FIELD_OPTIONS %}
        {% type = options[:type] %}
        {% property_name = name.id %}
        {% suffixes = options[:raise_on_nil] ? ["?", ""] : ["", "!"] %}

        property{{suffixes.first.id}} {{name.id}} : {{type.id}}

        def {{name.id}}{{suffixes[1].id}}
          raise {{@type.name.stringify}} + "#" + {{name.stringify}} + " cannot be nil" if @{{name.id}}.nil?
          @{{name.id}}.not_nil!
        end

        def {{property_name}}{{suffixes[1].id}}
          raise {{@type.name.stringify}} + "#" + {{property_name.stringify}} + " cannot be nil" if @{{property_name}}.nil?
          @{{property_name}}.not_nil!
        end
      {% end %}

      getter rules = Rules.new
      getter params : Hash(String, String)

      def initialize(@params : Hash(String, String))
        {% for name, options in FIELD_OPTIONS %}
          {% field_type = CONTENT_attributes[name][:type] %}
          {% key = name.id %}
          field_{{name.id}} =
            @params[{{key.stringify}}]? || @params["#{self.class.name.split("::").last.downcase}.{{key}}"]


          {% if field_type.is_a?(Generic) %}
            {% sub_type = field_type.type_vars %}
            @{{name.id}} = field_{{name.id}}.split(",").map do |item|
              Schema::ConvertTo({{sub_type.join('|').id}}).new(item).value
            end
          {% else %}
            @{{name.id}} = Schema::ConvertTo({{field_type}}).new(field_{{name.id}}).value
          {% end %}
        {% end %}

        load_schema_rules
      end

      def valid?
        rules.errors.empty?
      end

      def valid!
        valid? || raise Schema::Error.new(errors)
      end

      private def load_schema_rules
        {% for name, options in FIELD_OPTIONS %}
          {% field_type = CONTENT_attributes[name][:type] %}
          {% key = name.id %}

          rules << Rule.new(:{{name.id}}, {{options[:message]}} || "") do |rule|
            {% for key, expected_value in options %}
              {% if !["message", "type"].includes?(key.stringify) %}
              rule.{{key}}?(@{{name.id}}.as({{field_type}}), {{expected_value}}) &
              {% end %}
            {% end %}
            true
          end
        {% end %}
      end
    end
  end
end
