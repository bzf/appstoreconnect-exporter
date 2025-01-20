AppStoreConnect.config = {
  issuer_id: ENV.fetch("APP_STORE_CONNECT_ISSUER_ID"),
  key_id: ENV.fetch("APP_STORE_CONNECT_KEY_ID"),
  private_key: ENV.fetch("APP_STORE_CONNECT_PRIVATE_KEY")
}

VENDOR_ID = ENV.fetch("APP_STORE_CONNECT_VENDOR_NUMBER")
