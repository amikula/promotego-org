require File.dirname(__FILE__) + '/../spec_helper'

describe TypesController do
  describe "handling GET /types" do

    before(:each) do
      @type = mock_model(Type)
      Type.stub!(:find).and_return([@type])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all types" do
      Type.should_receive(:find).with(:all).and_return([@type])
      do_get
    end
  
    it "should assign the found types for the view" do
      do_get
      assigns[:types].should == [@type]
    end
  end

  describe "handling GET /types.xml" do

    before(:each) do
      @type = mock_model(Type, :to_xml => "XML")
      Type.stub!(:find).and_return(@type)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all types" do
      Type.should_receive(:find).with(:all).and_return([@type])
      do_get
    end
  
    it "should render the found types as xml" do
      @type.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /types/1" do

    before(:each) do
      @type = mock_model(Type)
      Type.stub!(:find).and_return(@type)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the type requested" do
      Type.should_receive(:find).with("1").and_return(@type)
      do_get
    end
  
    it "should assign the found type for the view" do
      do_get
      assigns[:type].should equal(@type)
    end
  end

  describe "handling GET /types/1.xml" do

    before(:each) do
      @type = mock_model(Type, :to_xml => "XML")
      Type.stub!(:find).and_return(@type)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the type requested" do
      Type.should_receive(:find).with("1").and_return(@type)
      do_get
    end
  
    it "should render the found type as xml" do
      @type.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /types/new" do

    before(:each) do
      @type = mock_model(Type)
      Type.stub!(:new).and_return(@type)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new type" do
      Type.should_receive(:new).and_return(@type)
      do_get
    end
  
    it "should not save the new type" do
      @type.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new type for the view" do
      do_get
      assigns[:type].should equal(@type)
    end
  end

  describe "handling GET /types/1/edit" do

    before(:each) do
      @type = mock_model(Type)
      Type.stub!(:find).and_return(@type)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the type requested" do
      Type.should_receive(:find).and_return(@type)
      do_get
    end
  
    it "should assign the found Type for the view" do
      do_get
      assigns[:type].should equal(@type)
    end
  end

  describe "handling POST /types" do

    before(:each) do
      @type = mock_model(Type, :to_param => "1")
      Type.stub!(:new).and_return(@type)
    end
    
    describe "with successful save" do
  
      def do_post
        @type.should_receive(:save).and_return(true)
        post :create, :type => {}
      end
  
      it "should create a new type" do
        Type.should_receive(:new).with({}).and_return(@type)
        do_post
      end

      it "should redirect to the new type" do
        do_post
        response.should redirect_to(type_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @type.should_receive(:save).and_return(false)
        post :create, :type => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /types/1" do

    before(:each) do
      @type = mock_model(Type, :to_param => "1")
      Type.stub!(:find).and_return(@type)
    end
    
    describe "with successful update" do

      def do_put
        @type.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the type requested" do
        Type.should_receive(:find).with("1").and_return(@type)
        do_put
      end

      it "should update the found type" do
        do_put
        assigns(:type).should equal(@type)
      end

      it "should assign the found type for the view" do
        do_put
        assigns(:type).should equal(@type)
      end

      it "should redirect to the type" do
        do_put
        response.should redirect_to(type_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @type.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /types/1" do

    before(:each) do
      @type = mock_model(Type, :destroy => true)
      Type.stub!(:find).and_return(@type)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the type requested" do
      Type.should_receive(:find).with("1").and_return(@type)
      do_delete
    end
  
    it "should call destroy on the found type" do
      @type.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the types list" do
      do_delete
      response.should redirect_to(types_url)
    end
  end
end