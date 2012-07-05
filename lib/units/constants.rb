class Units
    # http://wikipedia.org/wiki/Metric_prefix
    PREFIXES = {
	:yocto => -24,	:zepto => -21,	:atto  => -18,	:femto => -15,
	:pico  => -12,	:nano  =>  -9,	:micro =>  -6,	:milli =>  -3,
	:centi =>  -2,	:deci  =>  -1,	:deca  =>   1,	:hecto =>   2,
	:kilo  =>   3,	:mega  =>   6,	:giga  =>   9,	:tera  =>  12,
	:peta  =>  15,	:exa   =>  18,	:zetta =>  21,	:yotta =>  24,
    }

    # http://wikipedia.org/wiki/International_System_of_Units
    SI_UNITS = [:meter, :gram, :second, :ampere, :kelvin, :candela, :mole]
    SI_DERIVED = [
	:hertz,	:radian,    :steradian,	:newton,    :pascal,	:joule,
	:watt,	:coulomb,   :volt,	:farad,	    :ohm,	:siemens,
	:weber,	:tesla,	    :henry,	:celsius,   :lumen,	:lux,
	:gray,	:sievert,   :katal,	:becquerel
    ]

    # http://wikipedia.org/wiki/United_States_customary_units
    US_CUSTOMARY_AREA_UNITS = [:acre, :section, :township]
    US_CUSTOMARY_INTERNATIONAL_UNITS = [:point, :pica, :inch, :foot, :yard, :mile]
    US_CUSTOMARY_MASS_UNITS = [
	:grain, :dram, :ounce, :pound, :hundredweight, :long_hundredweight,
	:short_ton, :long_ton, :pennyweight, :troy_ounce, :troy_pound
    ]
    US_CUSTOMARY_NAUTICAL_UNITS = [:fathom, :cable, :nautical_mile]
    US_CUSTOMARY_SURVEY_UNITS = [
	:link, :survey_foot, :rod, :chain,
	:furlong, :statute_mile, :league
    ]
    US_CUSTOMARY_TEMPERATURE_UNITS = [:fahrenheit, :rankine]
    US_CUSTOMARY_VOLUME_UNITS = [
	:acre_foot, :minim, :fluid_dram, :teaspoon, :tablespoon, :fluid_ounce,
	:jigger, :gill, :cup, :pint, :quart, :barrel, :hogshead
    ]
    US_CUSTOMARY_UNITS = US_CUSTOMARY_AREA_UNITS +
			 US_CUSTOMARY_INTERNATIONAL_UNITS +
			 US_CUSTOMARY_MASS_UNITS +
			 US_CUSTOMARY_NAUTICAL_UNITS +
			 US_CUSTOMARY_SURVEY_UNITS +
			 US_CUSTOMARY_TEMPERATURE_UNITS +
			 US_CUSTOMARY_VOLUME_UNITS

    ABBREVIATIONS = {
	:mm => 'millimeter', :cm => 'centimeter', :km => 'kilometer',
    }
    ABBREVIATION_EXP = Regexp.new('\A(?<abbreviation>' + ABBREVIATIONS.keys.join('|') + ')')

    PREFIX_ABBREVIATIONS = {
	:yocto => 'y',	:zepto => 'z',	:atto  => 'a',	:femto => 'f',
	:pico  => 'p',	:nano  => 'n',	:micro => 'u',	:milli => 'm',
	:centi => 'c',	:deci  => 'd',	:deca  => 'da',	:hecto => 'h',
	:kilo  => 'k',	:mega  => 'M',	:giga  => 'G',	:tera  => 'T',
	:peta  => 'P',	:exa   => 'E',	:zetta => 'Z',	:yotta => 'Y',
    }

    SI_UNIT_ABBREVIATIONS = {
	:meter	=> 'm',	:gram	 => 'g',    :second => 's',	:ampere => 'A',
	:kelvin => 'K',	:candela => 'cd',   :mole   => 'mol'
    }

    US_CUSTOMARY_UNIT_ABBREVIATIONS = {
    }

    UNITS = SI_UNITS + SI_DERIVED + US_CUSTOMARY_UNITS + [:degrees]
    UNIT_ABBREVIATIONS = SI_UNIT_ABBREVIATIONS.merge(US_CUSTOMARY_UNIT_ABBREVIATIONS)

    BASE_CAPTURE = '(?<base>' + UNITS.each {|u| u.to_s }.join('|') + ')'
    PREFIX_CAPTURE = '(?<prefix>' + PREFIXES.keys.each {|u| u.to_s }.join('|') + ')?'
    PARSER_EXP = Regexp.new('\A'+PREFIX_CAPTURE+BASE_CAPTURE+'(s|es)?')
end
