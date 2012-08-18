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
    jid = ProcessJob.create(keyword: keyword, loc: final_loc, geo: geo)

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
