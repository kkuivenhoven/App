class SkateSpot < ActiveRecord::Base

  belongs_to :user
  has_many :ratings
  has_many :events, dependent: :destroy
	# has_many :microposts, dependent: :destroy
	serialize :user_votes, Hash

  #geocoded_by :complete_address
  geocoded_by :gmaps4rails_address
	after_validation :geocode
  #reverse_geocoded_by :latitude, :longitude
	#acts_as_gmappable

	# validates_presence_of makes sure that the user provided input for that specified attribute
  validates_presence_of :name
  ##makes sure that the user enters in a country of 3 characters (i.e. USA)
  #validates :country, :length => { :is => 3 }, :on => :create

  # searches the SkateSpot DB for skate_spots with term that has been specified by the user
  def self.search(search)
    where("name LIKE ? OR street LIKE ? OR city LIKE ? OR zip_code LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%") 
  end

	def num_and_st
		number_street = "#{number} #{street}"
		return number_street
	end

	def basic_address
		[num_and_st, city].join(', ')
	end

	def just_city
		return "#{city}"
	end

	def complete_address
		[num_and_st, city, state, zip_code].join(', ')
	end

	def complete_address_LB
		addr = [num_and_st].join(', ')
		lineBreak = ",<br>"
		partialAddr = addr + lineBreak + city
		fullAddr = [partialAddr, state, zip_code].join(', ').html_safe
	  return fullAddr	
	end

	def gmaps4rails_address
		return "#{complete_address}"
	end

	def get_coords
		return Geocoder.coordinates(complete_address)
	end

  def get_lat
		return get_coords[0]
	end
  def get_long
		return get_coords[1]
	end

	def set_lat_long
			@skate_spot.latitude = get_lat
			@skate_spot.longitude = get_long
  end

  def self.get_recommendations(matchVals, lowDiff, highDiff, lowSec, highSec, lowPed, highPed)
		@m_ids = Array.new
		matchVals.each do |key, val|
			diffBool = val["avgDiff"].between?(lowDiff, highDiff)
			secBool = val["avgSec"].between?(lowSec, highSec)
			pedBool = val["avgPed"].between?(lowPed, highPed)
			if (diffBool == true) and (secBool == true) and (pedBool == true)
				@m_ids << key
			end
		end
		return @m_ids
	end


	def self.find_spots(params, skate_spots, vote_IDs)
	 @skate_spots = skate_spots
   # if vote_IDs.count != 0
   # if !vote_IDs.nil?
   if vote_IDs.length != 0
		 if (@skate_spots.ids & vote_IDs).any?
			 vote_IDs = (@skate_spots.ids & vote_IDs)
			 @skate_spots = @skate_spots.find(vote_IDs)
		 else
			 @skate_spots = nil
     end
	 end
	 if @skate_spots.present?
			if params[:metal][:metal] == "1"
				@skate_spots.select { |ss| ss.metal == true }
			end
			if params[:wood][:wood] == "1"
				@skate_spots.select { |ss| ss.wood == true }
			end
			if params[:concrete][:concrete] == "1"
				@skate_spots.select { |ss| ss.concrete == true }
			end
			if params[:gated][:gated] == "1"
				@skate_spots.select { |ss| ss.gated == true }
			end
			if params[:spotSize][:spotSize] == "1"
				@skate_spots.select { |ss| ss.skate_spot_size == true }
			elsif params[:neighSize][:neighspotSize] == "1"
				@skate_spots.select { |ss| ss.neighborhood_spot_size == true }
			elsif params[:regSize][:regSize] == "1"
				@skate_spots.select { |ss| ss.regional_spot_size == true }
			end
			if params[:transition][:transition] == "1"
				@skate_spots.select { |ss| ss.transition == true }
			end
			if params[:streetPlaza][:streetPlaza] == "1"
				@skate_spots = @skate_spots.select { |ss| ss.street_plaza == true }
			end
			if params[:wcmxAccessible][:wcmxAccessible] == "1"
				@skate_spots = @skate_spots.select { |ss| ss.wcmx_accessible == true }
			end
			if params[:bmxAccessible][:bmxAccessible] == "1"
				@skate_spots = @skate_spots.select { |ss| ss.bmx_accessible == true }
			end
			# if @skate_spots.count != 0
			if @skate_spots.length != 0
				if params[:search].length != 0
					@skate_spots.select { |ss| params[:search] }
				end
			end
	  end 
		return @skate_spots
	end


end
