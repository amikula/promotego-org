#
# Replace Rails' cruddy parameter parsing code with something more predictable.
#
class ActionController::AbstractRequest::UrlEncodedPairParser
  attr_reader :result

  #
  # Initialize a new parameter parser.
  #
  def initialize(params=[])
    @result = {}
    params.each { |key, value| parse(key, value) }
  end

  ROOT_REGEX = /[^\[]+/
  ARRAY_REGEX = /\[([0-9]*)\]/
  HASH_REGEX = /\[([^\]]+)\]/

  #
  # Parse a single key/value pair into the internal parameter hash.
  #
  def parse(key, value)
    lex = StringScanner.new(key)
    current = lex.scan(ROOT_REGEX) or return
    ref = result

    until lex.eos?
      if lex.scan(ARRAY_REGEX)
        ref[current] ||= []
        check_type(Array, ref, current)
        if lex[1].empty?
          key = ref[current].length
        else
          key = lex[1].to_i
        end
      elsif lex.scan(HASH_REGEX)
        ref[current] ||= {}.with_indifferent_access
        check_type(Hash, ref, current)
        key = lex[1]
      else
        break
      end
      ref = ref[current]
      current = key
    end

    ref[current] = value unless ref[current]
    result
  end

  #
  # If we receive parameters indicating a key being treated as both an
  # Array and a Hash, we complain about it: just like Real Rails!
  #
  def check_type(expected, actual, key)
    if !actual[key].kind_of?(expected)
      raise TypeError,
        "Ambiguous type encountered while parsing parameters: expected " +
        "#{expected} but got #{actual[key].class} for key #{key} in " +
        "#{actual.inspect}"
    end
  end
end
