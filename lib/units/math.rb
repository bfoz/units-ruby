require_relative 'literal'

module Math
    alias :units_sqrt :sqrt
    # Override Math::sqrt to fix handling of {Literal}s
    # @return [Numeric]
    def sqrt(a)
	if a.kind_of?(Units::Literal)
	    if a.units
		Units::Literal.new(units_sqrt(a.value), a.units.square_root)
	    else
		units_sqrt(a.value)
	    end
	else
	    units_sqrt(a)
	end
    end
    # @return [Numeric]
    module_function :units_sqrt
    # @return [Numeric]
    module_function :sqrt
end
