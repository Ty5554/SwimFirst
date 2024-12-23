class CreateHeartRates < ActiveRecord::Migration[7.2]
  def change
    create_table :heart_rates do |t|
      t.references :training_set, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :training_heart_rate, null: false
      t.timestamps
    end

    remove_column :training_sets, :heart_rate, :integer
    remove_column :training_sets, :athlete_id, :bigint
  end
end
