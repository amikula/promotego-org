COUNTRY_FROM_ABBREV = YAML.load(File.new("db/country-codes.yml"))
COUNTRY_TO_ABBREV = COUNTRY_FROM_ABBREV.invert
STATE_FROM_ABBREV = YAML.load(File.new("db/states_provinces.yml"))
STATE_TO_ABBREV = Hash[STATE_FROM_ABBREV.map{|key,value| [key, value.invert]}]
