require File.dirname(__FILE__) + '/../spec_helper'

describe :CommandLineUtil do
  def subject; CommandLineUtil; end

  before(:each) do
    @user = mock_model(User)
    CommandLineUtil.stub!(:ask)
    CommandLineUtil.stub!(:print)
    CommandLineUtil.stub!(:puts)
    @user.stub!(:valid?).and_return(true)
  end

  describe :input_attribute do
    it "should call STDIN.gets and assign values to the model object" do
      CommandLineUtil.should_receive(:ask).and_return(:value)
      @user.should_receive(:attribute=).with(:value)

      CommandLineUtil.input_attribute(@user, :attribute)
    end

    it "should prompt for the attribute" do
      CommandLineUtil.should_receive(:ask).with(/attr_name/)
      @user.stub!(:attr_name=)

      CommandLineUtil.input_attribute(@user, "attr_name");
    end

    it "should indicate how to send a nil value if nil_ok is true" do
      CommandLineUtil.should_receive(:ask).once.with(/Control-D for nil value/)
      @user.stub!(:attr_name=)

      CommandLineUtil.input_attribute(@user, "attr_name", true)
    end

    it "should not indicate how to send a nil value if nil_ok is false" do
      CommandLineUtil.should_not_receive(:print).with(/Control-D for nil value/)
      @user.stub!(:attr_name=)

      CommandLineUtil.input_attribute(@user, "attr_name")
    end
  end

  describe :get_attributes_with_validation do
    before(:each) do
      @user.stub!(:attribute=)
      @user.stub!(:errors).and_return({})
    end

    it "should call input_attribute with the attribute name" do
      CommandLineUtil.should_receive(:input_attribute).with(@user, :attribute, anything, anything)

      CommandLineUtil.get_attributes_with_validation(@user, :attribute)
    end

    it "should ask for multiple attributes when an array is passed" do
      CommandLineUtil.should_receive(:input_attribute).with(@user, :attribute_1, anything, anything)
      CommandLineUtil.should_receive(:input_attribute).with(@user, :attribute_2, anything, anything)
      @user.stub!(:attribute_1=)
      @user.stub!(:attribute_2=)

      CommandLineUtil.get_attributes_with_validation(@user, [:attribute_1, :attribute_2])
    end

    it "should pass nil_ok=true when nil values validate" do
      @user.should_receive(:errors).and_return(:attribute => nil)
      CommandLineUtil.should_receive(:input_attribute).with(@user, :attribute, true, anything)

      CommandLineUtil.get_attributes_with_validation(@user, :attribute)
    end

    it "should not pass nil_ok=true when nil values do not validate" do
      @user.should_receive(:errors).and_return(:attribute => ["some error"])
      CommandLineUtil.should_receive(:input_attribute).with(@user, :attribute, false, anything)

      CommandLineUtil.get_attributes_with_validation(@user, :attribute)
    end

    it "asks again if validation fails" do
      @user.should_receive(:attribute=).with(nil)
      @user.should_receive(:valid?).and_return(false, false, true)
      @user.should_receive(:errors).and_return({}, {:attribute => ["some error"]}, {})
      CommandLineUtil.should_receive(:input_attribute).twice.with(@user, :attribute, anything, anything)

      CommandLineUtil.get_attributes_with_validation(@user, :attribute)
    end

    it "checks validation for multiple attributes together when an array is passed" do
      @user.should_receive(:attribute1=).with(nil)
      @user.should_receive(:attribute2=).with(nil)
      @user.should_receive(:valid?).exactly(3).times
      @user.should_receive(:errors).and_return({}, {}, {:attribute1 => ["some error"]}, {})
      CommandLineUtil.should_receive(:input_attribute).twice.with(@user, :attribute1, anything, anything)
      CommandLineUtil.should_receive(:input_attribute).twice.with(@user, :attribute2, anything, anything)

      CommandLineUtil.get_attributes_with_validation(@user, [:attribute1, :attribute2])
    end

  end
end
