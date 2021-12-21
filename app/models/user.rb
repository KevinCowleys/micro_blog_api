class User < ApplicationRecord
  # adds virtual attributes for authentication
  has_secure_password
  has_one_attached :profile_image
  has_one_attached :profile_banner

  # validates email
  validates :username, presence: true, uniqueness: true, length: { minimum: 1, maximum: 15 }
  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid email' }

  # Relationships
  has_many :posts
  has_many :post_likes
  has_many :post_shares
  has_many :post_saved
  has_many :blocks
  has_many :followers, foreign_key: 'follower_id', class_name: 'Follower'
  has_many :followers, foreign_key: 'following_id', class_name: 'Follower'
  has_many :mutes
end
