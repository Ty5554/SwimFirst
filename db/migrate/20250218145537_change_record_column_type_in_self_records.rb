class ChangeRecordColumnTypeInSelfRecords < ActiveRecord::Migration[7.2]
  def up
    change_column :self_records, :record, :integer
  end

  def down
    change_column :self_records, :record, :float
  end
end
