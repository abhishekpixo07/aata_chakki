class AddAmountToSolidusSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :solidus_subscriptions_subscriptions, :amount, :integer
  end
end
