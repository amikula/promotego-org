require 'test_helper'

class ObfuscatedTest < ActionMailer::TestCase
  tests Obfuscated
  def test_contact
    @expected.subject = 'Obfuscated#contact'
    @expected.body    = read_fixture('contact')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Obfuscated.create_contact(@expected.date).encoded
  end

end
