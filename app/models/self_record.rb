class SelfRecord < ApplicationRecord
  belongs_to :user

  enum style: { "自由形": 0, "背泳ぎ": 1, "平泳ぎ": 2, "バタフライ": 3, "個人メドレー": 4  } # バリデーションを追加
  validates :style, presence: true
  validates :distance, presence: true
  validates :record, presence: true
  validates :recorded_on, presence: true

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "distance", "id", "record", "recorded_on", "style", "updated_at", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end
end
