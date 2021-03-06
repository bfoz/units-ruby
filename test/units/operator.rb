require 'minitest/autorun'
require 'units'

describe Units::Operator do
    before do
	Units::Operator.send(:public, *Units::Operator.private_instance_methods)
    end

    it 'must reduce' do
	operator = Units::Operator.new(1.meter, 2.meter)
	operator.reduce(:+, 3.meter, 4.inch, -3.meter, -9.inch).must_equal [0, -5.inch]
    end

    it 'must coerce with Rationals' do
	operator = Units::Operator.new(1.meter, 2.meter)
	operator.coerce(Rational(4,8)).first.must_be :kind_of?, UnitsMixin
    end
end
