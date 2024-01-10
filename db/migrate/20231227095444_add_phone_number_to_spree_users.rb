class AddPhoneNumberToSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :phone_number, :string
    add_column :spree_users, :phone_country_code, :string
    add_column :spree_users, :otp, :string
    add_column :spree_users, :user_active, :boolean, default: false
    add_column :spree_users, :first_name, :string
    add_column :spree_users, :last_name, :string
  end
end
