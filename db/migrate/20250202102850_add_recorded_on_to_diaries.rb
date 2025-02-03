class AddRecordedOnToDiaries < ActiveRecord::Migration[7.2]
  def change
    add_column :diaries, :recorded_on, :date, null: true
  end
end
