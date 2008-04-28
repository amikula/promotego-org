class HomeController < ApplicationController
  def index
    # display index.html
    @title = "Welcome to Vote!"
  end

  def show
    @title = params[:page].capitalize
    render :action => params[:page]
  end
end
