class CreateTrainingSets < ActiveRecord::Migration[7.2]
  def change
    create_table :training_sets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :training_menu, null: false, foreign_key: true
      t.integer :set_number, null: false
      t.integer :intensity, null: false, default: 0
      t.integer :heart_rate, null: true

      t.timestamps
    end
    add_index :training_sets, [ :training_menu_id, :set_number ], unique: true
  end
end
