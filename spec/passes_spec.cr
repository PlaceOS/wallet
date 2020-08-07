require "./spec_helper"

describe Passes do
  with_server do
    it "should give 401 when not providing proper api header" do
      result = curl("POST", "/")
      result.status.should eq(HTTP::Status::UNAUTHORIZED)
    end

    it "should not give 401 when providing proper api header" do
      result = curl("POST", "/", {"x-api-key" => "SECURE_KEY"})
      result.status.should_not eq(HTTP::Status::UNAUTHORIZED)
    end
  end
end
