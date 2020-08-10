require "spec"
require "webmock"
require "json"


# Your application config
# If you have a testing environment, replace this with a test config file
require "../src/config"

# Helper methods for testing controllers (curl, with_server, context)
require "../lib/action-controller/spec/curl_context"

Spec.before_each &->WebMock.reset
