class SelfRecord < ApplicationRecord
  belongs_to :user

  enum style: { free_style: 0, back_stroke: 1, breast_stroke: 2, fly: 3, im: 4  } # バリデーションを追加
  validates :style, presence: true
  validates :distance, presence: true
  validates :record, presence: true
  validates :recorded_on, presence: true
end
