class Auth
  def initialize(@scopes : String)
    @file_path = File.expand_path(ENV["GOOGLE_AUTH_FILE"])
  end

  def call
    Google::FileAuth.new(file_path: @file_path, scopes: @scopes)
  end
end
