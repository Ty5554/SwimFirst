class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :team_name, null: false
      t.string :invitation_token, null: false
      t.timestamps
    end

    add_index :teams, :invitation_token, unique: true
  end
end
