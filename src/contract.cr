require "./contract/validators/*"
require "./contract/rules"
require "./contract/cast"
require "./contract/definition"
require "./contract/contract_macro"

# A contract is an abstraction to handle validation of
# arbitrary data or object state. It is a fully self-contained
# object that is orchestrated by the operation.

# The Contract macros helps you define contracts and assists
# with instantiating and validating data with those contracts at runtime.
module Contract
  include Validators

  VERSION = "0.1.0"
end
