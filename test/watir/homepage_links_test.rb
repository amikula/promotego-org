#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_helper'
require 'firewatir'

class WatirTest < Test::Unit::TestCase
  def setup
    ff.goto("http://localhost:3000")
  end

#  def test_make_a_reservation
#    ff.link(:text, "Make a reservation").click
#    ff.text_field(:id, "reservation_name").value = "Bill"
#    ff.button(:value, "Book this room").click

#    today = Date.today.to_s(:db)
#    tomorrow = (Date.today+1).to_s(:db)
#    assert_match(/Reservation for: Bill/, ff.text)
#    assert_match(/Checking in: *#{today}/i, ff.text)
#    assert_match(/Checking out: *#{tomorrow}/i, ff.text)
#  end

  private

  # Class method to get the cached firefox connection
  def self.ff
    @ff ||= FireWatir::Firefox.new
  end

  # Return the firefox connection cached in the class.
  def ff
    self.class.ff
  end
end
