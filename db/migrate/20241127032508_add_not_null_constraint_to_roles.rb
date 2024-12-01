class AddNotNullConstraintToRoles < ActiveRecord::Migration[7.2]
  def change
    change_column_null :roles, :user_id, false
  end
end
