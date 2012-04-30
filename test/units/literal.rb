require_relative '../helper'

def Literal(*args)
    Units::Literal.new(*args)
end

class LiteralTest < Test::Unit::TestCase
    one = Literal(1)
    three = Literal(3)
    four = Literal(4)
    seven = Literal(7)
    twelve = Literal(12)
    
    three_inches = Literal(3, :inches)
    four_inches = Literal(4, :inches)
    
    one_meter = Literal(1, :meter)
    three_meters = Literal(3, :meters)
    four_meters = Literal(4, :meters)
    seven_meters = Literal(7, :meters)
    twelve_meters = Literal(12, :meters)
    
    twelve_meters2 = Literal(12, Units.new(:meters, :meters))

    must "claim to be a Numeric" do
	assert_kind_of(Numeric, Literal(1))
    end

    # A literal with units is considered to be different from the same literal
    #  without units
    must "break equality for mixed units" do
	assert_not_equal(3, three_meters)
	assert_not_equal(three_meters, three_inches)
    end

    must "preserve equality" do
	assert_equal(three, three)
    end

    must "preserve addition" do
	assert_equal(seven, three + four)
    end

    must "preserve subtraction" do
	assert_equal(one, four - three)
    end

    must "preserve multiplication" do
	assert_equal(twelve, three * four)
    end

    must "preserve division" do
	assert_equal(three, twelve / four)
    end


    must "allow addition" do
	assert_equal(seven_meters, three_meters + four_meters)
    end

    must "allow subtraction" do
	assert_equal(one_meter, four_meters - three_meters)
    end

    must "allow multiplication" do
	assert_equal(twelve_meters2, 3.meters * 4.meters)
    end

    must "allow multiplication by Literal" do
	assert_equal(twelve_meters, three_meters * 4)
	assert_equal(twelve_meters, three_meters * four)
    end

    must "allow division" do
	assert_equal(four, twelve_meters / three_meters)
    end
    
    must "allow division by Literal" do
	assert_equal(four_meters, twelve_meters / 3)
    end


    must "allow addition of valid units and no units" do
	assert_nothing_raised { three_meters + four }
	assert_equal(seven_meters, three_meters + four)
    end

    must "allow subtraction of valid units and no units" do
	assert_nothing_raised { three_meters - three }
    end


    must "reject mixed units when adding" do
	assert_raise(UnitsError) { three_meters + three_inches }
    end

    must "reject mixed units when subtracting" do
	assert_raise(UnitsError) { three_meters - four_inches }
    end

    must "have an inspect method" do
	assert_equal('1 meter', one_meter.inspect)
	assert_equal(1, one);
    end
    must "have a to_s method that returns only the literal's to_s" do
	assert_equal('1', one_meter.to_s)
    end
end
