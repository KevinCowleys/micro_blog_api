FactoryBot.define do
  factory :user do
    username { 'MyString' }
    name { 'MyString' }
    email { 'user@fake.com' }
    location { 'MyString' }
    gender { 'male' }
    birth_date { Faker::Time.between_dates(from: Date.today - 99999, to: Date.today, period: :all) }
    website { '' }
    bio { 'MyString' }
  end
end
