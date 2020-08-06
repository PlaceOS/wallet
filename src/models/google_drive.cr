require "google"

class GoogleDrive
  def self.build
    auth = Auth.new(scopes: "https://www.googleapis.com/auth/drive").call
    Google::Files.new(auth: auth)
  end
end
