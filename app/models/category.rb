class Category < ActiveRecord::Base
  # Associations
  # --------------------
  has_many :cookbooks
end
