module InputHelper
  require 'csv'

  def csvhelper(jid)
    CSV.generate do |csv|
      results = Search.where("query = ?", jid).order("tweeted DESC")
      results.each do |search|
        csv << [search.lat, search.lon, search.text, search.tweeted,
                search.statuses, search.followers, search.friends,
                search.mood]
      end
    end
  end

end