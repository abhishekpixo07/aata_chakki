class SolidusSubscriptions::SubscriptionPlan < ApplicationRecord
    validates :title, presence: true
end
