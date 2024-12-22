class Body < ApplicationRecord
  belongs_to :user

  validates :height, :weight, :body_fat, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "height", "weight", "body_fat", "recorded_on", "updated_at", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end
end