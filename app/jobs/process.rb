class ProcessJob
	include Resque::Plugins::Status

	# pass in options['keyword', 'loc', 'geo']
  # via ProcessJob.create(keyword: 'harvard', loc: 'true', 
  #                       geo: '40.5,32.76,100mi')
	def perform

    at(0, 100, 'making Twitter query.')

    # make the query
    results = []
    max = nil
    1.upto(15) do |i|
      if options['loc'] == "true"
        attempts = 0
        q = begin
          if max.nil?
            Twitter.search(options['keyword'], geocode: options['geo'], 
                            lang: 'en', count: 100).statuses
          else
            Twitter.search(options['keyword'], geocode: options['geo'], 
                            lang: 'en', count: 100, max_id: max).statuses
          end
        rescue Twitter::Error::ClientError
          attempts += 1
          retry unless attempts > 3
          []
        end
      else
        attempts = 0
        q = begin
          if max.nil?
            Twitter.search(options['keyword'], lang: 'en', count: 100).statuses
          else
            Twitter.search(options['keyword'], lang: 'en', count: 100, 
                            max_id: max).statuses
          end
        rescue Twitter::Error::ClientError
          attempts += 1
          retry unless attempts > 3
          []
        end
      end
      results.concat(q)

      # handle max for pagination
      if q[-1].nil?
        failed('no results were found.')
        return
      else
        max = q[-1].id - 1
      end
    end

    # if no results, return message
    if results.empty?
      failed('no results were found.')
      return
    end

    # update
    total = results.count
    at(total/10, total + total/10 + total/30, 'analyzing mood of tweets.')

    # query for mood of tweets
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

    # update
    at(total/10 + total/30, total + total/10 + total/30, 'collecting Twitter user info.')

    # prepare info, use jobid to mark query
    unique = uuid
    
    # loop through results
    0.upto(total - 1) do |i|
      result = results[i]

      lat = nil
      lon = nil
      tweet_loc = result.geo

      # use user geo coordinates if possible
      unless tweet_loc.nil?
        lat = tweet_loc.latitude
        lon = tweet_loc.longitude
      else # look for location in db, create as appropriate
        if result.user.location.nil?
          next
        end
        sanitized = result.user.location.gsub(/[^0-9A-Za-z]/, '')
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
      t = Search.create :tweeted => result.created_at,
                        :user => result.user.screen_name,
                        :userid => result.user.id,
                        :name => result.user.name,
                        :text => result.text,
                        :loc => result.user.location,
                        :timezone => result.user.time_zone,
                        :statuses => result.user.statuses_count,
                        :followers => result.user.followers_count,
                        :friends => result.user.friends_count,
                        :source => source,
                        :lat => lat,
                        :lon => lon,
                        :mood => moods[i],
                        :query => unique

      # update
      curr = i + 1
      at(total/10 + total/30 + curr, total + total/10 + total/30, 
        "processed #{curr} of #{total} tweets.")
    end

    # finish
    completed()
	end
end