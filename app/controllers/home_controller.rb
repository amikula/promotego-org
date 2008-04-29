class HomeController < ApplicationController
  def index
    # display index.html
    @title = "Welcome to PromoteGo.org!"
  end

  def show
    @title = params[:page].capitalize
    render :action => params[:page]
  end
end
