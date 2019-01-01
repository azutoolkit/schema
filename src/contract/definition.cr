module Definition
  TIME_FORMAT_REGEX = /\d{4,}-\d{2,}-\d{2,}\s\d{2,}:\d{2,}:\d{2,}/
  DATETIME_FORMAT   = "%F %X%z"

  macro param(attribute, **options)
    {% FIELD_OPTIONS[attribute.var] = options %}
    {% CONTENT_attributes[attribute.var] = options || {} of Nil => Nil %}
    {% CONTENT_attributes[attribute.var][:type] = attribute.type %}
  end

  macro param!(attribute, **options)
    param {{attribute}}, {{options.double_splat(", ")}}raise_on_nil: true
  end

  macro included
    CONTENT_attributes = {} of Nil => Nil
    FIELD_OPTIONS = {} of Nil => Nil

    macro finished
      __process_params
    end
  end

  private macro __process_params
    {% types = [] of Class %}

    {% for name, options in FIELD_OPTIONS %}
      {% types << options[:type] %}
      {% type = options[:type] %}
      {% property_name = name.id %}
      {% suffixes = options[:raise_on_nil] ? ["?", ""] : ["", "!"] %}
      {% if options[:json_options] %}
        @[JSON::Field({{**options[:json_options]}})]
      {% end %}
      {% if options[:yaml_options] %}
        @[YAML::Field({{**options[:yaml_options]}})]
      {% end %}

      {% if options[:comment] %}
        {{options[:comment].id}}
      {% end %}

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

    {% properties = FIELD_OPTIONS.keys.map { |p| p.id } %}
    def_equals_and_hash {{*properties}}

    def initialize(@params : Hash(String, String))
      {% for name, options in FIELD_OPTIONS %}
        {% field_type = CONTENT_attributes[name][:type] %}
        {% key = name.id %}

        {% if field_type.is_a?(Generic) %}
          {% sub_type = field_type.type_vars %}
          @{{name.id}} = @params[{{key.stringify}}].split(",").map do |item|
            Contract::ConvertTo({{sub_type.join('|').id}}).new(item).value
          end
        {% else %}
          @{{name.id}} = Contract::ConvertTo({{field_type}}).new(@params[{{key.stringify}}]).value
        {% end %}
      {% end %}
      load_contract_rules
    end

    def valid?
      rules.errors.empty?
    end

    def valid!
      valid? || raise Contract::Error.new(errors)
    end

    private def load_contract_rules
      {% for name, options in FIELD_OPTIONS %}
        {% field_type = CONTENT_attributes[name][:type] %}
        {% key = name.id %}

        rules << Rule.new(:{{name.id}}, {{options[:message]}} || "") do |rule|
          {% for key, expected_value in options %}
            {% if !["message", "type"].includes?(key.stringify) %}
            rule.{{key}}?(@{{name.id}}.as({{field_type}}), {{expected_value}}) &&
            {% end %}
          {% end %}
          true
        end
      {% end %}
    end
  end
end
