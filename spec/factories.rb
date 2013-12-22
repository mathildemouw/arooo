FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    sequence(:email) { |n| "example#{n}@example.com" }
    username { "#{name[0..3]}_#{Faker::Internet.domain_word}"}
    uid { rand(100000...999999) }
    provider { "github" }

    factory :member do
      state "member"
    end

    factory :applicant do
      state "applicant"
    end
  end

  factory :application do
    user
    state "submitted"
    agreement_terms true
    agreement_policies true
    agreement_female true
  end
end
