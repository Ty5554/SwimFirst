class CreateTrainingMenus < ActiveRecord::Migration[7.2]
  def change
    create_table :training_menus do |t|
      t.references :user, null: false, foreign_key: true
      t.date :training_date, null: false
      t.string :description

      t.timestamps
    end
  end
end
