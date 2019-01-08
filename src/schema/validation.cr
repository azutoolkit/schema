require "./validations/*"

module Schema
  module Validators
    include Equal
    include Exclusion
    include GreaterThan
    include GreaterThanOrEqual
    include Inclusion
    include LessThan
    include LessThanOrEqual
    include RegularExpression
    include Size
  end

  module Validation
    CONTENT_ATTRIBUTES = {} of Nil => Nil
    FIELD_OPTIONS      = {} of Nil => Nil
    CUSTOM_VALIDATORS  = {} of Nil => Nil

    macro validate(attribute, **options)
      {% FIELD_OPTIONS[attribute] = options %}
      {% CONTENT_ATTRIBUTES[attribute] = options || {} of Nil => Nil %}
    end

    macro use(*validators)
      {% for validator in validators %}
        {% CUSTOM_VALIDATORS[validator.stringify] = @type %}
      {% end %}
    end

    macro predicates
      module ::Schema
        module Validators
          {{yield}}
        end
      end
    end

    macro included
      macro finished
        __process_validation
      end
    end

    macro __process_validation
      {% CUSTOM_VALIDATORS["Schema::Rule"] = "Symbol" %}
      {% custom_validators = CUSTOM_VALIDATORS.keys.map { |v| v.id }.join("|") %}
      {% custom_types = CUSTOM_VALIDATORS.values.map { |v| v.id }.join("|") %}

      @[JSON::Field(ignore: true)]
      @[YAML::Field(ignore: true)]
      getter rules : Schema::Rules({{custom_validators.id}}, {{custom_types.id}}) =
         Schema::Rules({{custom_validators.id}},{{custom_types.id}}).new

      def valid?
        load_validations_rules
        rules.errors.empty?
      end

      def validate!
        valid? || raise Schema::Error.new(errors)
      end

      def errors
        rules.errors
      end

      private def load_validations_rules
        {% for name, options in FIELD_OPTIONS %}
          {% for predicate, expected_value in options %}
            {% custom_validator = predicate.id.stringify.split('_').map(&.capitalize).join("") + "Validator" %}
            {% if !["message", "type"].includes?(predicate.stringify) && CUSTOM_VALIDATORS[custom_validator] != nil %}
            rules << {{custom_validator.id}}.new(self, {{options[:message]}} || "")
            {% end %}
          {% end %}

          rules << Schema::Rule.new(:{{name.id}}, {{options[:message]}} || "") do |rule|
          {% for predicate, expected_value in options %}
            {% custom_validator = predicate.id.stringify.split('_').map(&.capitalize).join("") + "Validator" %}
            {% if !["message", "type"].includes?(predicate.stringify) && CUSTOM_VALIDATORS[custom_validator] == nil %}
            rule.{{predicate.id}}?(@{{name.id}}, {{expected_value}}) &
            {% end %}
          {% end %}
          true
          end
        {% end %}
      end
    end
  end
end
