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

    # prevent malformed radius if location is given
    unless params[:city].empty?
      test = Integer(params[:radius]) rescue nil
      if test.nil? or test < 0
        respond_to do |format|
          format.html { redirect_to root_path,
                        alert: 'Please enter a non-negative 
                        integer value for radius.'}
        end
        return
      end
    end

    # provide values to fill the fake form for input#run
    @k = params[:keyword]
    @c = params[:city]
    @r = params[:radius]


    keyword = params[:keyword]
    loc = false                 # flag for location
    geo = ''                    # geo string for query

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
    @searches = Search.where("query = ?", params[:jid]).order("tweeted DESC")

    respond_to do |format|
      format.html # info.html.erb
    end
  end

  def visualize
    # DEBUG
    @jid = params[:jid]
    @locations = Location.all
    @searches = Search.where("query = ?", params[:jid])

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
