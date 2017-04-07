FactoryGirl.define do
  factory :location do
    building   { [10..45].sample }
    area       { FFaker::Lorem.characters(1).upcase }
    stockit_id { rand(99) }

    trait :dispatched do
      building 'Dispatched'
    end
  end

end
