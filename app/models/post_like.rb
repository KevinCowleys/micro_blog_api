class PostLike < ApplicationRecord
  validates :post_id, uniqueness: { scope: :user_id }
  # Relationships
  belongs_to :post
  belongs_to :user
end
