require 'minitest/autorun'
require 'units/literal'

def Literal(*args)
    Units::Literal.new(*args)
end

describe Units::Literal do
    let(:one)	{ Literal(1) }
    let(:three)	{ Literal(3) }
    let(:four)	{ Literal(4) }
    let(:seven)	{ Literal(7) }
    let(:twelve){ Literal(12) }

    let(:three_inches)	{ Literal(3, :inches) }
    let(:four_inches)	{ Literal(4, :inches) }

    let(:one_meter)	{ Literal(1, :meter) }
    let(:three_meters)	{ Literal(3, :meters) }
    let(:four_meters)	{ Literal(4, :meters) }
    let(:seven_meters)	{ Literal(7, :meters) }
    let(:twelve_meters)	{ Literal(12, :meters) }

    let(:twelve_meters2)    { Literal(12, Units.new(:meters, :meters)) }

    it "should claim to be a Numeric" do
	one.must_be_kind_of Numeric
    end

    describe "when constructing" do
	it "should require a value" do
	    lambda { Literal() }.must_raise(ArgumentError)
	end

	it "should accept a Unit, but not require it" do
	    Literal(1).must_equal 1
	    Literal(1, :meter).must_equal one_meter
	end
    end

    describe "equality" do
	let(:three_inches)	{ Literal(3, :inches) }
	let(:three_meters)	{ Literal(3, :meters) }

	it "should not equate a literal with units and a literal without units" do
	    three_meters.wont_equal 3
	end

	it "should not equate meters with inches" do
	    three_meters.wont_equal three_inches
	    three_inches.wont_equal three_meters
	end

	it "should preserve normal equality for literals without units" do
	    three.must_equal three
	    Literal(3).must_equal 3
	    Literal(3.5).must_equal 3.5
	end
    end

    describe "arithmetic without units" do
	it "should preserve integer addition" do
	    (three + four).must_equal seven
	end

	it "should preserve integer subtraction" do
	    (four - three).must_equal one
	    (three - four).must_equal -one
	end

	it "should preserve integer multiplication" do
	    (three * four).must_equal twelve
	end

	it "should preserve integer division" do
	    (twelve/four).must_equal three
	end
    end

    describe "arithmetic with like units" do
	it "should support addition" do
	    (three_meters + four_meters).must_equal seven_meters
	end

	it "should support subtraction" do
	    (four_meters - three_meters).must_equal one_meter
	end

	it "should support multiplication" do
	    (3.meters * 4.meters).must_equal twelve_meters2
	end

	it "should support division" do
	    assert_equal(four, twelve_meters / three_meters)
	end
    end

    describe "integer arithmetic with normal literals" do
	it "should support multiplication" do
	    (three_meters * 4).must_equal twelve_meters
	    (three_meters * four).must_equal twelve_meters
	end

	it "support division" do
	    (twelve_meters / 3).must_equal four_meters
	    (one_meter / 2).must_equal 0
	end
    end

    describe "arithmetic with mixed units" do
	it "should allow addition of valid units and no units" do
	    (three_meters + four).must_equal seven_meters
	    (four + three_meters).must_equal seven_meters
	end

	it "should allow subtraction of valid units and no units" do
	    (three_meters - three).must_equal 0
	    (three - three_meters).must_equal 0
	end

	it "should reject mixed units when adding" do
	    lambda { three_meters + three_inches }.must_raise UnitsError
	end

	it "reject mixed units when subtracting" do
	    lambda { three_meters - four_inches }.must_raise UnitsError
	end
    end

    it "should have an inspect method" do
	assert_equal('1 meter', one_meter.inspect)
	assert_equal(1, one);
    end
    it "should have a to_s method that returns only the literal's to_s" do
	assert_equal('1', one_meter.to_s)
    end
end
