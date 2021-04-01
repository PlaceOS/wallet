require "uuid"
require "active-model"
require "google"

require "../adapters/google_ticket"
require "../adapters/passkit"
require "../adapters/s3"

class Ticket < ActiveModel::Model
  include ActiveModel::Validation

  attribute event_name : String
  attribute ticket_holder_name : String
  attribute location : NamedTuple(lat: Float64, lon: Float64, name: String?, address: String?)
  attribute date_time : NamedTuple(start: String, end: String)
  attribute logo : NamedTuple(image_uri: String?, description: String?)?
  attribute icon : NamedTuple(image_uri: String?)?
  attribute event_details : NamedTuple(header: String?, body: String?)?
  attribute qr_code : NamedTuple(value: String, alt_text: String?)

  validates :event_name, presence: true
  validates :ticket_holder_name, presence: true
  validates :location, presence: true
  validates :date_time, presence: true
  validates :qr_code, presence: true

  def generate
    serial_number = UUID.random.to_s

    google_channel = Channel(PassResponse).new
    apple_channel = Channel(PassResponse).new

    spawn do
      pass_response = begin
        pass_url = to_google(serial_number: serial_number).execute

        PassResponse.new(success: true, data: pass_url)
      rescue ex
        PassResponse.new(success: false, data: "Failed to generate google pass url. Error: #{ex.message}")
      end
      google_channel.send(pass_response)
    end

    spawn do
      pass_response = begin
        pass_content = to_passkit(serial_number: serial_number).to_s
        S3.uploader.upload(App::AWS_BUCKET, "#{serial_number}.pkpass", IO::Memory.new(pass_content))
        PassResponse.new(success: true, data: "#{base_url}/#{serial_number}.pkpass")
      rescue ex
        PassResponse.new(success: false, data: "Failed to generate apple pass url. Error: #{ex.message}")
      end
      apple_channel.send(pass_response)
    end

    google_pass = google_channel.receive
    apple_pass = apple_channel.receive

    return google_pass unless google_pass.success
    return apple_pass unless apple_pass.success

    PassResponse.new(success: true, data: "", api_data: {
      apple_pass_url:  apple_pass.data,
      google_pass_url: google_pass.data,
    })
  end

  def to_passkit(serial_number : String)
    PasskitPass.new(ticket: self,
      serial_number: serial_number).convert
  end

  def to_google(serial_number : String)
    GoogleTicket.new(ticket: self,
      serial_number: serial_number).convert
  end

  def base_url
    if App.production?
      "https://#{App::DEFAULT_HOST}"
    else
      "http://#{App::DEFAULT_HOST}:#{App::DEFAULT_PORT}"
    end
  end

  struct PassResponse
    property success : Bool
    property data : String
    property api_data : NamedTuple(apple_pass_url: String, google_pass_url: String)?

    def initialize(@success, @data, @api_data = nil)
    end
  end
end
