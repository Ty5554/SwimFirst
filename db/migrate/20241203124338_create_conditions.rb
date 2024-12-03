class CreateConditions < ActiveRecord::Migration[7.2]
  def change
    create_table :conditions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :fatigue_level, null: false
      t.float :body_temperature, null: false
      t.float :sleep_hours, null: false
      t.integer :mental_state, null: false
      t.date :recorded_on, null: false

      t.timestamps
    end
  end
end
