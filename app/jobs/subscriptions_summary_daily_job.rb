require "csv"
require "prometheus/client"

class SubscriptionsSummaryDailyJob < ApplicationJob
  LABELS = [ "App Name", "App Apple ID", "Active Standard Price Subscriptions", "Active Free Trial Introductory Offer Subscriptions", "Subscription Name", "Standard Subscription Duration", "Customer Price", "Customer Currency", "Developer Proceeds", "Proceeds Currency", "Device", "Country" ].sort
  SUBSCRIPTIONS_TOTAL = Prometheus::Client.registry.gauge(
    :subscriptions_total,
    docstring: "Total subscriptions",
    labels: LABELS.uniq.map { _1.parameterize.underscore.to_sym }
  )

  def perform
    result = CSV.parse(data, col_sep: "\t", headers: true).map(&:to_h).map(&:with_indifferent_access)

    result.each do |data|
      SUBSCRIPTIONS_TOTAL.set(
        data["Subscribers"].to_i,
        labels: data.slice(*LABELS).transform_keys { _1.parameterize.underscore.to_sym }.symbolize_keys
      )
    end
  end

  private

  def data
    Rails.cache.fetch("subscriptions_summary_daily", expires_in: 30.minutes) do
      client.sales_reports(
        filter: {
          report_type: "SUBSCRIPTION",
          report_sub_type: "SUMMARY",
          frequency: "DAILY",
          vendor_number: VENDOR_ID,
          version: "1_4"
        }
      )
    end
  end

  def client
    @client ||= AppStoreConnect::Client.new
  end
end
