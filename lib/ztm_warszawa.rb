require "ztm_warszawa/version"
require 'httparty'
require 'addressable/uri'
require 'rss'

class NoDepartures < StandardError; end
class BusStopNotFound < StandardError; end
class NightLineError < StandardError; end
class NoApiKey < StandardError; end



class ZtmWarszawa

	attr_writer :api_key

	#def initialize(api_key)
		#@api_key = api_key
	#end

	# Queries the ZTM API to get the bus stop's ID from its name.
	# The ID is required for all the latter operations.
	def get_stop_id(bus_stop_name)
		raise NoApiKey, "No API key specified." if @api_key.nil?
		raw_url = "https://api.um.warszawa.pl/api/action/dbtimetable_get?id=b27f4c17-5c50-4a5b-89dd-236b282bc499&name=#{bus_stop_name}&apikey=#{@api_key}"
		url = Addressable::URI.parse(raw_url)
		response = HTTParty.get(url.normalize).parsed_response["result"]
		raise BusStopNotFound, 'Bus stop not found' if response.empty?
		bus_stop_id = response[0]["values"][0]["value"]
		return bus_stop_id
	end

	# Returns an array of bus lines (e.g. 527, 141...) that depart from a given bus stop.
	def get_bus_lines(bus_stop_id, bus_stop_no)
		raise NoApiKey, "No API key specified." if @api_key.nil?
		bus_lines = []
	
		url = "https://api.um.warszawa.pl/api/action/dbtimetable_get/?id=88cd555f-6f31-43ca-9de4-66c479ad5942&busstopId=#{bus_stop_id}&busstopNr=#{bus_stop_no}&apikey=#{@api_key}"
		response = HTTParty.get(url).parsed_response["result"]
		raise NoDepartures, 'No vehicles seem to depart from here.' if response.empty?

		response.each do |bus_line_info|
		bus_lines << bus_line_info["values"][0]["value"]
		end
		return bus_lines
	end

	# Returns the server response with all the hours of departure of a given bus line from a given bus stop.
	def get_line_departure_hours(bus_stop_id, bus_stop_no, bus_line)
		raise NoApiKey, "No API key specified." if @api_key.nil?
		raise NightLineError, 'Night bus lines are not supported due to some server-side errors.' if bus_line.start_with? "N"
		url = "https://api.um.warszawa.pl/api/action/dbtimetable_get?id=e923fa0e-d96c-43f9-ae6e-60518c9f3238&busstopId=#{bus_stop_id}&busstopNr=#{bus_stop_no}&line=#{bus_line}&apikey=#{@api_key}"
		response = HTTParty.get(url).parsed_response["result"]
		return response
	end

	# From the server's response from get_line_departure_hours(), find a given number of closest departures
	def get_closest_departures(server_response, script_starting_time, bus_line, number_of_departures)
		bus_data = server_response
		closest_departures = []

			bus_data.each do |bus|
				diff = Time.parse(bus["values"][0]["value"]) - script_starting_time
				if diff > 0
					closest_departures << {"bus_line" => bus_line, "time" => bus["values"][0]["value"] }
				end
			end

		return closest_departures.take(number_of_departures)
	end

	def check_alerts
		alerts = []
		alert_page = HTTParty.get("http://ztm.waw.pl/rss.php?l=1&IDRss=6")
		alert_feed = RSS::Parser.parse(alert_page.body)

		alert_feed.items.each do |item|
			alerts << {"title" => item.title, "link" => item.link, "description" => item.description}
		end
		return alerts
	end

end
