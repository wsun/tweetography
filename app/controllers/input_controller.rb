class InputController < ApplicationController
  def home
  end

  def run
    # prevent indirect means of arriving here
    unless params.has_key?(:keyword) or params.has_key?(:city) or 
                                        params.has_key?(:radius)
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Please make a query.'}
      end
      return
    end

    # prevent lack of keyword
    if params[:keyword].empty?
      respond_to do |format|
        format.html { redirect_to root_path, 
                      alert: 'Please enter search keyword.' }
      end
      return
    end

    # provide values to fill the fake form for input#run
    @k = params[:keyword]
    @c = params[:city]
    @r = params[:radius]

    @city = @c

    keyword = params[:keyword]
    loc = false                 # flag for location
    geo = ''                    # geo string for query

    # error-check only if location query is made
    unless params[:city].empty?
      center = Geocoder.search(params[:city]).first
    
      # prevent bad locations
      if center.nil?
        respond_to do |format|
          format.html { redirect_to root_path, 
                        alert: 'Unable to find city.' }
        end
        return
      end

      # prevent malformed radius if location is given
      test = Integer(params[:radius]) rescue nil
      if test.nil? or test <= 0
        respond_to do |format|
          format.html { redirect_to root_path,
                        alert: 'Please enter a positive 
                        integer value for radius.' }
        end
        return
      end

      # construct the geocode query string
      loc = true
      rad = test
      @radius = rad
      geo = "#{center.latitude.to_s},#{center.longitude.to_s},#{rad.to_s}mi"
    end

    # call the job
    if loc
      final_loc = "true"
    else
      final_loc = ""
    end
    @jid = ProcessJob.create(keyword: keyword, loc: final_loc, geo: geo)

    # render the modal and fake page
    respond_to do |format|
      format.html # run.html.erb
    end
  end

  def status
    @status = Resque::Plugins::Status::Hash.get(params[:jid])
  end

  def kill
    @jid = params[:jid]
    Resque::Plugins::Status::Hash.kill(@jid)

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def info
    @jid = params[:jid]

    respond_to do |format|
      format.html # info.html.erb
    end
  end

  def visualize
    # DEBUG
    @jid = params[:jid]
    @k = params[:keyword]
    #@locations = Location.all
    #@searches = Search.where("query = ?", params[:jid])

    # generate visualization
    respond_to do |format|
      format.html # visualize.html.erb
    end
  end

  def sample
  end

  def about
  end

=begin
  def export
    searches = Search.where("query = ?", params[:jid]).order("tweeted DESC")

    # write CSV file to the public directory
    directory = 'public/'
    name = params[:jid]
    path = File.join( directory, name )

    CSV.open(path + '.csv', 'wb') do |csv|
      searches.each do |search|
        csv << [search.lat, search.lon, search.text, search.tweeted,
                search.statuses, search.followers, search.friends,
                search.mood]
      end
    end
  end
=end
end
