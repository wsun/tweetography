# retrieve endpoint from Heroku env vars if possible
=begin
if ENV['APIGEE_TWITTER_API_ENDPOINT']
  twitter_api = ENV['APIGEE_TWITTER_API_ENDPOINT']
else
  twitter_api = 'twitter-api-app4154261.apigee.com'
end
endpoint = 'http://' + twitter_api
=end

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end