require 'net/http'
require 'uri'
require 'json'

SUMMONER_NAME = "javaspparow"
QUEUE_TYPE = "RANKED_SOLO_5x5"
API_KEY = "5b80d745-4ccc-4bd2-9eb4-5be06ee9c39c"

#get id of summoner
url = URI.parse("https://na.api.pvp.net/api/lol/na/v1.4/summoner/by-name/" + SUMMONER_NAME + "?api_key=" + API_KEY)
req = Net::HTTP::Get.new url
res = Net::HTTP.start(url.host, url.port,
					:use_ssl => url.scheme == 'https') {|http| http.request req}
id = JSON.parse(res.body)[SUMMONER_NAME]["id"]
puts "id:" + id.to_s

#get match history of summoner
index = 0
stats = Hash.new
total = 0
loop{
	url = URI.parse("https://na.api.pvp.net/api/lol/na/v2.2/matchhistory/" + id.to_s + "?rankedQueues=" + QUEUE_TYPE + "&api_key=" + API_KEY + "&beginIndex=" + index.to_s + "&endIndex=" + (index + 10).to_s)
	req = Net::HTTP::Get.new url
	res = Net::HTTP.start(url.host, url.port,
						:use_ssl => url.scheme == 'https') {|http| http.request req}
	matches = JSON.parse(res.body)["matches"]
	if(matches == nil || matches.size == 0)
		break
	end
	matches.each{|match|
		lane = match["participants"][0]["timeline"]["lane"]
		win = match["participants"][0]["stats"]["winner"].to_s
		puts lane + ":" + win
		if(stats[lane] == nil)
			stats[lane] = {"true" => 0, "false" => 0}
		end
		stats[lane][win] = stats[lane][win] + 1
		total = total + 1
	}
	index = index + 10
}
puts stats
puts "total:" + total.to_s