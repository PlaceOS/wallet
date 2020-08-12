require "../models/auth"
require "google"

class GoogleTicket
  property auth : Google::FileAuth

  def initialize(@ticket : Ticket, @serial_number : String)
    @auth = Auth.new(scopes: "https://www.googleapis.com/auth/wallet_object.issuer").call
  end

  def convert
    Google::EventTickets.new(auth: @auth,
      serial_number: @serial_number,
      issuer_id: ENV["GOOGLE_WALLET_ISSUER_ID"],
      issuer_name: ENV["GOOGLE_WALLET_ISSUER_NAME"],
      event_name: @ticket.event_name.to_s,
      ticket_holder_name: @ticket.ticket_holder_name.to_s,
      qr_code_value: qr_code_value,
      qr_code_alternate_text: qr_code_alt_text,
      location: location,
      date_time: @ticket.date_time,
      venue: venue,
      logo_image: logo_image,
      event_image: event_image,
      event_details: @ticket.event_details
    )
  end

  private def qr_code_value
    @ticket.qr_code.not_nil!["value"]
  end

  private def qr_code_alt_text
    return nil if @ticket.qr_code.nil?

    @ticket.qr_code.not_nil!["alt_text"]?
  end

  private def location
    {lat: @ticket.location.not_nil!["lat"], lon: @ticket.location.not_nil!["lon"]}
  end

  private def venue
    {name: @ticket.location.not_nil!["name"]?, address: @ticket.location.not_nil!["address"]?}
  end

  private def logo_image
    return default_logo_image if @ticket.logo.nil?

    {uri: @ticket.logo.not_nil!["image_uri"], description: @ticket.logo.not_nil!["description"]}
  end

  private def event_image
    return if @ticket.icon.nil?

    {uri: @ticket.icon.not_nil!["image_uri"]?, description: nil}
  end

  private def default_logo_image
    {uri: ENV["GOOGLE_LOGO_IMAGE_URL"]?, description: ENV["GOOGLE_LOGO_DESCRIPTION"]?}
  end
end
