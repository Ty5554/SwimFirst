class CreateTeamInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :team_invitations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
