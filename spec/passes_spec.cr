require "./spec_helper"

describe Passes do
  with_server do
    it "should give 401 when not providing proper api header" do
      WebMock.allow_net_connect = true
      result = curl("POST", "/")
      result.status.should eq(HTTP::Status::UNAUTHORIZED)
    end

    it "should not give 401 when providing proper api header" do
      WebMock.allow_net_connect = true
      result = curl("POST", "/", {"x-api-key" => "SECURE_KEY"})
      result.status.should_not eq(HTTP::Status::UNAUTHORIZED)
    end

    it "should give validation errors when providing proper api header but incomplete payload" do
      WebMock.allow_net_connect = true
      result = curl("POST", "/", {"x-api-key" => "SECURE_KEY"}, {"test" => 123}.to_json)
      result.status.should eq(HTTP::Status::UNPROCESSABLE_ENTITY)
      result.body.includes?("errors").should be_truthy
    end
  end
end
