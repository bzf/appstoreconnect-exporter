require "ostruct"

class CustomerReviewsDailyJob < ApplicationJob
  def perform
    apps.map do |app|
      customer_reviews(app.id).each do |review|
          foo = CustomerReview.find_or_initialize_by(id: review[:id])
          foo.assign_attributes(
            app_id: app.id,
            app_name: app.name,
            rating: review.dig(:attributes, :rating),
            title: review.dig(:attributes, :title),
            nickname: review.dig(:attributes, :reviewer_nickname),
            territory: review.dig(:attributes, :territory),
            body: review.dig(:attributes, :body),
            review_date: review.dig(:attributes, :created_date),
          )

          foo.save!
      end
    end
  end

  private

  def customer_reviews(app_id)
    Rails.cache.fetch("apps/#{app_id}/customer-reviews", expires_in: 30.minutes) do
      reviews = []

      page_result = client.send(:call, customer_reviews_endpoint, id: app_id)

      loop do
        puts page_result[:data]&.size
        reviews.concat(page_result[:data] || [])

        if (url = page_result.dig(:links, :next)) && url.present?
          page_result = client.send(
            :call,
            AppStoreConnect::Schema::WebServiceEndpoint.new(http_method: :get, url:),
            id: app_id
          )
        else
          break
        end
      end

      return reviews
    end
  end

  def customer_reviews_endpoint
    AppStoreConnect::Schema::WebServiceEndpoint.new(
      http_method: :get,
      url: "https://api.appstoreconnect.apple.com/v1/apps/{id}/customerReviews"
    )
  end

  def apps
    @apps ||= Rails.cache.fetch("apps", expires_in: 30.minutes) do
      client.apps.dig(:data)
    end.map do |data|
      OpenStruct.new(
        id: data.dig(:id),
        name: data.dig(:attributes, :name),
        sku: data.dig(:attributes, :sku)
      )
    end
  end

  def client
    @client ||= AppStoreConnect::Client.new
  end
end
