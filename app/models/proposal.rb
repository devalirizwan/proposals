class Proposal < ApplicationRecord
  has_many :proposal_locations, dependent: :destroy
  has_many :locations, through: :proposal_locations
  belongs_to :proposal_type
  has_many :proposal_roles, dependent: :destroy
end
