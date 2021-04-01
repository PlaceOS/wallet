require "../adapters/s3.cr"

class Passes < Application
  before_action :require_authentication, only: :create

  base "/"

  def create
    ticket = Ticket.from_json(request.body.not_nil!)

    errors = [{} of String => String]
    if ticket.valid?
      generated = ticket.generate
      if generated.success
        render json: generated.api_data.to_json
      else
        errors = [{error: generated.data}]
      end
    else
      errors = ticket.errors.map { |error| {error.field => error.message} }
    end
    render(status: HTTP::Status::UNPROCESSABLE_ENTITY, json: {errors: errors}.to_json)
  end

  def show
    response.content_type = "application/vnd.apple.pkpass"
    response.print(S3.client.get_object(App::AWS_BUCKET, params["id"]))
  end
end
