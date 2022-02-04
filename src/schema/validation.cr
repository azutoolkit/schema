require "./validation/predicates"
require "./validation/error"
require "./validation/validator"
require "./validation/constraint"

module Schema
  module Validation
    class ValidationError < Exception
      def initialize(@errors : Array(Error))
      end

      def message
        @errors.map(&.message).join(",")
      end
    end

    macro use(*validators)
      {% for validator in validators %}
      {% SCHEMA_VALIDATORS << validator %}
      {% end %}
    end

    macro validate(attribute, **options)
      {% SCHEMA_VALIDATIONS[attribute] = options %}
    end

    macro predicates
      module Schema::Predicates
        {{yield}}
      end
    end

    macro create_validator(type_validator)
      {% type_validator = type_validator.resolve %}

      class Validator
        def self.validate(instance : {{type_validator}})
          errors = Array(Schema::Error).new
          rules = Array(Schema::Constraint | Schema::Validator).new
          validations(rules, instance)
          rules.reduce([] of Schema::Error) do |errors, rule|
            errors + rule.valid?
          end
        end

        private def self.validations(rules, instance)
          {% for validtor in type_validator.constant(:SCHEMA_VALIDATORS) %}
          rules << {{validtor}}.new(instance)
          {% end %}

          rules << Schema::Constraint.new do |rule, errors|
            {% for name, options in type_validator.constant(:SCHEMA_VALIDATIONS) %}
              {% for predicate, expected_value in options %}
                {% if !["message"].includes?(predicate.stringify) %}
                unless rule.{{predicate.id}}?(instance.{{name.id}}, {{expected_value}})
                  errors << Schema::Error.new(:{{name.id}}, {{options["message"] || "Invalid field: " + name.stringify}})
                end
                {% end %}
              {% end %}
            {% end %}
          end
        end
      end
    end

    macro included
      SCHEMA_VALIDATORS = [] of Nil
      SCHEMA_VALIDATIONS = {} of Nil => Nil

      def valid?
        errors.empty?
      end

      def validate!
        errs = errors
        errs.empty? || raise ValidationError.new(errs)
      end

      def errors
        Validator.validate(self)
      end

      macro finished
        create_validator(\{{ @type }})
      end
    end
  end
end
