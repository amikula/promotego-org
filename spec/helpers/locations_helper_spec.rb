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

  describe :visible_affiliations do
    before :each do
      @location = stub_model(Location)
      assigns[:location] = @location

      @user = stub_model(User)
      @user.stub!(:has_role?).and_return(false)
      @user.stub!(:administers).and_return(false)
      helper.stub!(:current_user).and_return(@user)

      @affiliates = []
      @affiliations = []
      %w{aff1 aff2 aff3}.each do |aff_name|
        affiliate = stub_model(Affiliate, :name => aff_name)
        @affiliates << affiliate
        @affiliations << stub_model(Affiliation, :affiliate => affiliate)
      end
      Affiliate.stub!(:find).with(:all).and_return(@affiliates)
    end

    it 'returns something responding to :each' do
      helper.visible_affiliations.should respond_to(:each)
    end

    it "returns affiliations on @location that the current user administrates" do
      @user.should_receive(:administers).with(@affiliations[1]).at_least(1).and_return(true)

      @location.should_receive(:affiliations).and_return(@affiliations)
      Affiliate.stub!(:find).with(:all).and_return([])

      helper.visible_affiliations.should == [@affiliations[1]]
    end

    it "returns an empty array if current user is nil" do
      helper.should_receive(:current_user).and_return(nil)

      helper.visible_affiliations.should == []
    end

    it "shows all affiliations to administrators" do
      affiliations = []
      @user.should_receive(:has_role?).with(:administrator).and_return(true)
      @location.should_receive(:affiliations).and_return(affiliations)
      Affiliate.stub!(:find).with(:all).and_return([])

      helper.visible_affiliations.should == affiliations
    end

    it "adds a blank affiliation for each affiliate that the user administers" do
      @user.stub!(:administers).and_return(true)

      helper.visible_affiliations.collect{|a| a.affiliate.name}.should == @affiliations.collect{|a| a.affiliate.name}
    end

    it "does not add a blank affiliation for affiliates already in the list of affiliations" do
      @user.stub!(:has_role?).with(:administrator).and_return(true)
      @location.should_receive(:affiliations).and_return(@affiliations)

      helper.visible_affiliations.collect{|a| a.id}.should == @affiliations.collect{|a| a.id}
    end

    it "doesn't modify the location's original list of affiliations when the user administers each" do
      @affiliations.delete_at(1)
      orig_affiliations = @affiliations.dup
      @user.stub!(:administers).and_return(true)

      helper.visible_affiliations

      @affiliations.should == orig_affiliations
    end

    it "doesn't modify the location's original list of affiliations when the user is administrator" do
      @affiliations.delete_at(1)
      @location.stub!(:affiliations).and_return(@affiliations)
      orig_affiliations = @affiliations.dup
      @user.stub!(:has_role?).with(:administrator).and_return(true)

      helper.visible_affiliations

      @affiliations.should == orig_affiliations
    end

    it "doesn't add blank affiliations for affiliates the user doesn't administer" do
      @affiliates[0..-2].each do |affiliate|
        @user.should_receive(:administers).with(affiliate).and_return(false)
      end
      @user.should_receive(:administers).with(@affiliates[-1]).and_return(true)

      helper.visible_affiliations.map{|a| a.affiliate.name}.should == [@affiliates[-1].name]
    end
  end

  describe :state_select_hash do
    before :each do
      helper.stub!(:has_provinces?).and_return(true)
    end

    it 'has a key for US and Canada' do
      helper.should_receive(:merge_translation_hashes).any_number_of_times

      helper.state_select_hash.should have_key('US')
      helper.state_select_hash.should have_key('CA')
    end

    it 'creates selectors based on the merged translation hashes' do
      helper.stub!(:merge_translation_hashes)
      helper.should_receive(:merge_translation_hashes).with(:CA, :provinces).and_return(:AB => 'Alberta')
      helper.should_receive(:merge_translation_hashes).with(:US, :provinces).and_return(:TX => 'Texas', :CA => 'California')

      hash = helper.state_select_hash
      hash['US'].should have_tag('option[value=?]', 'TX', 'Texas')
      hash['US'].should have_tag('option[value=?]', 'CA', 'California')
    end

    it 'inserts nil hash values for countries when has_provinces? returns false' do
      helper.stub!(:merge_translation_hashes)
      helper.should_receive(:has_provinces?).with(:SE).and_return(false)
      helper.should_receive(:has_provinces?).with(:IL).and_return(false)

      hash = helper.state_select_hash
      hash.should have_key('SE')
      hash['SE'].should == nil
      hash.should have_key('IL')
      hash['IL'].should == nil
    end
  end
end
