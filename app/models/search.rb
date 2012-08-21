class Search < ActiveRecord::Base
  attr_accessible :tweeted, :followers, :friends, :lat, :loc, :lon, :mood, 
  	:name, :source, :statuses, :text, :timezone, :user, :userid, :query

  validates :text, :presence => true
  validates :tweeted, :presence => true
  validates :lat, :presence => true
  validates :lon, :presence => true
  validates :query, :presence => true

end
