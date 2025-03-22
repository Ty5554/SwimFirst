require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
  describe "新規登録チェック" do
    it "有効なユーザーは登録できる" do
      user = build(:user)
      expect(user).to be_valid
    end
  end
end
