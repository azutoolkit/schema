require "./schema/validation"
require "./schema/error"
require "./schema/errors"
require "./schema/rule"
require "./schema/rules"
require "./schema/cast"
require "./schema/definition"
require "./schema/schema_macro"

# A schema is an abstraction to handle validation of
# arbitrary data or object state. It is a fully self-contained
# object that is orchestrated by the operation.

# The Schema macros helps you define schemas and assists
# with instantiating and validating data with those schemas at runtime.
module Schema
  VERSION = "0.1.0"
end
