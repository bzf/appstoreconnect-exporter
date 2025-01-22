class CreateSalesSummaryDailies < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_summary_dailies do |t|
      t.string :provider, null: false
      t.string :sku, null: false
      t.string :version, null: false
      t.date :date, null: false
      t.string :country_code, null: false
      t.string :customer_currency, null: false
      t.string :promo_code
      t.string :device, null: false
      t.integer :units, null: false
      t.integer :developer_proceeds_in_cents, null: false
      t.json :payload

      t.timestamps
    end
  end
end
