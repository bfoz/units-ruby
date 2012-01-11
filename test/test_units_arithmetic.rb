require_relative 'helper'

class UnitsArithmetic < Test::Unit::TestCase
    must "allow addition of compatible units" do
	assert_nothing_raised { Units.new(:meters) + Units.new(:meters) }
    end
    must "not allow addition of incompatible units" do
	assert_raise(UnitsError) { Units.new(:meters) + Units.new(:inches) }
    end

    must "allow subtraction of compatible units" do
	assert_nothing_raised { Units.new(:meters) - Units.new(:meters) }
    end
    must "reject subtraction of incompatible units" do
	assert_raise(UnitsError) { Units.new(:meters) - Units.new(:inches) }
    end

    must "allow multiplication of mixed units" do
	assert_equal(Units.new(:meters => 1, :inches => 1),
		     Units.new(:meters) * Units.new(:inches))
    end
    must "allow multiplication of same units" do
	assert_equal(Units.new(:meters => 2),
		     Units.new(:meters) * Units.new(:meters))
    end
    must "allow multiplication by nil" do
	assert_equal(Units.new(:meters), Units.new(:meters) * nil)
    end

    must "allow division" do
	assert_equal(Units.new(:meters => 1, :inches => -1),
		     Units.new(:meters) / Units.new(:inches))
    end
    must "allow division by nil" do
	assert_equal(Units.new(:meters), Units.new(:meters) / nil)
    end
end
