require File.dirname(__FILE__) + '/../spec_helper'

describe RolesController do
  describe "handling GET /roles" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:find).and_return([@role])
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
  
    it "should find all roles" do
      Role.should_receive(:find).with(:all).and_return([@role])
      do_get
    end
  
    it "should assign the found roles for the view" do
      do_get
      assigns[:roles].should == [@role]
    end
  end

  describe "handling GET /roles.xml" do

    before(:each) do
      @role = mock_model(Role, :to_xml => "XML")
      Role.stub!(:find).and_return(@role)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all roles" do
      Role.should_receive(:find).with(:all).and_return([@role])
      do_get
    end
  
    it "should render the found roles as xml" do
      @role.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /roles/1" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:find).and_return(@role)
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
  
    it "should find the role requested" do
      Role.should_receive(:find).with("1").and_return(@role)
      do_get
    end
  
    it "should assign the found role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling GET /roles/1.xml" do

    before(:each) do
      @role = mock_model(Role, :to_xml => "XML")
      Role.stub!(:find).and_return(@role)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the role requested" do
      Role.should_receive(:find).with("1").and_return(@role)
      do_get
    end
  
    it "should render the found role as xml" do
      @role.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /roles/new" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:new).and_return(@role)
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
  
    it "should create an new role" do
      Role.should_receive(:new).and_return(@role)
      do_get
    end
  
    it "should not save the new role" do
      @role.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling GET /roles/1/edit" do

    before(:each) do
      @role = mock_model(Role)
      Role.stub!(:find).and_return(@role)
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
  
    it "should find the role requested" do
      Role.should_receive(:find).and_return(@role)
      do_get
    end
  
    it "should assign the found Role for the view" do
      do_get
      assigns[:role].should equal(@role)
    end
  end

  describe "handling POST /roles" do

    before(:each) do
      @role = mock_model(Role, :to_param => "1")
      Role.stub!(:new).and_return(@role)
    end
    
    describe "with successful save" do
  
      def do_post
        @role.should_receive(:save).and_return(true)
        post :create, :role => {}
      end
  
      it "should create a new role" do
        Role.should_receive(:new).with({}).and_return(@role)
        do_post
      end

      it "should redirect to the new role" do
        do_post
        response.should redirect_to(role_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @role.should_receive(:save).and_return(false)
        post :create, :role => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /roles/1" do

    before(:each) do
      @role = mock_model(Role, :to_param => "1")
      Role.stub!(:find).and_return(@role)
    end
    
    describe "with successful update" do

      def do_put
        @role.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the role requested" do
        Role.should_receive(:find).with("1").and_return(@role)
        do_put
      end

      it "should update the found role" do
        do_put
        assigns(:role).should equal(@role)
      end

      it "should assign the found role for the view" do
        do_put
        assigns(:role).should equal(@role)
      end

      it "should redirect to the role" do
        do_put
        response.should redirect_to(role_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @role.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /roles/1" do

    before(:each) do
      @role = mock_model(Role, :destroy => true)
      Role.stub!(:find).and_return(@role)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the role requested" do
      Role.should_receive(:find).with("1").and_return(@role)
      do_delete
    end
  
    it "should call destroy on the found role" do
      @role.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the roles list" do
      do_delete
      response.should redirect_to(roles_url)
    end
  end
end