require 'net/http'
require 'faraday/net_http'

# Make sure Faraday uses Net::HTTP before Octokit builds its middleware stack.
Faraday.default_adapter = :net_http

require 'octokit'
require 'openssl'

Octokit.configure do |config|
  config.middleware = Faraday::RackBuilder.new do |builder|
    if defined?(Faraday::Request::Retry)
      builder.use Faraday::Request::Retry, exceptions: [Octokit::ServerError]
    elsif defined?(Faraday::Retry::Middleware)
      builder.use Faraday::Retry::Middleware, exceptions: [Octokit::ServerError]
    end

    builder.use Octokit::Middleware::FollowRedirects
    builder.use Octokit::Response::RaiseError
    builder.use Octokit::Response::FeedParser
    builder.adapter :net_http
  end

  config.ssl_verify_mode = OpenSSL::SSL::VERIFY_NONE
end
