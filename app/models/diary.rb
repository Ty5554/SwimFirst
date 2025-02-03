class Diary < ApplicationRecord
  belongs_to :user

  def self.ransackable_attributes(auth_object = nil)
    # ここに検索を許可する属性を配列で指定します。
    # 例として、id, content, recorded_on, created_at, updated_at を許可していますが、
    # 必要に応じて追加・変更してください。
    %w[id content recorded_on created_at updated_at]
  end
end
