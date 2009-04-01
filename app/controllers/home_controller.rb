class HomeController < ApplicationController
  def index
    # display index.html
    @title = "Promote Go in Your Community!"
  end

  def show
    @title = "Promote Go &mdash; #{params[:page].titleize}"
    render :action => params[:page]
  end
end
