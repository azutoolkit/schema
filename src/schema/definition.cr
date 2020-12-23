require "json"
require "http"
require "./parse_error"

module Schema
  annotation Settings
  end

  module Definition
    annotation Field
    end

    macro included
      include JSON::Serializable

      {% settings = @type.annotation(::Schema::Settings) || { strict: false, unmapped: false } %}
      {% raise "strict and unmapped are mutually exclusive" if settings[:strict] && settings[:unmapped] %}
      {% if settings[:strict] %}
        include JSON::Serializable::Strict
      {% elsif settings[:unmapped] %}
        include JSON::Serializable::Unmapped

        @[JSON::Field(ignore: true)]
        getter query_unmapped = Hash(String, Array(String)).new
      {% end %}

      def self.from_urlencoded(string)
        new(HTTP::Params.parse(string))
      end

      def self.new(http_params : HTTP::Params, path : Array(String) = [] of String)
        new_from_http_params(http_params, path)
      end

      private def self.new_from_http_params(http_params : HTTP::Params, path : Array(String) = [] of String)
        instance = allocate
        instance.initialize(__http_params_from_schema: http_params, __path_from_schema: path)
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        instance
      end
    end

    macro string_value_from_params(params, name, nilable, has_default)
      %values = string_values_from_params({{params}}, {{name}}, {{nilable}}, {{has_default}})
      {% if nilable || has_default %}
        %values.empty? ? nil : %values.last
      {% else %}
        %values.last
      {% end %}
    end

    macro string_values_from_params(params, name, nilable, has_default)
      {% if nilable || has_default %}
        {{params}}.fetch_all({{name}})
      {% else %}
        {{params}}.fetch_all({{name}}).tap do |values|
          raise KeyError.new(%|Missing hash key: "#{{{name}}}"|) if values.empty?
        end
      {% end %}
    end

    def initialize(*, __http_params_from_schema http_params : HTTP::Params, __path_from_schema path = [] of String)
      {% begin %}
        {% settings = @type.annotation(::Schema::Settings) || { strict: false, unmapped: false } %}
        {% if settings[:strict] || settings[:unmapped] %}
          handled_param_names = [] of String
        {% end %}

        {% for ivar in @type.instance_vars %}
          {% non_nil_type = ivar.type.union? ? ivar.type.union_types.reject { |type| type == ::Nil }.first : ivar.type %}
          {% nilable = ivar.type.nilable? %}
          {% has_default = ivar.has_default_value? %}
          {% default = has_default ? ivar.default_value : nil %}
          {% ann = ivar.annotation(::Schema::Params::Field) %}
          {% converter = ann && ann[:converter] %}
          {% key = (ann && ann[:key] || ivar.name.stringify) %}

          %param_name = (path + [{{key}}]).reduce { |result, fragment| "#{result}[#{fragment}]" }
          {% if converter %}
            %values = string_values_from_params(http_params, %param_name, {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              if %values.empty?
                @{{ivar.name}} = {{default}}
              else
            {% end %}
              @{{ivar.name}} = {{converter}}.from_params(%values)
            {% if nilable || has_default %}
              end
            {% end %}

          {% elsif non_nil_type <= Array %}
            %values = string_values_from_params(http_params, "#{%param_name}[]", {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              if %values.empty?
                @{{ivar.name}} = {{default}}
              else
            {% end %}

            @{{ivar.name}} = %values.map do |item|
              {% item_type = non_nil_type.type_vars.first %}
              {% if item_type <= String %}
                item
              {% elsif item_type == Bool %}
                !\%w[0 false no].includes?(item)
              {% elsif item_type <= Enum %}
                {{item_type}}.parse(item)
              {% else %}
                {{item_type}}.new(item)
              {% end %}
            end

            {% if nilable || has_default %}
              end
            {% end %}

            {% if settings[:strict] || settings[:unmapped] %}
              handled_param_names << "#{%param_name}[]"
            {% end %}

          {% elsif non_nil_type <= Tuple %}
            %values = string_values_from_params(http_params, "#{%param_name}[]", {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              if %values.empty?
                @{{ivar.name}} = {{default}}
              else
            {% end %}
            @{{ivar.name}} = {
              {% for item_type, index in non_nil_type.type_vars %}
                {% if item_type <= String %}
                  %values[{{index}}],
                {% elsif item_type == Bool %}
                  !\%w[0 false no].includes?(%values[{{index}}]),
                {% elsif item_type <= Enum %}
                  {{item_type}}.parse(%values[{{index}}]),
                {% else %}
                  {{item_type}}.new(%values[{{index}}]),
                {% end %}
              {% end %}
            }
            {% if nilable || has_default %}
              end
            {% end %}

            {% if settings[:strict] || settings[:unmapped] %}
              handled_param_names << "#{%param_name}[]"
            {% end %}

          {% elsif non_nil_type <= ::Schema::Params %}
            %nested_params = HTTP::Params.new({} of String => Array(String))
            http_params.each do |key, value|
              if key.starts_with?("#{%param_name}[")
                %nested_params.add(key, value)
                {% if settings[:strict] || settings[:unmapped] %}
                  handled_param_names << key
                {% end %}
              end
            end

            if %nested_params.any?
              @{{ivar.name}} = {{non_nil_type}}.new(
                %nested_params,
                path + [{{ivar.name.stringify}}]
              )
            else
              {% if nilable || has_default %}
                @{{ivar.name}} = {{default}}
              {% else %}
                raise KeyError.new(%|Missing nested hash keys: "#{%param_name}"|)
              {% end %}
            end

          {% elsif non_nil_type == String %}
            %value = string_value_from_params(http_params, %param_name, {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              @{{ivar.name}} = %value || {{default}}
            {% else %}
              @{{ivar.name}} = %value
            {% end %}

            {% if settings[:strict] || settings[:unmapped] %}
              handled_param_names << %param_name
            {% end %}

          {% elsif non_nil_type == Bool %}
            %value = string_value_from_params(http_params, %param_name, {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              if %value.nil?
                @{{ivar.name}} = {{default}}
              else
            {% end %}
            @{{ivar.name}} = !\%w[0 false no].includes?(%value.downcase)
            {% if nilable || has_default %}
              end
            {% end %}
            {% if settings[:strict] || settings[:unmapped] %}
              handled_param_names << %param_name
            {% end %}

          {% elsif non_nil_type <= ::Enum %}
            %value = string_value_from_params(http_params, %param_name, {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              @{{ivar.name}} = %value.try { |value| {{non_nil_type}}.parse(value) } || {{default}}
            {% else %}
              @{{ivar.name}} = {{non_nil_type}}.parse(%value)
            {% end %}

            {% if settings[:strict] || settings[:unmapped] %}
              handled_param_names << %param_name
            {% end %}

          {% elsif non_nil_type <= Hash %}
            %value = {{non_nil_type}}.new
            escaped_param_name = Regex.escape(%param_name)

            {% key_type = non_nil_type.type_vars[0] %}
            {% value_type = non_nil_type.type_vars[1] %}

            {% if value_type <= Array %}
              matcher = /^#{escaped_param_name}\[(?<key>[^\]]+)\]\[\]$/
            {% else %}
              matcher = /^#{escaped_param_name}\[(?<key>[^\]]+)\]$/
            {% end %}

            http_params.each do |key, value|
              match = key.match(matcher)
              next if match.nil?

              {% if key_type <= String %}
                key = match["key"]
              {% else %}
                key = {{key_type}}.new(match["key"])
              {% end %}

              {% element_type = value_type <= Array ? value_type.type_vars.first : value_type %}

              {% if element_type <= String %}
              {% elsif element_type == Bool %}
                value = !\%w[0 false no].includes?(value)
              {% elsif element_type <= Enum %}
                value = {{element_type}}.parse(value)
              {% else %}
                value = {{element_type}}.new(value)
              {% end %}

              {% if value_type <= Array %}
                if %value.has_key?(key)
                  %value[key] << value
                else
                  %value[key] = {{value_type}}.new(1) { value }
                end
              {% else %}
                %value[key] = value
              {% end %}

              {% if settings[:strict] || settings[:unmapped] %}
                handled_param_names << key
              {% end %}
            end

            if %value.empty?
              {% if nilable || has_default %}
                @{{ivar.name}} = {{default}}
              {% else %}
                raise KeyError.new(%|Missing nested keys for: "#{%param_name}"|)
              {% end %}
            else
              @{{ivar.name}} = %value
            end

          {% else %}
            %value = string_value_from_params(http_params, %param_name, {{nilable}}, {{has_default}})
            {% if nilable || has_default %}
              if %value.nil?
                @{{ivar.name}} = {{default}}
              else
            {% end %}
              @{{ivar.name}} = {{non_nil_type}}.new(%value)
            {% if nilable || has_default %}
              end
            {% end %}
            {% if settings[:strict] || settings[:unmapped] %}
              handled_param_names << %param_name
            {% end %}
          {% end %}
        {% end %}

        {% if settings[:strict] || settings[:unmapped] %}
          http_params.each do |key, _|
            next if handled_param_names.includes?(key)
            {% if settings[:strict] %}
              raise %|Unknown param: "#{key}"|
            {% else %}
              @query_unmapped[key] = http_params.fetch_all(key)
            {% end %}
          end
        {% end %}
      {% end %}
    end
  end
end
