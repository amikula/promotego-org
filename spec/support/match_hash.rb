class MatchHash
  def initialize(expected)
    @expected = expected
  end

  def matches?(target)
    @target = target
    failure_start = "expected #{@expected.inspect}, but "

    case target
    when nil
      @failure_message = failure_start + "target is nil"
      return false
    when Hash
      target_keys = target.keys.to_a
      expected_keys = @expected.keys.to_a

      if ((missing = expected_keys - target_keys).size > 0)
        @failure_message = failure_start + "target is missing keys " +
          missing.join(", ")
        return false
      elsif ((extra = target_keys - expected_keys).size > 0)
        @failure_message = failure_start + "target has extra keys " +
          extra.inject(""){|string, key| string + "#{key.to_s}=#{target[key]} "}
        return false
      else
        mismatched_keys = []

        expected_keys.each do |key|
          if(@expected[key] != @target[key])
            mismatched_keys << key
          end
        end

        if (mismatched_keys.size > 0)
          @failure_message = failure_start + "these keys do not match in #{@target.inspect}: " +
            mismatched_keys.join(", ")
          return false
        else
          return true
        end
      end
    else
      @failure_message = failure_start + "target is not a Hash"
      return false
    end
  end

  def failure_message
    @failure_message
  end

  def negative_failure_message
    "expected #{@target.inspect} not to match hash #{@expected}"
  end
end

def match_hash(expected)
  MatchHash.new(expected)
end
