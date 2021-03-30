require "webmock"
require "json"

# Your application config
# If you have a testing environment, replace this with a test config file
require "../src/config"

# Helper methods for testing controllers (curl, with_server, context)
require "../lib/action-controller/spec/curl_context"

require "spec"

Spec.before_each &->WebMock.reset

module ApiHelper
  extend self

  def file_response
    {
      "id"          => "123",
      "name"        => "test.txt",
      "webViewLink" => "https://docs.google.com/spreadsheets/d/123/edit?usp=drivesdk",
    }
  end

  def mock_create
    WebMock.stub(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(body: {access_token: "test_token", expires_in: 3599, token_type: "Bearer"}.to_json)
    WebMock.stub(:post, "https://walletobjects.googleapis.com/walletobjects/v1/eventTicketClass")
      .to_return(body: {"test" => true}.to_json)
    WebMock.stub(:post, "https://walletobjects.googleapis.com/walletobjects/v1/eventTicketObject")
      .to_return(body: {"test" => true}.to_json)
    WebMock.stub(:get, "https://example.com/logo.png")
    WebMock.stub(:get, "https://example.com/icon.png")
    WebMock.stub(:post, "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")
      .to_return(body: file_response.to_json)
    WebMock.stub(:put, Regex.new("(https://s3.amazonaws.com/bucket/)*(.pkpass?)"))
      .to_return(body: file_response.to_json, headers: {"ETag" => "etag"})
  end

  def event_payload
    {
      "event_name":         "My event",
      "ticket_holder_name": "John Smith",
      "location":           {"lat": 37.424299996, "lon": -122.0925956000001, "name": "Sydney International Convention Centre", "address": "ICC Sydney"},
      "date_time":          {"start": "2023-04-12T11:20:50.52Z", "end": "2023-04-12T16:20:50.52Z"},
      "logo":               {"image_uri": "https://example.com/logo.png", "description": "Logo Desc"},
      "icon":               {"image_uri": "https://example.com/icon.png"},
      "qr_code":            {
        "value":    "http://example.com/best_url",
        "alt_text": "1234567890",
      },
      "event_details": {"header": "My header", "body": "BODY of the event"},
    }.to_json
  end
end
