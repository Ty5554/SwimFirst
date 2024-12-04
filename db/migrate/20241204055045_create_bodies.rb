class CreateBodies < ActiveRecord::Migration[7.2]
  def change
    create_table :bodies do |t|
      t.references :user, null: false, foreign_key: true
      t.float :height, null: false
      t.float :weight, null: false
      t.float :body_fat, null: false
      t.date :recorded_on

      t.timestamps
    end
  end
end
