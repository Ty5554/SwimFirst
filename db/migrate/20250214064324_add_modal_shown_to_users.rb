class AddModalShownToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :modal_shown, :boolean, default: false, null: false
  end
end
