require_relative 'numeric'

module Math
    alias :units_sqrt :sqrt
    # Override Math::sqrt to fix handling of {Units::Numeric}s
    # @return [Numeric]
    def sqrt(a)
	if a.kind_of?(Units::Numeric)
	    if a.units
		Units::Numeric.new(units_sqrt(a.value), a.units.square_root)
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
