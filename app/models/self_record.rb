class SelfRecord < ApplicationRecord
  belongs_to :user

  enum style: { "自由形": 0, "背泳ぎ": 1, "平泳ぎ": 2, "バタフライ": 3, "個人メドレー": 4  } # バリデーションを追加
  validates :style, presence: true
  validates :distance, presence: true
  validates :record, presence: true
  validates :recorded_on, presence: true
end
