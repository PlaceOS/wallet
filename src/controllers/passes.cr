require "../models/google_drive"

class Passes < Application
  base "/"

  def create
    ticket = Ticket.from_json(request.body.not_nil!)

    if ticket.valid?
      render json: ticket.generate.to_json
    else
      render(status: HTTP::Status::UNPROCESSABLE_ENTITY,
        json: {errors: ticket.errors.map { |error| {error.field => error.message} }}.to_json)
    end
  end

  def show
    response.content_type = "application/vnd.apple.pkpass"
    response.print(drive.download_file(params["id"]))
  end

  private def drive
    GoogleDrive.build
  end
end
