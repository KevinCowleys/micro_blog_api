class Mute < ApplicationRecord
  belongs_to :muted, -> { select(:id, :name, :username) }, class_name: 'User'
  belongs_to :muted_by, -> { select(:id, :name, :username) }, class_name: 'User'
end
