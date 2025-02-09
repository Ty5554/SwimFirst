class AddFeedbackToDiaries < ActiveRecord::Migration[7.2]
  def change
    add_column :diaries, :feedback, :text
  end
end
