class CreateCustomerReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_reviews, id: :uuid do |t|
      t.string :app_id, null: false
      t.string :app_name, null: false
      t.integer :rating, null: false
      t.string :title, null: false
      t.string :nickname, null: false
      t.string :territory, null: false
      t.text :body, null: false
      t.datetime :review_date, null: false
      t.timestamps
    end
  end
end
