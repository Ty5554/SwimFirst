# spec/factories/users.rb
FactoryBot.define do
    factory :user do
      first_name { "テスト" }
      last_name { "太郎" }
      sequence(:email) { |n| "test#{n}@example.org" }
      password { "password" }
    end
  end
  