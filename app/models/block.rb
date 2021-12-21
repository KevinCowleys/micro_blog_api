class Block < ApplicationRecord
  belongs_to :blocked, -> { select(:id, :name, :username) }, class_name: 'User'
  belongs_to :blocked_by, -> { select(:id, :name, :username) }, class_name: 'User'
end
