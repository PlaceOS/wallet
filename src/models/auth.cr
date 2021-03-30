class Auth
  @signing_key : String

  def initialize(@scopes : String)
    @signing_key = read_base64_key(App::GOOGLE_PRIVATE_KEY)
    @issuer = App::GOOGLE_CLIENT_EMAIL
  end

  def call
    Google::Auth.new(issuer: @issuer, signing_key: @signing_key, scopes: @scopes, sub: "", user_agent: Google::Auth::DEFAULT_USER_AGENT)
  end

  private def read_base64_key(key : String) : String
    raise ArgumentError.new("Base64-encoded Key is empty") unless key.presence
    String.new(Base64.decode(key))
  end
end
