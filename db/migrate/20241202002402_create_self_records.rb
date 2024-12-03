class CreateSelfRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :self_records do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :style, null: false
      t.integer :distance, null: false
      t.float :record, null: false
      t.date :recorded_on, null: false

      t.timestamps
    end
  end
end
