require File.dirname(__FILE__) + '/../spec_helper'

describe LocationsHelper do
  describe :phone_number_type_select do
    it "should render a select tag with the correct name" do
      helper.phone_number_type_select(nil, 0, 1).should have_tag("select[name=?]",
                                       "location[contacts][0][phone][1][type]")
    end

    it "should have all types" do
      helper.phone_number_type_select(nil, 0, 0).should have_tag('select') do
        LocationsHelper::PHONE_NUMBER_TYPES.each do |type|
          with_tag('option', type)
        end
      end
    end

    it "should only have the correct type selected" do
      option_tags = helper.phone_number_type_select('cell', 0, 0)

      option_tags.should have_tag('select') do
        with_tag('option[selected=selected]', 'cell')

        other_types = Array.new(LocationsHelper::PHONE_NUMBER_TYPES)
        other_types.delete('cell')

        other_types.each do |type|
          with_tag('option', type)
          without_tag('option[selected=selected]', type)
        end
      end
    end
  end

  describe :administered_affiliations do
    before :each do
      @location = stub_model(Location)
      @user = stub_model(User)
      @user.stub!(:has_role?).and_return(false)
      helper.stub!(:current_user).and_return(@user)
    end

    it 'returns something responding to :each' do
      helper.administered_affiliations.should respond_to(:each)
    end

    it "returns affiliations on @location that the current user administrates" do
      @user.should_receive(:has_role?).with("aff_administrator").at_least(1).and_return(true)

      affiliations = []
      affiliations << (aff = stub_model(Affiliation, :affiliate => stub_model(Affiliate, :name => 'AFF')))
      affiliations << (other = stub_model(Affiliation, :affiliate => stub_model(Affiliate, :name => 'OTHER')))
      @location.should_receive(:affiliations).and_return(affiliations)

      assigns[:location] = @location

      helper.administered_affiliations.should == [aff]
    end

    it "returns an empty array if current user is nil" do
      helper.should_receive(:current_user).and_return(nil)

      helper.administered_affiliations.should == []
    end
  end
end
