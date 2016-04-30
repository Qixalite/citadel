FactoryGirl.define do
  factory :competition do |c|
    sequence(:name) { |n| "OWL #{n}" }
    description "The owl that won't happen"
    format
    c.private true
    signuppable false
    roster_locked false
    matches_submittable false
    min_players 5
    max_players 12
  end
end
