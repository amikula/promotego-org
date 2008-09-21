class AddCountryToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :country, :string
    Location.find(:all).each{|l| l.country = "USA"; l.save}
  end

  def self.down
    remove_column :locations, :country
  end
end
