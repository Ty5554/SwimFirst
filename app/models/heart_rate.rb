class HeartRate < ApplicationRecord
  belongs_to :training_set
  belongs_to :user
end
  