class InputController < ApplicationController
  def home
  end

  def visualize
    keyword = params[:keyword]
    loc = false
    geo = ''

    unless params[:keyword].present?
      respond_to do |format|
        format.html { redirect_to root_path, 
                      alert: 'Please enter search keyword.' }
      end
    end

    # OAuth
    Twitter.configure do |config|
      config.consumer_key = 'W3mRvrBAYvTV1840W7w6w'
      config.consumer_secret = 'QzmwtlyCfffIiEio9TK6WJfK2RuxL0vn3UBvugs9Eo'
      config.oauth_token = '318868789-Eho05NqG1ZCEajYk7d9gU61xqk9AVbZAQqZKlwqI'
      config.oauth_token_secret = 'Ofa4sOJil0e26kcPxu6dAu7WcU1I7GrdLLiqpCpa0g'
    end


    # geocode the city parameter
    if params[:city].present?
      center = Geocoder.search(params[:city]).first
      unless center.nil?
        loc = true
        if params[:radius].present?
          geo = "#{center.latitude.to_s}, #{center.longitude.to_s}, #{params[:radius].to_s}mi"
        else
          geo = "#{center.latitude.to_s}, #{center.longitude.to_s}, 100mi"
        end
      end
    end
    
    # make the query
    results = []
    1.upto(15) do |i|
      q = []
      if loc
        q.concat(Twitter.search(keyword, geocode: geo, rpp: 5, page: i))
      else
        q.concat(Twitter.search(keyword, rpp: 5, page: i))
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

      user = Twitter.user(result.from_user_id)

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

      current.push(/&gt;(.*)&lt;/.match(result.source)[1])

      current.push(lat)
      current.push(lon)
      current.push(moods[i])

      final.push(current)
    end

    # write CSV file
    directory = 'public/'
    @unique = rand(1..2**32)
    name = @unique.to_s
    path = File.join( directory, name )
    CSV.open('path' + '.csv', 'wb') do |csv|
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
