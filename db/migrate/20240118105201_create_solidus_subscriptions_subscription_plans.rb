class CreateSolidusSubscriptionsSubscriptionPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_subscriptions_subscription_plans do |t|
      t.string :title
      t.string :image
      t.text :description
      t.integer :amount

      t.timestamps
    end
  end
end
