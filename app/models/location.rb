class Location < ActiveRecord::Base
  acts_as_mappable
  belongs_to :type
end
