module Tweetography
  class Application < Rails::Application
    config.to_prepare do
      # Apigee
      '''
      if ENV['APIGEE_TWITTER_API_ENDPOINT']
        @@twitter_api = ENV['APIGEE_TWITTER_API_ENDPOINT']
   	  else
        # Get this value from Heroku.
        # Once you have enabled the addon, boot up the 'heroku console' and run the following:
        # puts ENV['APIGEE_TWITTER_API_ENDPOINT']
        # this will spit out your correct api endpoint

        @@twitter_api = "twitter-api-tweetography.apigee.com"
      end

	  # build the endpoint based on the add-on supplied configvar
	  @endpoint = 'http://' + @@twitter_api
	  '''

      # OAuth
      Twitter.configure do |config|
      	config.consumer_key = 'W3mRvrBAYvTV1840W7w6w'
      	config.consumer_secret = 'QzmwtlyCfffIiEio9TK6WJfK2RuxL0vn3UBvugs9Eo'
      	config.oauth_token = '318868789-Eho05NqG1ZCEajYk7d9gU61xqk9AVbZAQqZKlwqI'
      	config.oauth_token_secret = 'Ofa4sOJil0e26kcPxu6dAu7WcU1I7GrdLLiqpCpa0g'
      	config.default_search_endpoint = 'http://twitter-search-api-tweetography.apigee.com'
      	config.default_endpoint = 'http://twitter-api-tweetography.apigee.com'
      end
    end
  end
end