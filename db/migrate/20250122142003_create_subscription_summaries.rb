class CreateSubscriptionSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_summaries do |t|
      t.string :app_id, null: false
      t.string :app_name, null: false
      t.integer :active_standard_price_subscriptions, null: false
      t.integer :active_free_trial_introductory_offer_subscriptions, null: false
      t.string :subscription_name, null: false
      t.string :standard_subscription_duration, null: false
      t.integer :customer_price_in_cents, null: false
      t.string :customer_currency, null: false
      t.integer :developer_proceeds_in_cents, null: false
      t.string :proceeds_currency, null: false
      t.string :device, null: false
      t.string :country, null: false
      t.integer :subscriptions_total, null: false
      t.date :date, null: false
      t.timestamps
    end
  end
end
