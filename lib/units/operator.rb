class Units
    class Operator
	include Comparable

	# @!attribute operands
	#   @return [Array]  The operands of the operator
	attr_reader :operands

	def initialize(*args)
	    raise ArgumentError, "Can't initialize #{self.class} without arguments" if args.empty?
	    @conversion_cache = {}
	    @operands = Array(args)
	end

	# Returns true if both operands be of the same class and in the same order
	def eql?(other)
	    return zero? if other.zero?
	    other.is_a?(self.class) && (operands.eql? other.operands)
	end

	# Returns true if both operands are of the same class and convert to the same value
	def ==(other)
	    return zero? if other.zero?
	    return false unless other.is_a?(self.class)
	    return true if operands == other.operands

	    # If the operands aren't exactly equal, try converting
	    # them both to some unit and then do the comparison

	    # Randomly choose the first unit of self
	    target_unit = units || other.units

	    self.to(target_unit) == other.to(target_unit)
	end

	def <=>(other)
	    case other
		when ::Numeric
		    convert_to(units) <=> other
		when Units::Numeric
		    convert_to(other.units) <=> other
		when Units::Operator
		    if eql?(other)
			0
		    else
			# If the operands aren't exactly equal, try converting
			# them both to some unit and then do the comparison

			# Randomly choose the first unit of self
			target_unit = units || other.units

			self.to(target_unit) <=> other.to(target_unit)
		    end
		else
		    raise ArgumentError, "Can't spaceship '#{self}'(#{self.class}) with '#{other}'(#{other.class})"
	    end
	end

	def +@
	    self
	end

	def -@
	    self.class.new *(operands.map {|operand| -operand })
	end

	def +(other)
	    if other.zero?
		if 1 == operands.size
		    operands.first
		else
		    self.dup
		end
	    else
		Units.Addition(self, other)
	    end
	end

	def -(other)
	    if other.zero?
		if 1 == operands.size
		    operands.first
		else
		    self.dup
		end
	    elsif self == other
		0
	    else
		Units.Subtraction(self, other)
	    end
	end

	def *(other)
	    return other if other.zero?
	    operands.map {|operand| operand * other }
		    .reduce {|result, operand| result.send(operator, operand)}
	end

	def /(other)
	    self.class.new *(operands.map {|operand| operand / other })
	end

	# Convert other into something that can handle being divided by {Numeric}
	def coerce(other)
	    case other
		when Fixnum, Float then [Units::Numeric.new(other), self]
		else
		    [other, self]
	    end
	end

	def respond_to_missing?(name, include_private = false)
	    if Units.valid_unit?(name) or ((name.to_s =~ /^to_(.+)$/) and Units.valid_unit?($1))
		true
	    else
		super
	    end
	end

	# Convert all of the operands to the given units and perform the proxied operation
	# @param units [Unit]	the desired {Unit}s to convert to
	# @return [Number]  the result of the proxied operation
	def convert_to(units)
	    @conversion_cache[units] ||= operands.map {|operand| operand.to(units) rescue operand }.reduce(operator)
	end
	alias :to :convert_to

	# @!attribute units
	#   @return [Unit]  a {Unit} randomly-selected from the operands
	def units
	    # Use something that's already been cached, if possible. Otherwise,
	    #  randomly choose the first available unit.
	    if @conversion_cache.empty?
		f = operands.find {|op| op.respond_to? :units}
		f && f.units
	    else
		@conversion_cache.first.first
	    end
	end

	# This is meant to be called from subclasses, but won't explode if called directly
	def to_s(operator)
	    operands.map {|op| op.is_a?(Units::Operator) ? ('(' + op.to_s + ')') : op}.join(operator)
	end

	# This is meant to be called from subclasses, but won't explode if called directly
	def inspect(operator)
	    operands.map {|op| op.is_a?(Units::Operator) ? ('(' + op.inspect + ')') : op.inspect}.join(operator)
	end

	# @group Math
	def sqrt
	    self.class.new *(operands.map {|op| op.respond_to?(:sqrt) ? op.sqrt : Math.sqrt(op)})
	end
	# @endgroup

	# @group Numeric
	def abs2
	    self * self
	end

	def zero?
	    operands.all? {|operand| operand.zero? }
	end
	# @endgroup

    private

	def operator
	    case self
		when Units::Addition then :+
		when Units::Division then :/
		when Units::Subtraction then :-
	    end
	end

	# Reduce the length of the operand list by applying the operator to any operand pairs that won't produce more proxy objects
	# @param operator [Symbol]  The operator to apply to the operands
	# @return [Array]
	def reduce(operator, *args)
	    args.reduce([]) do |memo, operand|
		skip = false
		memo.map! do |lhs|
		    next lhs if skip
		    next lhs if [lhs, operand].map {|a| a.respond_to?(:units) && !!a.units }.uniq.size != 1
		    next lhs if lhs.zero? || operand.zero?
		    begin
			result = lhs.send(operator, operand)
			if result.is_a?(Numeric)
			    skip = true
			    result
			else
			    lhs
			end
		    rescue
			lhs
		    end
		end
		skip ? memo : memo.push(operand)
	    end
	end

	# Reduce the arguments. If only one operand remains, return it. Otherwise, clone.
	def reduce_and_clone(*args)
	    reduced = reduce(*args)
	    if reduced.length > 1
		self.class.new(*reduced)
	    else
		reduced.first
	    end
	end
    end
end