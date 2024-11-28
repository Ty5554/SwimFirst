class CreateRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :roles do |t|
      t.integer :role
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
