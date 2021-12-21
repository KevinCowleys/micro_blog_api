class PostShare < ApplicationRecord
  # Relationships
  belongs_to :post
  belongs_to :user
end
