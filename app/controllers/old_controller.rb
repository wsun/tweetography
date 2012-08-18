require 'csv'

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
    loc = false                 # flag for location
    geo = ''                    # geo string for query

    #####################
    start_time = Time.now
    #####################

    # geocode the city parameter, using default 100 mi radius if none provided
    unless params[:city].empty?
      center = Geocoder.search(params[:city]).first
      unless center.nil?
        loc = true
        unless params[:radius].empty? or params[:radius].to_i < 0
          rad = params[:radius].to_i
          geo = "#{center.latitude.to_s},#{center.longitude.to_s},#{rad.to_s}mi"
        else
          geo = "#{center.latitude.to_s},#{center.longitude.to_s},100mi"
        end
      end
    end

    #####################
    g_time = Time.now - start_time
    #####################

    # OAuth
    Twitter.configure do |config|
      config.consumer_key = 'W3mRvrBAYvTV1840W7w6w'
      config.consumer_secret = 'QzmwtlyCfffIiEio9TK6WJfK2RuxL0vn3UBvugs9Eo'
      config.oauth_token = '318868789-Eho05NqG1ZCEajYk7d9gU61xqk9AVbZAQqZKlwqI'
      config.oauth_token_secret = 'Ofa4sOJil0e26kcPxu6dAu7WcU1I7GrdLLiqpCpa0g'
    #config.search_endpoint = 'http://twitter-search-api-tweetography.apigee.com'
    #config.endpoint = 'http://twitter-api-tweetography.apigee.com'
    end

    #####################
    c_time = Time.now - start_time - g_time
    #####################

    #TEST
    p Twitter.rate_limit_status

    # make the query
    results = []
    1.upto(15) do |i|
      q = []
      if loc
        q.concat(Twitter.search(keyword, geocode: geo, 
                                         lang: 'en', rpp: 100, page: i))
      else
        q.concat(Twitter.search(keyword, lang: 'en', rpp: 100, page: i))
      end
      if q.empty?
        break
      end
      results.concat(q)
    end

    #####################
    q_time = Time.now - start_time - g_time - c_time
    #####################


    # if no results, redirect
    if results.empty?
      respond_to do |format|
        format.html { redirect_to root_path, 
                      alert: 'Please retry, no results were found.' }
      end
      return
    end

=begin
    final = []
    # data labels
    labels = ['time', 'user', 'user_id', 'name', 'text', 'loc', 'time_zone',
              'statuses_count', 'followers_count', 'friends_count', 'source',
              'lat', 'lon', 'mood']
    final.push(labels)
=end

    # prepare user info
    users = Hash.new

    # query for mood of tweets
    # prepare request
    moods = []
    x = []
    results.each do |r|
      x.push({text: r.text})

      # save user ids as we loop through
      users.store(r.from_user_id, 0)
    end
    request = {data: x}
    url = 'http://twittersentiment.appspot.com/api/bulkClassifyJson'
    
    # make request and build the mood array
    y = HTTParty.post(url, :body => request.to_json)
    y.parsed_response["data"].each do |tweet|
      moods.push(tweet["polarity"])
    end

    #####################
    m_time = Time.now - start_time - g_time - c_time - q_time
    #####################

    # make user requests in batches of 100 and fill hash
    user_ids = users.keys
    user_count = user_ids.count
    start = 0
    while user_count > 0
      if user_count > 100
        response = Twitter.users(*user_ids[start, 100])
        user_count -= 100
        start += 100
      else
        response = Twitter.users(*user_ids[start, user_count])
        user_count = 0
      end
      response.each do |r|
        users[r.id] = r
      end
    end

    # prepare info, use random integer to mark query
    total = results.count
    @unique = Random.new.rand(-2**31..(2**31 - 1))

    # loop through results
    0.upto(total - 1) do |i|
      result = results[i]
      user = users[result.from_user_id]

      lat = nil
      lon = nil
      tweet_loc = result.geo

      # use user geo coordinates if possible
      unless tweet_loc.nil?
        lat = tweet_loc.latitude
        lon = tweet_loc.longitude
      else # look for location in db, create as appropriate
        if user.location.nil?
          next
        end
        sanitized = user.location.gsub(/[^0-9A-Za-z]/, '')
        #sanitized = ActiveRecord::Base.connection.quote(user.location)
        search_query = Location.search(sanitized)
        if search_query.empty? # new query
          new_loc = Location.new(:address => sanitized)
          if new_loc.save
            lat = new_loc.latitude
            lon = new_loc.longitude
          else
            next
          end
        else # already in db
          lat = search_query.first.latitude
          lon = search_query.first.longitude
        end
      end

      # error check, if no coordinates, kill
      if lat.nil? or lon.nil?
        next
      end

      # extract out the name of the source of the tweet
      source = /&gt;(.*)&lt;/.match(result.source)
      unless source.nil?
        source = source[1].gsub(/[^0-9A-Za-z]/, '')
      end

      # construct tweet db entry
      t = Search.create :created => result.created_at,
                        :user => result.from_user,
                        :userid => result.from_user_id,
                        :name => result.from_user_name,
                        :text => result.text,
                        :loc => user.location,
                        :timezone => user.time_zone,
                        :statuses => user.statuses_count,
                        :followers => user.followers_count,
                        :friends => user.friends_count,
                        :source => source,
                        :lat => lat,
                        :lon => lon,
                        :mood => moods[i],
                        :query => @unique
    end
  
    #####################
    p_time = Time.now - start_time - g_time - c_time - q_time - m_time
    #####################


=begin
    # prepare info
    total = results.count
    0.upto(total - 1) do |i|
      result = results[i]

      user = users[result.from_user_id]

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
      source = /&gt;(.*)&lt;/.match(result.source)
      unless source.nil?
        source = source[1].gsub(/[^0-9A-Za-z]/, '')
        current.push(source)
      end

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
=end

    #####################
    w_time = Time.now - start_time - g_time - c_time - q_time - m_time - p_time
    #####################

    # TIMERS
    @geo = g_time
    @config = c_time
    @query = q_time
    @mood = m_time
    @process = p_time
    @write = w_time

    # DEBUG
    @locations = Location.all
    @searches = Search.all

    # generate visualization
    respond_to do |format|
      format.html # visualize.html.erb
    end
  end


  def sample
    @unique = 'sample'
  end

  def about
  end
end
