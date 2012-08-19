class ProcessJob
	include Resque::Plugins::Status

	# pass in options['keyword', 'loc', 'geo']
  # via ProcessJob.create(keyword: 'harvard', loc: 'boston', geo: '100')
	def perform
  	
    # OAuth config
    Twitter.configure do |config|
      config.consumer_key = 'W3mRvrBAYvTV1840W7w6w'
      config.consumer_secret = 'QzmwtlyCfffIiEio9TK6WJfK2RuxL0vn3UBvugs9Eo'
      config.oauth_token = '318868789-Eho05NqG1ZCEajYk7d9gU61xqk9AVbZAQqZKlwqI'
      config.oauth_token_secret = 'Ofa4sOJil0e26kcPxu6dAu7WcU1I7GrdLLiqpCpa0g'
      #config.search_endpoint = 'http://twitter-search-api-tweetography.apigee.com'
      #config.endpoint = 'http://twitter-api-tweetography.apigee.com'
    end

    # make the query
    results = []
    1.upto(15) do |i|
      q = []
      if options['loc']
        q.concat(Twitter.search(options['keyword'], geocode: options['geo'], 
                                lang: 'en', rpp: 100, page: i))
      else
        q.concat(Twitter.search(options['keyword'], lang: 'en', rpp: 100, 
                                page: i))
      end
      if q.empty?
        break
      end
      results.concat(q)
    end

    # if no results, return message
    if results.empty?
      failed()
      return
    end

    # update
    total = results.count
    at(total/10, total + total/10 + total/30, "Finished Twitter query")

    # prepare user info
    users = Hash.new

    # query for mood of tweets
    moods = []
    x = []
    results.each do |r|
      x.push({text: r.text})

      # save user ids as we loop through in this prep phase
      users.store(r.from_user_id, 0)
    end
    request = {data: x}
    url = 'http://twittersentiment.appspot.com/api/bulkClassifyJson'
    
    # make request and build the mood array
    y = HTTParty.post(url, :body => request.to_json)
    y.parsed_response["data"].each do |tweet|
      moods.push(tweet["polarity"])
    end

    # update
    at(total/10 + total/30, total + total/10 + total/30, "Finished mood query")

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

    # prepare info, use jobid to mark query
    unique = uuid
    
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
                        :query => unique

      # update
      curr = i + 1
      at(total/10 + total/30 + curr, total + total/10 + total/30, 
          "Processed #{curr} of #{total} tweets")
    end

    # finish
    completed()
	end
end