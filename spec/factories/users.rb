# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    mobile     { Faker::PhoneNumber.phone_number }
    factory :reviewer do
      permissions { [create(:reviewer_permission)] }
    end

    factory :supervisor do
      permissions { [create(:supervisor_permission)] }
    end

    factory :administrator do
      permissions { [create(:administrator_permission)] }
    end
  end

  factory :user_with_specifics, parent: :user do
    mobile {"+85211111111"}
    after(:create) do |user|
      user.auth_tokens << create(:scenario_before_auth_token)
    end
  end

end
