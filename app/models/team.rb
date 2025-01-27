class Team < ApplicationRecord
  has_many :team_invitations
  has_many :users, through: :team_invitations

  before_validation :set_invitation_token, on: [ :create, :complete_registration ]

  validates :team_name, presence: true

  private

  def set_invitation_token
    self.invitation_token ||= SecureRandom.hex(10)
  end
end
