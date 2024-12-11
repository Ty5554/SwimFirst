class AddAthleteIdTrainingSets < ActiveRecord::Migration[7.2]
  def change
    add_column :training_sets, :athlete_id, :bigint
    add_index :training_sets, :athlete_id
  end
end
