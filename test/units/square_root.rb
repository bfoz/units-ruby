require 'minitest/autorun'
require 'units/square_root'

describe Units::SquareRoot do
    subject { Units::SquareRoot.new(Units.Addition(3.meters, 4.inches)) }
    let(:addition) { Units.Addition(3.meters, 4.inches) }

    it 'must raise an exception when initialized with more than one argument' do
	->{ Units::SquareRoot.new(3.meters, 4.inches) }.must_raise ArgumentError
    end

    it 'must raise an exception when initialized with anything other than an Operator' do
	->{ Units::SquareRoot.new(3.meters) }.must_raise ArgumentError
    end

    it 'must have an unary negation operator' do
	(-subject).must_equal Units.Subtraction(0, subject)
    end

    it 'must add' do
	(subject + 5).must_equal Units.Addition(subject, 5)
    end

    it 'must subtract' do
	(subject - 5).must_equal Units.Subtraction(subject, 5)
    end

    it 'must multiply' do
	(subject * 0).must_equal 0
	(subject * 5).must_equal Units.SquareRoot(addition * 5.abs2)
    end

    it 'must divide' do
	(Units::SquareRoot.new(Units.Addition(15.meters, 20.inches)) / 5).must_equal Units.SquareRoot(addition / 5.abs2)
    end

    it 'must spaceship with a Numeric that has units' do
	(Units::SquareRoot.new(addition) <=> 1000.inches('1/2'.to_r)).must_equal -1
	(Units::SquareRoot.new(addition) <=> Math.sqrt(3.1016).meter).must_equal 0
	(Units::SquareRoot.new(addition) <=> 5.inches).must_equal 1
    end

    describe 'when pretending to be a Numeric' do
	it 'must have an unary plus method' do
	    (+subject).must_equal subject
	end

	it 'must have an abs2 method' do
	    subject.abs2.must_equal subject.operands.first
	end

	it 'must have a zero? method' do
	    subject.zero?.must_equal nil
	    Units::SquareRoot.new(Units.Addition(0)).zero?.must_equal true
	end
    end
end