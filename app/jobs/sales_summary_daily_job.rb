require "csv"

class SalesSummaryDailyJob < ApplicationJob
  def perform
    result = CSV.parse(data, col_sep: "\t", headers: true).map(&:to_h).map(&:with_indifferent_access)

    result.each do |data|
      summary = SalesSummaryDaily.find_or_initialize_by(
        provider: data["Provider"],
        sku: data["SKU"],
        version: data["Version"],
        date: Date.strptime(data["Begin Date"], "%m/%d/%Y"),
        country_code: data["Country Code"],
        customer_currency: data["Customer Currency"],
        promo_code: data["Promo Code"],
        device: data["Device"]
      )

      summary.units = data["Units"].to_i
      summary.developer_proceeds_in_cents = data["Developer Proceeds"].to_f * 100
      summary.payload = data
      summary.save!
    end
  end

  private

  def data
    Rails.cache.fetch("sales_summary_daily", expires_in: 30.minutes) do
      client.sales_reports(
        filter: {
          report_type: "SALES",
          report_sub_type: "SUMMARY",
          frequency: "DAILY",
          vendor_number: VENDOR_ID
        }
      )
    end
  end

  def client
    @client ||= AppStoreConnect::Client.new
  end
end
