class AddSubscriptionPlanIdToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :solidus_subscriptions_subscriptions, :subscription_plan_id, :integer
  end
end
