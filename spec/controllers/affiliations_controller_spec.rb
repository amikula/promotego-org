require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliationsController do

  def mock_affiliation(stubs={})
    @mock_affiliation ||= mock_model(Affiliation, stubs)
  end

  describe "responding to GET index" do
    before(:each) do
      controller.should_receive(:require_administrator)
    end

    it "should expose all affiliations as @affiliations" do
      Affiliation.should_receive(:find).with(:all).and_return([mock_affiliation])
      get :index
      assigns[:affiliations].should == [mock_affiliation]
    end

    describe "with mime type of xml" do

      it "should render all affiliations as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Affiliation.should_receive(:find).with(:all).and_return(affiliations = mock("Array of Affiliations"))
        affiliations.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET show" do
    before(:each) do
      controller.should_receive(:require_administrator)
    end

    it "should expose the requested affiliation as @affiliation" do
      Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
      get :show, :id => "37"
      assigns[:affiliation].should equal(mock_affiliation)
    end

    describe "with mime type of xml" do

      it "should render the requested affiliation as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
        mock_affiliation.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET new" do
    before(:each) do
      controller.should_receive(:require_affiliate_administrator)
    end

    it "should expose a new affiliation as @affiliation" do
      affiliate = stub_model(Affiliate)
      location = stub_model(Location)
      Affiliation.should_receive(:new).with("affiliate_id" => "affiliate_id", "location_id" => "location_id").and_return(mock_affiliation)
      get :new, :affiliation => {:affiliate_id => "affiliate_id", :location_id => "location_id"}
      assigns[:affiliation].should equal(mock_affiliation)
    end

  end

  describe "responding to GET edit" do
    before(:each) do
      controller.should_receive(:require_administrator)
    end

    it "should expose the requested affiliation as @affiliation" do
      Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
      get :edit, :id => "37"
      assigns[:affiliation].should equal(mock_affiliation)
    end

  end

  describe "responding to POST create" do
    before(:each) do
      controller.should_receive(:require_affiliate_administrator)
    end

    describe "with valid params" do
      before :each do
        @location = mock_model(Location, :slug => 'location_slug')
      end

      it "should expose a newly created affiliation as @affiliation" do
        Affiliation.should_receive(:new).with({'these' => 'params'}).and_return(mock_affiliation(:save => true, :location => @location))
        post :create, :affiliation => {:these => 'params'}
        assigns(:affiliation).should equal(mock_affiliation)
      end

      it "should redirect to the associated location" do
        Affiliation.stub!(:new).and_return(mock_affiliation(:save => true, :location => @location))
        post :create, :affiliation => {}
        response.should redirect_to(:controller => :locations, :action => :show, :id => @location.slug)
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved affiliation as @affiliation" do
        Affiliation.stub!(:new).with({'these' => 'params'}).and_return(mock_affiliation(:save => false))
        post :create, :affiliation => {:these => 'params'}
        assigns(:affiliation).should equal(mock_affiliation)
      end

      it "should re-render the 'new' template" do
        Affiliation.stub!(:new).and_return(mock_affiliation(:save => false))
        post :create, :affiliation => {}
        response.should render_template('new')
      end

    end

  end

  describe "responding to PUT udpate" do
    before(:each) do
      controller.should_receive(:require_affiliate_administrator)
    end

    describe "with valid params" do
      before :each do
        @location = mock_model(Location, :slug => 'location_slug')
      end

      it "should update the requested affiliation" do
        Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
        mock_affiliation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :affiliation => {:these => 'params'}
      end

      it "should expose the requested affiliation as @affiliation" do
        Affiliation.stub!(:find).and_return(mock_affiliation(:update_attributes => true, :location => @location))
        put :update, :id => "1"
        assigns(:affiliation).should equal(mock_affiliation)
      end

      it "should redirect to the associated location" do
        Affiliation.stub!(:find).and_return(mock_affiliation(:update_attributes => true, :location => @location))
        put :update, :id => "1"
        response.should redirect_to(:controller => :locations, :action => :show, :id => @location.slug)
      end

    end

    describe "with invalid params" do

      it "should update the requested affiliation" do
        Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
        mock_affiliation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :affiliation => {:these => 'params'}
      end

      it "should expose the affiliation as @affiliation" do
        Affiliation.stub!(:find).and_return(mock_affiliation(:update_attributes => false))
        put :update, :id => "1"
        assigns(:affiliation).should equal(mock_affiliation)
      end

      it "should re-render the 'edit' template" do
        Affiliation.stub!(:find).and_return(mock_affiliation(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do
    before(:each) do
      controller.should_receive(:require_affiliate_administrator)
      @location = mock_model(Location, :slug => 'location_slug')
    end

    it "should destroy the requested affiliation" do
      Affiliation.should_receive(:find).with("37").and_return(mock_affiliation(:location => @location))
      mock_affiliation.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the affiliations list" do
      Affiliation.stub!(:find).and_return(mock_affiliation(:destroy => true, :location => @location))
      delete :destroy, :id => "1"
      response.should redirect_to(:controller => :locations, :action => :show, :id => @location.slug)
    end

  end

  describe :require_administrator do
    it "should pass through if the user is an administrator" do
      user = stub_model(User)
      user.should_receive(:has_role?).with(:administrator).and_return(true)
      controller.should_receive(:current_user).any_number_of_times.and_return(user)

      lambda{controller.send(:require_administrator)}.should_not raise_error
    end

    it "should render a 403 if the user is not an administrator" do
      user = stub_model(User)
      user.should_receive(:has_role?).with(:administrator).and_return(false)
      controller.should_receive(:current_user).any_number_of_times.and_return(user)
      controller.should_receive(:render).with(hash_including(:status => 403))

      controller.send(:require_administrator)
    end

    it "should render a 403 if there is no current user" do
      controller.should_receive(:current_user).and_return(nil)
      controller.should_receive(:render).with(hash_including(:status => 403))

      controller.send(:require_administrator)
    end
  end

  describe :require_affiliate_administrator do
    before :each do
      @affiliation = mock_and_find(Affiliation, :affiliate => stub_model(Affiliate, :name => "AFF"))
      @user = stub_model(User)
      controller.stub!(:current_user).any_number_of_times.and_return(@user)
    end

    it "should pass through if the user is an administrator of the affiliate" do
      @user.should_receive(:has_role?).with("aff_administrator").and_return(true)
      controller.stub!(:params).and_return(:id => @affiliation.id.to_s)

      lambda{controller.send(:require_affiliate_administrator)}.should_not raise_error
    end

    it "should render a 403 if the user is not an administrator of the affiliate" do
      @user.should_receive(:has_role?).with("aff_administrator").and_return(false)
      controller.stub!(:params).and_return(:id => @affiliation.id.to_s)
      controller.should_receive(:render).with(hash_including(:status => 403))

      controller.send(:require_affiliate_administrator)
    end

    it "should render a 403 if there is no current user" do
      controller.should_receive(:current_user).and_return(nil)
      controller.should_receive(:render).with(hash_including(:status => 403))

      controller.send(:require_affiliate_administrator)
    end

    it "should check the Affiliate on the new Affiliation if one is being created" do
      controller.stub!(:params).and_return({:affiliation => {:affiliate_id => "affiliate_id"}})
      Affiliation.should_receive(:new).with(hash_including(:affiliate_id => "affiliate_id")).and_return(@affiliation)
      @user.should_receive(:has_role?).with("aff_administrator").and_return(true)

      lambda{controller.send(:require_affiliate_administrator)}.should_not raise_error
    end
  end
end
