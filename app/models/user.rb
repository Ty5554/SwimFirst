class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :role, dependent: :destroy
  has_many :team_invitations
  has_many :teams, through: :team_invitations

  accepts_nested_attributes_for :role
  accepts_nested_attributes_for :teams
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
