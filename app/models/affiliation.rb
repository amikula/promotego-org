class Affiliation < ActiveRecord::Base
  belongs_to :affiliate
  belongs_to :location
end
