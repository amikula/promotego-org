class Admin::LocationsController < ApplicationController
  active_scaffold :location do |config|
    config.list.columns = [:name, :city, :state, :country, :is_aga]
  end
end
