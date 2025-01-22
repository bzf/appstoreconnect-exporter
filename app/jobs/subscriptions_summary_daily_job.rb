require "csv"

class SubscriptionsSummaryDailyJob < ApplicationJob
  def perform
    result = CSV.parse(data, col_sep: "\t", headers: true).map(&:to_h).map(&:with_indifferent_access)

    result.each do |data|
      summary = SubscriptionSummary.find_or_initialize_by(
        app_id: data["App Apple ID"],
        app_name: data["App Name"],
        subscription_name: data["Subscription Name"],
        standard_subscription_duration: data["Standard Subscription Duration"],
        customer_price_in_cents: data["Customer Price"].to_f * 100,
        customer_currency: data["Customer Currency"],
        proceeds_currency: data["Proceeds Currency"],
        device: data["Device"],
        country: data["Country"],
        date: Date.today,
      )

      summary.assign_attributes(
        active_standard_price_subscriptions: data["Active Standard Price Subscriptions"],
        active_free_trial_introductory_offer_subscriptions: data["Active Free Trial Introductory Offer Subscriptions"],
        developer_proceeds_in_cents: data["Developer Proceeds"].to_f * 100,
        subscriptions_total: data["Subscribers"].to_i
      )

      summary.save!
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
