require 'minitest/autorun'
require 'units/addition'

describe Units::Addition do
    subject { Units::Addition.new(3.meters, 4.inches) }
    let(:addition) { Units.Addition(3.meters, 9.inches) }

    it 'must have a units attribute' do
	subject.units.must_equal Units.meters
	Units::Addition.new(Units::Subtraction.new(5.inches, 3.meters), 4.inches).units.must_equal Units.inches
    end

    it 'must have an addition operator that returns a new proxy' do
	(subject + 5).must_equal Units::Addition.new(3.meters, 4.inches, 5)
	(5 + subject).must_equal Units::Addition.new(5, 3.meters, 4.inches)
	(subject + subject).must_equal Units::Addition.new(6.meters, 8.inches)
    end

    it 'must have a subtraction operator that returns a new proxy' do
	(subject - 5).must_equal Units::Subtraction.new(subject, 5)
	(5 - subject).must_equal Units::Subtraction.new(5, 3.meters, 4.inches)
    end

    it 'must subtract another Addition that yields a new proxy' do
	(subject - Units.Addition(4.meters, 9.inches)).must_equal Units.Addition(-1.meters, -5.inches)
    end

    it 'must subtract another Addition that yields a Numeric' do
	(subject - addition).must_equal -5.inches
    end

    it 'must have a multiplication operator that returns a new proxy' do
	(subject * 5).must_equal Units::Addition.new(15.meters, 20.inches)
	(5 * subject).must_equal Units::Addition.new(15.meters, 20.inches)
	(subject * subject).must_equal ((3.meters * subject) + (4.inches * subject))
    end

    it 'must have a division operator that returns a new proxy' do
	(Units::Addition.new(15.meters, 20.inches) / 5).must_equal subject
	(5 / subject).must_equal Units::Division.new(5, subject)
	(subject / subject).must_equal Units::Division.new(subject, subject)
    end

    it 'must collapse like units when adding Units' do
	(subject + 5.inches).must_equal Units.Addition(3.meters, 9.inches)
	(Units::Addition.new(20.cm, 20.mm) + 10.mm).must_equal Units::Addition.new(20.cm, 30.mm)
    end

    it 'must collapse like units when subtracting Units' do
	(Units::Addition.new(20.cm, 20.mm) - 10.mm).must_equal Units::Addition.new(20.cm, 10.mm)
	(Units::Addition.new(20.cm, 20.mm) - 20.mm).must_equal 20.cm
    end

    it 'must spaceship with a regular Numeric' do
	(Units::Addition.new(20.inches, 15.meters) <=> 1000).must_equal -1
	(Units::Addition.new(15.meters, 15.meters) <=> 30).must_equal 0
	(Units::Addition.new(15.meters, 20.inches) <=> 5).must_equal 1
    end

    it 'must spaceship with a Numeric that has units' do
	(Units::Addition.new(20.inches, 15.meters) <=> 1000.inches).must_equal -1
	(Units::Addition.new(15.meters, 15.meters) <=> 30.meters).must_equal 0
	(Units::Addition.new(15.meters, 20.inches) <=> 5.inches).must_equal 1
    end

    it 'must spaceship with an exactly equal operator' do
	arg0 = 9.mm + (Rational(-9, 2).cm - 2.25.mm)
	arg1 = 9.mm + (Rational(-9, 2).cm - 2.25.mm)
	(arg0 <=> arg1).must_equal 0
    end

    it 'must spaceship with an unequal operator' do
	arg0 = 9.mm + (Rational(-9, 2).cm - 2.25.mm)
	arg1 = -9.mm + (Rational(-9, 2).cm - 2.25.mm)
	(arg0 <=> arg1).must_equal 1
    end

    it 'must compare equal regardless of order' do
	(Units.Addition(10.cm, 6.mm) == Units.Addition(6.mm, 10.cm)).must_equal true
    end

    describe 'when operating on zero' do
	it 'must not add zero' do
	    (subject + 0).must_equal subject
	    (Units.Addition(3.meters) + 0).must_equal 3.meters
	    (Units.Addition(3.meters) + 0).wont_be_kind_of Units::Operator
	end

	it 'must not subtract 0' do
	    (subject - 0).must_equal subject
	    (Units.Addition(3.meters) - 0).must_equal 3.meters
	end

	it 'must return 0 when multiplied by 0' do
	    (subject * 0).must_equal 0
	end

	it 'must return 0 when subtracting itself' do
	    (subject - subject).must_equal 0
	end
    end

    describe 'when operating on a Division operator' do
	let(:division) { Units::Division.new 3.meters, 5.foot }

	it 'must add' do
	    (subject + division).must_equal Units::Addition.new(3.meters, 4.inches, division)
	end

	it 'must subtract' do
	    (subject - division).must_equal Units::Subtraction.new(subject, division)
	end

	it 'must multiply' do
	    (subject * division).must_equal Units::Addition.new(3.meters * division, 4.inches * division)
	end

	it 'must divide' do
	    (subject / division).must_equal Units::Addition.new(3.meters / division, 4.inches / division)
	end
    end

    describe 'when operating on a Subtraction operator' do
	let(:subtraction) { Units::Subtraction.new(3.meters, 4.meters) }

	it 'must add a subtraction' do
	    (subject + subtraction).must_equal Units::Addition.new(3.meters, 4.inches, subtraction)
	end

	it 'must subtract a subtraction' do
	    (subject - subtraction).must_equal Units.Addition(4.inches, 4.meters)
	end

	it 'must multiply by a subtraction' do
	    (subject * subtraction).must_equal Units::Addition.new(3.meters * subtraction, 4.inches * subtraction)
	end

	it 'must divide by a subtraction' do
	    (subject / subtraction).must_equal Units::Addition.new(3.meters / subtraction, 4.inches / subtraction)
	end
    end

    describe 'when operating on a SquareRoot operator' do
	let(:sqrt) { Units::SquareRoot.new(subject) }

	it 'must add' do
	    (subject + sqrt).must_equal Units.Addition(3.meters, 4.inches, sqrt)
	end

	it 'must subtract' do
	    (subject - sqrt).must_equal Units.Subtraction(subject, sqrt)
	end

	it 'must multiply' do
	    (subject * sqrt).must_equal Units.Addition(3.meters * sqrt, 4.inches * sqrt)
	end

	it 'must divide' do
	    (subject / sqrt).must_equal Units.Addition(3.meters/sqrt, 4.inches/sqrt)
	end
    end

    it 'must convert all operands to a desired unit' do
	subject.to_foot.must_be_close_to 10.1758532.foot
    end

    describe 'when pretending to be a Numeric' do
	it 'must have an unary plus method' do
	    (+subject).must_equal subject
	end

	it 'must have an unary minus method' do
	    (-subject).must_equal Units::Addition.new(-3.meters, -4.inches)
	end

	it 'must have an abs2 method' do
	    subject.abs2.must_equal (subject * subject)
	end

	it 'must have a sqrt method' do
	    subject.sqrt.must_equal Units::SquareRoot.new(subject)
	end

	it 'must have a zero? method' do
	    subject.zero?.must_equal false
	    Units::Addition.new(0.meters, 0.inches).zero?.must_equal true
	end
    end
end
