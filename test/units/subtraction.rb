require 'minitest/autorun'
require 'units/subtraction'

describe Units::Subtraction do
    subject { Units::Subtraction.new(3.meters, 4.inches) }
    let(:subtraction) { Units.Subtraction(5.meters, 6.foot) }

    it 'must have an addition operator that returns a new proxy' do
	(subject + 5).must_equal Units::Addition.new(subject, 5)
	(5 + subject).must_equal Units::Addition.new(5, subject)
	(subject + subject).must_equal Units::Addition.new(subject, subject)
    end

    it 'must have a subtraction operator that returns a new proxy' do
	(subject - 5).must_equal Units::Subtraction.new(3.meters, 4.inches, 5)
	(5 - subject).must_equal Units::Subtraction.new(5, 3.meters, -4.inches)
    end

    it 'must subtract another Subtraction that yields a new proxy' do
	(subject - subtraction).must_equal Units::Subtraction.new(-2.meters, 4.inches, -6.foot)
    end

    it 'must subtract another Subtraction that yields a Numeric' do
	(subject - Units.Subtraction(3.meters, 9.inches)).must_equal 5.inches
    end

    it 'must have a multiplication operator that returns a new proxy' do
	(subject * 5).must_equal Units::Subtraction.new(15.meters, 20.inches)
	(5 * subject).must_equal Units::Subtraction.new(15.meters, 20.inches)
	(subject * subject).must_equal ((3.meters * subject) - (4.inches * subject))
    end

    it 'must have a division operator that returns a new proxy' do
	(Units::Subtraction.new(15.meters, 20.inches) / 5).must_equal subject
	(5 / subject).must_equal Units::Division.new(5, subject)
	(subject / subject).must_equal Units::Division.new(subject, subject)
    end

    it 'must spaceship with a Numeric that has units' do
	(Units::Subtraction.new(20.inches, 15.meters) <=> 5.inches).must_equal -1
	(Units::Subtraction.new(15.meters, 15.meters) <=> 0.inches).must_equal 0
	(Units::Subtraction.new(15.meters, 20.inches) <=> 5.inches).must_equal 1
    end

    describe 'when operating on zero' do
	it 'must not add zero' do
	    (subject + 0).must_equal subject
	    (Units.Subtraction(3.meters) + 0).must_equal 3.meters
	    (Units.Subtraction(3.meters) + 0).wont_be_kind_of Units::Operator
	end

	it 'must not subtract 0' do
	    (subject - 0).must_equal subject
	    (Units.Subtraction(3.meters) - 0).must_equal 3.meters
	end

	it 'must return 0 when multiplied by 0' do
	    (subject * 0).must_equal 0
	end

	it 'must return 0 when subtracting itself' do
	    (subject - subject).must_equal 0
	end
    end

    describe 'when operating on an Addition operator' do
	let(:addition) { Units::Addition.new 3.meters, 5.foot }

	it 'must add' do
	    (subject + addition).must_equal Units::Addition.new(subject, addition)
	end

	it 'must subtract' do
	    (subject - addition).must_equal Units::Subtraction.new(-4.inches, 5.foot)
	end

	it 'must multiply' do
	    (subject * addition).must_equal 3.meters * addition - 4.inches * addition
	end

	it 'must divide' do
	    (subject / addition).must_equal Units::Subtraction.new(3.meters / addition, 4.inches / addition)
	end
    end

    describe 'when operating on a Division operator' do
	let(:division) { Units::Division.new 3.meters, 5.foot }

	it 'must add' do
	    (subject + division).must_equal Units::Addition.new(subject, division)
	end

	it 'must subtract' do
	    (subject - division).must_equal Units::Subtraction.new(3.meters, 4.inches, division)
	end

	it 'must multiply' do
	    (subject * division).must_equal Units::Subtraction.new(3.meters * division, 4.inches * division)
	end

	it 'must divide' do
	    (subject / division).must_equal Units::Subtraction.new(3.meters / division, 4.inches / division)
	end
    end

    describe 'when operating on a SquareRoot operator' do
	let(:sqrt) { Units::SquareRoot.new(subject) }

	it 'must add' do
	    (subject + sqrt).must_equal Units.Addition(subject, sqrt)
	end

	it 'must subtract' do
	    (subject - sqrt).must_equal Units.Subtraction(3.meters, 4.inches, sqrt)
	end

	it 'must multiply' do
	    (subject * sqrt).must_equal Units.Subtraction(3.meters * sqrt, 4.inches * sqrt)
	end

	it 'must divide' do
	    (subject / sqrt).must_equal Units.Subtraction(3.meters / sqrt, 4.inches / sqrt)
	end
    end

    it 'must convert all operands to a desired unit' do
	subject.to_foot.must_be_close_to 9.509.foot
    end

    describe 'when pretending to be a Numeric' do
	it 'must have an unary plus method' do
	    (+subject).must_equal subject
	end

	it 'must have an unary minus method' do
	    (-subject).must_equal Units::Subtraction.new(-3.meters, -4.inches)
	end

	it 'must have an abs2 method' do
	    subject.abs2.must_equal (subject * subject)
	end

	it 'must have a sqrt method' do
	    subject.sqrt.must_equal Units::SquareRoot.new(subject)
	end

	it 'must have a zero? method' do
	    subject.zero?.must_equal false
	    Units::Subtraction.new(0.meters, 0.inches).zero?.must_equal true
	end
    end
end
