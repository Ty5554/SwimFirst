class TrainingSet < ApplicationRecord
  has_many :heart_rates, dependent: :destroy
  belongs_to :user
  belongs_to :training_menu

  validates :set_number, presence: true, numericality: { only_integer: true }
  validates :intensity, presence: true

  before_validation :assign_user

  enum :intensity, { A1: 0, A2: 1, EN1: 2, EN2: 3, EN3: 4, SP1: 5, SP2: 6, SP3: 7 }

  private

  def assign_user
    self.user_id ||= training_menu&.user_id
  end
end
