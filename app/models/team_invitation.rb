class TeamInvitation < ApplicationRecord
  belongs_to :user
  belongs_to :team

  enum status: { pending: "pending", approved: "approved" }

  validates :status, presence: true
end
