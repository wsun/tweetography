require 'csv'
require 'random'

class InputController < ApplicationController
  def home
  end

  def visualize

    # prevent indirect means of arriving here
    unless params[:keyword].present? or params[:city].present? or
           params[:radius].present? or not params[:keyword].empty?
      respond_to do |format|
        format.html { redirect_to root_path, 
                      alert: 'Please enter search keyword.' }
      end
      return
    end

    keyword = params[:keyword]
    loc = false
    geo = ''

    # geocode the city parameter, using default 100 mi radius if none provided
    unless params[:city].empty?
      center = Geocoder.search(params[:city]).first
      unless center.nil?
        loc = true
        unless params[:radius].empty? or params[:radius].to_i < 0
          rad = params[:radius].to_i
          geo = "#{center.latitude.to_s}, #{center.longitude.to_s}, #{rad.to_s}mi"
        else
          geo = "#{center.latitude.to_s}, #{center.longitude.to_s}, 100mi"
        end
      end
    end


    # OAuth
    Twitter.configure do |config|
      config.consumer_key = 'W3mRvrBAYvTV1840W7w6w'
      config.consumer_secret = 'QzmwtlyCfffIiEio9TK6WJfK2RuxL0vn3UBvugs9Eo'
      config.oauth_token = '318868789-Eho05NqG1ZCEajYk7d9gU61xqk9AVbZAQqZKlwqI'
      config.oauth_token_secret = 'Ofa4sOJil0e26kcPxu6dAu7WcU1I7GrdLLiqpCpa0g'
      config.search_endpoint = 'http://twitter-search-api-tweetography.apigee.com'
      config.endpoint = 'http://twitter-api-tweetography.apigee.com'
    end
    
    # make the query
    results = []
    1.upto(15) do |i|
      q = []
      if loc
        q.concat(Twitter.search(keyword, geocode: geo, 
                                         lang: 'en', rpp: 3, page: i))
      else
        q.concat(Twitter.search(keyword, lang: 'en', rpp: 3, page: i))
      end
      if q.empty?
        break
      end
      results.concat(q)
    end

    # if no results, redirect
    if results.empty?
      respond_to do |format|
        format.html { redirect_to root_path, 
                      alert: 'Please retry, no results were found.' }
      end
      return
    end


    final = []
    # data labels
    labels = ['time', 'user', 'user_id', 'name', 'text', 'loc', 'time_zone',
              'statuses_count', 'followers_count', 'friends_count', 'source',
              'lat', 'lon', 'mood']
    final.push(labels)

    # query for mood of tweets
    # prepare request
    moods = []
    x = []
    results.each do |r|
      x.push({text: r.text})
    end
    request = {data: x}
    url = 'http://twittersentiment.appspot.com/api/bulkClassifyJson'
    
    # make request and build the mood array
    y = HTTParty.post(url, :body => request.to_json)
    y.parsed_response["data"].each do |tweet|
      moods.push(tweet["polarity"])
    end

    # prepare info
    total = results.count
    0.upto(total - 1) do |i|
      result = results[i]

      user = Twitter.user(result.from_user_id)

      # determine tweet location, if none, kick it out
      loc = result.geo
      lat = ''
      lon = ''
      if loc.nil?
        attempt = Geocoder.search(user.location).first
        if attempt.nil?
          next
        else
          lat = attempt.latitude
          lon = attempt.longitude
        end
      else
        lat = loc.latitude
        lon = loc.longitude
      end

      current = []
      current.push(result.created_at)
      current.push(result.from_user)
      current.push(result.from_user_id)
      current.push(result.from_user_name)
      current.push(result.text)

      current.push(user.location)
      current.push(user.time_zone)
      current.push(user.statuses_count)
      current.push(user.followers_count)
      current.push(user.friends_count)

      # extract out the name of the source of the tweet
      source = /&gt;(.*)&lt;/.match(result.source)[1]
      source = source.gsub(/[^0-9A-Za-z]/, '')
      current.push(source)

      current.push(lat)
      current.push(lon)
      current.push(moods[i])

      final.push(current)
    end

    # write CSV file to the public directory
    directory = 'public/'

    prng = Random.new

    @unique = prng.rand(1..(2**32))
    name = @unique.to_s
    path = File.join( directory, name )
    CSV.open(path + '.csv', 'wb') do |csv|
      final.each do |row|
        csv << row
      end
    end

    # generate visualization
    respond_to do |format|
      format.html # visualize.html.erb
    end
  end
end
