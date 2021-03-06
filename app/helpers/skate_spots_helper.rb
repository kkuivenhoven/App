module SkateSpotsHelper

	def checkDate(newEvents, date, keyEvents)
		if newEvents.include?(date.to_date)
			@ev = Event.find_by(date: keyEvents[newEvents.index(date.to_date).to_i])
			return "<span class='skate_link' data-toggle='tooltip' data-placement='bottom' title='#{ @ev.name.capitalize } event @ #{ @ev.date.time.strftime("%l:%M %p") }' style='color: #f4ffe3'>
							 #{ link_to date.strftime("%e"), events_path }
					</span>".html_safe
		else
			return "#{ date.strftime("%e") }".html_safe
		end
	end

	def getTags(id)
		@ht_ids = Array.new

		HashTag.all.each do |h_tag|
			if h_tag.skate_spot_ids.keys.include?(id) == true
				@ht_ids.push(h_tag.id)
			end
		end
		
		@pop_tags = HashTag.where(id: @ht_ids)
		return @pop_tags
	end


	def material_words(skate_spot)
      if skate_spot.wood && skate_spot.concrete && skate_spot.metal
				return "&#9687; wood<br>&#9687; concrete<br>&#9687; metal".html_safe
      elsif skate_spot.wood && skate_spot.concrete
				return "&#9687; wood<br>&#9687; concrete".html_safe
      elsif skate_spot.wood && skate_spot.metal
				return "&#9687;wood<br> &#9687; metal".html_safe
      elsif skate_spot.concrete && skate_spot.metal 
				return "&#9687;concrete<br>&#9687; metal".html_safe
      elsif skate_spot.wood 
				return "&#9687; wooden".html_safe
      elsif skate_spot.metal
				return "&#9687; metal".html_safe
      elsif skate_spot.concrete
				return "&#9687; concrete".html_safe
      else 
				return "&#9687; no material listed".html_safe
      end
	end


	def ss_size(skate_spot)
    if skate_spot.skate_spot_size 
			return "&#9687; skate spot".html_safe
    elsif skate_spot.neighborhood_spot_size 
			return "&#9687; neighborhood spot".html_safe
    elsif skate_spot.regional_spot_size 
			return "&#9687; regional spot".html_safe
    else 
			return "&#9687; no size listed".html_safe
    end
	end


	def ss_type(skate_spot)
		if skate_spot.transition 
			return "&#9687; transition".html_safe
		elsif skate_spot.street_plaza 
			return "&#9687; street plaza".html_safe
		else 
			return "&#9687; not listed".html_safe
		end
	end


end
