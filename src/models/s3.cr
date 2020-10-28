require "awscr-s3"

module S3
  extend self

  def client
    Awscr::S3::Client.new(ENV["AWS_REGION"], ENV["AWS_KEY"], ENV["AWS_SECRET"])
  end

  def uploader
    Awscr::S3::FileUploader.new(self.client)
  end
end
