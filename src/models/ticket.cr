require "uuid"
require "google"

require "../adapters/google_ticket"
require "../adapters/passkit"
require "./google_drive"

class Ticket < ActiveModel::Model
  attribute event_name : String
  attribute ticket_holder_name : String
  attribute location : NamedTuple(lat: Float64, lon: Float64, name: String?, address: String?)
  attribute date_time : NamedTuple(start: String, end: String)
  attribute logo : NamedTuple(image_uri: String?, description: String?)?
  attribute icon : NamedTuple(image_uri: String?)?
  attribute event_details : NamedTuple(header: String?, body: String?)?
  attribute qr_code : NamedTuple(value: String, alt_text: String?)

  def generate
    serial_number = UUID.random.to_s

    google_channel = Channel(String).new
    apple_channel = Channel(String).new

    spawn do
      pass_url = to_google(serial_number: serial_number).execute
      google_channel.send(pass_url)
    end

    spawn do
      pass_content = to_passkit(serial_number: serial_number).to_s
      pass_file = drive.create(name: "#{serial_number}.pkpass",
                               content_bytes: pass_content,
                               content_type: "application/vnd.apple.pkpass")
      apple_channel.send(pass_file.id.to_s)
    end

    # TODO: Need to figure out the apple URL base
    {
      apple_pass_url: "127.0.0.1:3000/#{apple_channel.receive}",
      google_pass_url: google_channel.receive
    }
  end

  def to_passkit(serial_number : String)
    Passkit.new(ticket: self,
      serial_number: serial_number).convert
  end

  def to_google(serial_number : String)
    GoogleTicket.new(ticket: self,
      serial_number: serial_number).convert
  end

  private def drive
    GoogleDrive.build
  end
end