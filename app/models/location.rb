require 'texticle/searchable'

class Location < ActiveRecord::Base
  attr_accessible :address, :latitude, :longitude

  # Validations
  validates :address, :uniqueness => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true

  # Limit scope of Texticle search
  extend Searchable(:address)

  # Geocoder stuff
  geocoded_by :address
  before_validation :special_geocode, :if => :address_changed? # dirty tracking

  private
  	def special_geocode
  	  if attribute_present? 'address'
  	  	geocode
  	  end
  	end

end
