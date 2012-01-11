require_relative 'helper'

class WrapperTest < Test::Unit::TestCase
    must "reject single argument contructor" do
	assert_raise(ArgumentError) { LiteralWithUnits.new(3) }
    end
    must "reject no argument contructor" do
	assert_raise(ArgumentError) { LiteralWithUnits.new() }
    end
    must "reject nil units" do
	assert_raise(ArgumentError) { LiteralWithUnits.new(3, nil) }
    end

    must "Equal units must be equal" do
	assert_equal(LiteralWithUnits.new(3, :meters), LiteralWithUnits.new(3, :meters))
    end
    must "Unequal units must be unequal" do
	assert_not_equal(LiteralWithUnits.new(3, :meters), LiteralWithUnits.new(4, :meters))
	assert_not_equal(LiteralWithUnits.new(3, :meters), LiteralWithUnits.new(3, :inches))
	assert_not_equal(LiteralWithUnits.new(3, :meters), LiteralWithUnits.new(4, :inches))
	assert_not_equal(LiteralWithUnits.new(3, :meters), 3)
    end
    must "Case equality must work" do
	assert(Units.new(:meters) === Units.new(:meters))
	assert(!(Units.new(:meters) === Units.new(:inches)))
    end
    must "not equal nil" do
	assert_not_equal(Units.new(:meters), nil)
    end

    must "allow addition of compatible units" do
	assert_nothing_raised { LiteralWithUnits.new(3, :meters) + LiteralWithUnits.new(4, :meters) }
	assert_equal(LiteralWithUnits.new(7, :meters),
		     (LiteralWithUnits.new(3, :meters) + LiteralWithUnits.new(4, :meters)))
    end
    must "reject addition of incompatible units" do
	assert_raise(UnitsError) { LiteralWithUnits.new(3, :meters) + LiteralWithUnits.new(4, :inches) }
    end
    must "reject addition of literal" do
	assert_raise(UnitsError) { LiteralWithUnits.new(3, :meters) + 4 }
	assert_raise(UnitsError) { 3 + LiteralWithUnits.new(4, :meters) }
    end

    must "allow subtraction of compatible units" do
	assert_nothing_raised { LiteralWithUnits.new(4, :meters) - LiteralWithUnits.new(3, :meters) }
	assert_equal(LiteralWithUnits.new(1, :meters),
		     (LiteralWithUnits.new(4, :meters) - LiteralWithUnits.new(3, :meters)))
    end
    must "reject subtraction of incompatible units" do
	assert_raise(UnitsError) { LiteralWithUnits.new(3, :meters) - LiteralWithUnits.new(4, :inches) }
    end
    must "reject subtraction of literal" do
	assert_raise(UnitsError) { LiteralWithUnits.new(3, :meters) - 4 }
	assert_raise(UnitsError) { 3 - LiteralWithUnits.new(4, :meters) }
    end

    must "allow multiplication of mixed units" do
	assert_equal(LiteralWithUnits.new(12, {:meters => 1, :inches => 1}),
		     LiteralWithUnits.new(3, :meters) * LiteralWithUnits.new(4, :inches))
    end
    must "allow multiplication of same units" do
	assert_equal(LiteralWithUnits.new(9, {:meters => 2}),
		     LiteralWithUnits.new(3, :meters) * LiteralWithUnits.new(3, :meters))
    end
    must "allow multiplication by literal" do
	assert_equal(LiteralWithUnits.new(9, :meters),
		     LiteralWithUnits.new(3, :meters) * 3)
    end
    must "allow literal multiplied by wrapper" do
	assert_equal(LiteralWithUnits.new(9, :meters),
		     3 * LiteralWithUnits.new(3, :meters))
    end

    must "allow division of mixed units" do
	assert_equal(LiteralWithUnits.new(5, {:meters => 1, :inches => -1}),
		     LiteralWithUnits.new(10, :meters) / LiteralWithUnits.new(2, :inches))
    end
    must "support division of same units" do
	assert_equal(5, LiteralWithUnits.new(10, :meters) / LiteralWithUnits.new(2, :meters))
    end
    must "allow division by literal" do
	assert_equal(LiteralWithUnits.new(1, :meters),
		     LiteralWithUnits.new(3, :meters) / 3)
    end
    must "allow literal divided by wrapper" do
	assert_equal(LiteralWithUnits.new(1, :meters),
		     3 / LiteralWithUnits.new(3, :meters))
    end

end
