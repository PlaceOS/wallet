require "awscr-s3"

module S3
  extend self

  def client
    Awscr::S3::Client.new(App::AWS_REGION, App::AWS_KEY, App::AWS_SECRET)
  end

  def uploader
    Awscr::S3::FileUploader.new(self.client)
  end
end
