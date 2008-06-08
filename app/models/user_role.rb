class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :granting_user, :class_name => "User"
end
