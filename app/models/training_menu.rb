class TrainingMenu < ApplicationRecord
  belongs_to :user
  has_many :training_sets, dependent: :destroy

  validates :training_date, presence: true

  accepts_nested_attributes_for :training_sets
end
