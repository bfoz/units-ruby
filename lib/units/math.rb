require_relative 'numeric'

module Math
    alias :units_sqrt :sqrt
    # Override Math::sqrt to fix handling of {Units::Numeric}s
    # @return [Numeric]
    def sqrt(arg)
	case arg
	    when Units::Numeric
		if arg.units
		    Units::Numeric.new(units_sqrt(arg.value), arg.units.square_root)
		else
		    units_sqrt(arg.value)
		end
	    when Units::Operator
		arg.sqrt
	    else
		units_sqrt(arg)
	end
    end
    # @return [Numeric]
    module_function :units_sqrt
    # @return [Numeric]
    module_function :sqrt
end
