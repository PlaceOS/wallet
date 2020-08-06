require "passkit"

class Passkit
  def initialize(@ticket : Ticket, @serial_number : String)
  end

  def convert
    pass = PassKit::Pass.new(
      pass_type_identifier: ENV["APPLE_PASS_TYPE_IDENTIFIER"],
      team_identifier: ENV["APPLE_TEAM_IDENTIFIER"],
      serial_number: @serial_number,
      organization_name: ENV["APPLE_ORGANIZATION_NAME"],
      description: @ticket.event_name.to_s,
      logo_text: logo_text,
      type: PassKit::PassType::EventTicket,
      foreground_color: "rgb(255, 255, 255)",
      background_color: "rgb(66, 80, 112)",
      label_color: "rgb(255, 255, 255)",
      header_fields: header_fields,
      primary_fields: [{
        key:   "eventLocation",
        label: "LOCATION",
        value: location_name,
      }],
      relevant_date: relevant_date,
      locations: locations,
      barcodes: barcodes
    )
    pk_pass = PassKit::PKPass.new(pass)
    add_icon_image(pk_pass)
    add_logo_image(pk_pass)
  end

  # TODO: Secondary Date Time Fields
  # TODO: Logo
  # TODO: Ticket Holder Name

  # TODO: Need to verify date time format
  private def relevant_date
    @ticket.date_time.not_nil!["start"]
  end

  private def header_fields
    return if @ticket.event_details.nil?

    [{key: @ticket.event_details.not_nil!["header"].to_s, value: @ticket.event_details.not_nil!["body"].to_s}]
  end

  private def logo_text
    return ENV["APPLE_LOGO_DESCRIPTION"] if @ticket.logo.nil?

    @ticket.logo.not_nil!["description"]
  end

  private def location_name
    @ticket.location.not_nil!["name"].to_s
  end

  private def barcodes
    [PassKit::Barcode.new(format: PassKit::BarcodeFormat::PKBarcodeFormatQR,
      message: qr_code_value,
      message_encoding: "iso-8859-1",
      alt_text: qr_code_alt_text)]
  end

  private def qr_code_value
    @ticket.qr_code.not_nil!["value"]
  end

  private def qr_code_alt_text
    return nil if @ticket.qr_code.nil?

    @ticket.qr_code.not_nil!["alt_text"]?
  end

  private def add_logo_image(pk_pass)
    if @ticket.logo.nil?
      pk_pass.add_file("logo.png", File.read(ENV["APPLE_LOGO_PATH"]))
    else
      pk_pass.add_url(@ticket.logo.not_nil!["image_uri"].to_s)
    end
    pk_pass
  end

  private def add_icon_image(pk_pass)
    if @ticket.icon.nil?
      pk_pass.add_file("icon.png", File.read(ENV["APPLE_ICON_PATH"]))
    else
      pk_pass.add_url(@ticket.icon.not_nil!["image_uri"].to_s)
    end
    pk_pass
  end

  private def locations
    [
      {latitude: @ticket.location.not_nil!["lat"], longitude: @ticket.location.not_nil!["lon"]},
    ]
  end
end
