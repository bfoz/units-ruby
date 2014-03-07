require_relative 'numeric_mixin'

# Monkey patch Numeric with a module so that super will work properly in the
#   patched methods
class Numeric
    include NumericMixin
end
