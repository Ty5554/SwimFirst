class Condition < ApplicationRecord
  belongs_to :user

  validates :fatigue_level, presence: true, numericality: { greater_than: 0, less_than: 11 }
  validates :body_temperature, presence: true, numericality: { greater_than_or_equal_to: 30, less_than_or_equal_to: 45 } # 0〜24時間
  validates :sleep_hours, presence: true# 0〜100
  validates :mental_state, presence: true, numericality: { greater_than: 0, less_than: 11 }
  validates :recorded_on, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "fatigue_level", "id", "body_temperature", "recorded_on", "sleep_hours", "mental_state", "updated_at", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end
end
