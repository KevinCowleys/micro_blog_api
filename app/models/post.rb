class Post < ApplicationRecord
  validates :content, presence: true

  # Relationships
  belongs_to :user
  has_many :post_likes, dependent: :delete_all
  has_many :post_saveds, dependent: :delete_all
  has_many :post_shares, dependent: :delete_all
end
