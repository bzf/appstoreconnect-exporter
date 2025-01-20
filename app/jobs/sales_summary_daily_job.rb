require "csv"
require "prometheus/client"

class SalesSummaryDailyJob < ApplicationJob
  LABELS = ["Provider", "SKU", "Version", "Begin Date", "End Date", "Country Code", "Customer Currency", "Promo Code", "Device"].sort
  APP_UNITS_TOTAL = Prometheus::Client.registry.gauge(
    :app_units_total,
    docstring: "Total app units",
    labels: LABELS.uniq.map { _1.parameterize.underscore.to_sym }
  )

  DEVELOPER_PROCEEDS = Prometheus::Client.registry.gauge(
    :developer_proceeds,
    docstring: "Total app units",
    labels: LABELS.uniq.map { _1.parameterize.underscore.to_sym }
  )

  def perform
    result = CSV.parse(data, col_sep: "\t", headers: true).map(&:to_h).map(&:with_indifferent_access)

    result.each do |data|
      APP_UNITS_TOTAL.set(
        data["Units"].to_i,
        labels: data.slice(*LABELS).transform_keys { _1.parameterize.underscore.to_sym }.symbolize_keys
      )
      DEVELOPER_PROCEEDS.set(
        data["Developer Proceeds"].to_f,
        labels: data.slice(*LABELS).transform_keys { _1.parameterize.underscore.to_sym }.symbolize_keys
      )
    end
  end

  private

  def data
    Rails.cache.fetch("sales_summary_daily", expires_in: 1.hour) do
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
