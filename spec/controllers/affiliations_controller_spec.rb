require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliationsController do

  def mock_affiliation(stubs={})
    @mock_affiliation ||= mock_model(Affiliation, stubs)
  end
  
  describe "responding to GET index" do

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
  
    it "should expose a new affiliation as @affiliation" do
      Affiliation.should_receive(:new).and_return(mock_affiliation)
      get :new
      assigns[:affiliation].should equal(mock_affiliation)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested affiliation as @affiliation" do
      Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
      get :edit, :id => "37"
      assigns[:affiliation].should equal(mock_affiliation)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created affiliation as @affiliation" do
        Affiliation.should_receive(:new).with({'these' => 'params'}).and_return(mock_affiliation(:save => true))
        post :create, :affiliation => {:these => 'params'}
        assigns(:affiliation).should equal(mock_affiliation)
      end

      it "should redirect to the created affiliation" do
        Affiliation.stub!(:new).and_return(mock_affiliation(:save => true))
        post :create, :affiliation => {}
        response.should redirect_to(affiliation_url(mock_affiliation))
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

    describe "with valid params" do

      it "should update the requested affiliation" do
        Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
        mock_affiliation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :affiliation => {:these => 'params'}
      end

      it "should expose the requested affiliation as @affiliation" do
        Affiliation.stub!(:find).and_return(mock_affiliation(:update_attributes => true))
        put :update, :id => "1"
        assigns(:affiliation).should equal(mock_affiliation)
      end

      it "should redirect to the affiliation" do
        Affiliation.stub!(:find).and_return(mock_affiliation(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(affiliation_url(mock_affiliation))
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

    it "should destroy the requested affiliation" do
      Affiliation.should_receive(:find).with("37").and_return(mock_affiliation)
      mock_affiliation.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the affiliations list" do
      Affiliation.stub!(:find).and_return(mock_affiliation(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(affiliations_url)
    end

  end

end
