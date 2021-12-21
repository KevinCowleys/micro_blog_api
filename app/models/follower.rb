class Follower < ApplicationRecord
  belongs_to :following, -> { select(:id, :name, :username) }, class_name: 'User'
  belongs_to :follower, -> { select(:id, :name, :username) }, class_name: 'User'
end
