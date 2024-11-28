class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :role, dependent: :destroy
  accepts_nested_attributes_for :role
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
