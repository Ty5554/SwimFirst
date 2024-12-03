class Condition < ApplicationRecord
  belongs_to :user

  validates :fatigue_level, presence: true, numericality: { greater_than: 0, less_than: 100 } # 体温は30℃〜45℃の範囲
  validates :body_temperature, presence: true, numericality: { greater_than_or_equal_to: 30, less_than_or_equal_to: 45 } # 0〜24時間
  validates :sleep_hours, presence: true# 0〜100
  validates :mental_state, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :recorded_on, presence: true
end
