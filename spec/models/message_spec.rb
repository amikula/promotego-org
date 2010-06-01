require 'spec_helper'

describe Message do
  before(:each) do
    @valid_attributes = {
      :sender_id => 1,
      :recipient_id => 1,
      :subject => "value for subject",
      :body => "value for body",
      :read => false,
      :message_responded_to_id => 1,
      :thread_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Message.create!(@valid_attributes)
  end
end
