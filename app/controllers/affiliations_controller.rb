class AffiliationsController < ApplicationController
  before_filter :require_administrator, :except => [:create, :update, :destroy]
  before_filter :require_affiliate_administrator, :only => [:create, :update, :destroy]

  # GET /affiliations
  # GET /affiliations.xml
  def index
    @affiliations = Affiliation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @affiliations }
    end
  end

  # GET /affiliations/1
  # GET /affiliations/1.xml
  def show
    @affiliation = Affiliation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @affiliation }
    end
  end

  # GET /affiliations/new
  # GET /affiliations/new.xml
  def new
    @affiliation = Affiliation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @affiliation }
    end
  end

  # GET /affiliations/1/edit
  def edit
    @affiliation = Affiliation.find(params[:id])
  end

  # POST /affiliations
  # POST /affiliations.xml
  def create
    @affiliation = Affiliation.new(params[:affiliation])

    respond_to do |format|
      if @affiliation.save
        flash[:notice] = 'Affiliation was successfully created.'
        format.html { redirect_to(@affiliation) }
        format.xml  { render :xml => @affiliation, :status => :created, :location => @affiliation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @affiliation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /affiliations/1
  # PUT /affiliations/1.xml
  def update
    @affiliation = Affiliation.find(params[:id])

    respond_to do |format|
      if @affiliation.update_attributes(params[:affiliation])
        flash[:notice] = 'Affiliation was successfully updated.'
        format.html { redirect_to(@affiliation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @affiliation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliations/1
  # DELETE /affiliations/1.xml
  def destroy
    @affiliation = Affiliation.find(params[:id])
    @affiliation.destroy

    respond_to do |format|
      format.html { redirect_to(affiliations_url) }
      format.xml  { head :ok }
    end
  end

  def require_administrator
    unless current_user && current_user.has_role?(:administrator)
      render :text => "Access denied", :status => 403
    end
  end

  def require_affiliate_administrator
    if current_user
      @affiliation ||= Affiliation.find(params[:id])
      return if current_user.has_role?("#{@affiliation.affiliate.name.downcase}_administrator")
    end

    render :text => "Access denied", :status => 403
  end
end
