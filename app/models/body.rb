class Body < ApplicationRecord
  belongs_to :user

  validates :height, :weight, :body_fat, presence: true
end
