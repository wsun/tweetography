## Overview
This app is a combination of Ruby on Rails and Processing. It currently lives at: http://tweetography.herokuapp.com

## Local Setup
Ruby 1.9.3p125 / Rails 3.2.3

1. install necessary packages (gcc, git, etc)
2. install ruby version manager (rvm)
3. install the latest version of ruby with rvm
4. install rails
5. within the project directory, run `bundle install` to install any necessary gems
6. set up environment variables: `RESQUE_USER`, `RESQUE_PASS`, `TWITTER_CONSUMER_KEY`, `TWITTER_CONSUMER_SECRET`, `TWITTER_OAUTH_TOKEN`, `TWITTER_OAUTH_TOKEN_SECRET`, `REDISTOGO_URL`
7. run `rails s` to fire up an instance of the server
8. navigate to http://localhost:3000

Processing (visualization only)

1. extract the 4 library files in the `libraries.zip` folder to
/Username/Documents/Processing/libraries or c:/My Documents/Processing (on PC, you might need to make a new folder)
2. load finalProject.pde 
3. run

## Structure
Overall, the app hinges on two primary capabilities:

1. data collection through Ruby and APIs
2. visualization through Processing

The Ruby/Rails app is fairly simple. A basic search form allows users to search for tweets by keyword and near a location. The work is pushed off to a Resque worker. A series of steps takes place:

1. Location input is converted to lat/lon for Twitter API call via Ruby Geocoder
2. Twitter search API returns a list of tweet objects
3. Tweets can be geocoded and come with lat/lon, but the large majority of them do not; we then try to use user-reported location to query via Ruby Geocoder to ascertain location coordinates. If no location can be found, the tweet is thrown out.
4. Mood of the user is analyzed through calls to the Twitter Sentiment API, which measures tweets on a 0,2,4 scale from sad to happy. 
5. Additional information, like tweet source, number of followers of a user, etc are also collected
6. Results are stored in a database, which can then be queried by the visualization.