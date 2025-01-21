require "ostruct"
require "prometheus/client"

class CustomerReviewsDailyJob < ApplicationJob
  LABELS = [ :app_id, :app_name, :rating ]
  SUBSCRIPTIONS_TOTAL = Prometheus::Client.registry.gauge(
    :app_ratings_total,
    docstring: "Number of App Store reviews with a given rating",
    labels: LABELS,
    store_settings: { aggregation: :most_recent }
  )

  def perform
    apps.map do |app|
      customer_reviews(app.id)
        .map { _1.dig(:attributes, :rating) }
        .tally
        .with_defaults(1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0)
        .each do |rating, count|
          SUBSCRIPTIONS_TOTAL.set(
            count,
            labels: {
              app_id: app.id,
              app_name: app.name,
              rating:
            }
          )
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
