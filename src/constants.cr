require "action-controller/logger"
require "secrets-env"

module App
  NAME    = "Wallet-Api"
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify.downcase }}

  Log         = ::Log.for(NAME)
  LOG_BACKEND = ActionController.default_backend

  ENVIRONMENT = ENV["SG_ENV"]? || "development"

  DEFAULT_PORT          = (ENV["SG_SERVER_PORT"]? || 3000).to_i
  DEFAULT_HOST          = ENV["SG_SERVER_HOST"]? || "127.0.0.1"
  DEFAULT_PROCESS_COUNT = (ENV["SG_PROCESS_COUNT"]? || 1).to_i

  STATIC_FILE_PATH = ENV["PUBLIC_WWW_PATH"]? || "./www"

  COOKIE_SESSION_KEY    = ENV["COOKIE_SESSION_KEY"]? || "_spider_gazelle_"
  COOKIE_SESSION_SECRET = ENV["COOKIE_SESSION_SECRET"]? || "4f74c0b358d5bab4000dd3c75465dc2c"

  # General
  API_KEY = ENV["API_KEY"]?

  # # Environment Variables
  # Google
  GOOGLE_PRIVATE_KEY        = self.required_environment("GOOGLE_PRIVATE_KEY")
  GOOGLE_CLIENT_EMAIL       = self.required_environment("GOOGLE_CLIENT_EMAIL")
  GOOGLE_WALLET_ISSUER_ID   = self.required_environment("GOOGLE_WALLET_ISSUER_ID")
  GOOGLE_WALLET_ISSUER_NAME = self.required_environment("GOOGLE_WALLET_ISSUER_NAME")
  GOOGLE_LOGO_IMAGE_URL     = ENV["GOOGLE_LOGO_IMAGE_URL"]?
  GOOGLE_LOGO_DESCRIPTION   = ENV["GOOGLE_LOGO_DESCRIPTION"]?

  # Apple
  APPLE_PASS_TYPE_IDENTIFIER    = self.required_environment("APPLE_PASS_TYPE_IDENTIFIER")
  APPLE_TEAM_IDENTIFIER         = self.required_environment("APPLE_TEAM_IDENTIFIER")
  APPLE_ORGANIZATION_NAME       = self.required_environment("APPLE_ORGANIZATION_NAME")
  APPLE_DESIGN_FOREGROUND_COLOR = self.required_environment("APPLE_DESIGN_FOREGROUND_COLOR")
  APPLE_DESIGN_BACKGROUND_COLOR = self.required_environment("APPLE_DESIGN_BACKGROUND_COLOR")
  APPLE_DESIGN_LABEL_COLOR      = self.required_environment("APPLE_DESIGN_LABEL_COLOR")
  APPLE_LOGO_PATH               = self.required_environment("APPLE_LOGO_PATH")
  APPLE_ICON_PATH               = self.required_environment("APPLE_ICON_PATH")
  APPLE_LOGO_DESCRIPTION        = self.required_environment("APPLE_LOGO_DESCRIPTION")

  # AWS
  AWS_REGION = self.required_environment("AWS_REGION")
  AWS_KEY    = self.required_environment("AWS_KEY")
  AWS_SECRET = self.required_environment("AWS_SECRET")
  AWS_BUCKET = self.required_environment("AWS_BUCKET")

  class_getter? production : Bool = ENVIRONMENT.downcase == "production"

  def self.required_environment(key)
    ENV[key]?.presence || abort("missing required environment variable #{key}")
  end
end
