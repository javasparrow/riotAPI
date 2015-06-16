require 'net/http'
require 'uri'
require 'json'
require 'set'

#Program for output teamComp at RANKED5*5 master & callenger
#when error occurs at riot server, this program ignores it
#warning! this will overwrite OUTPUT 

comps = Array.new

API_KEY = "5b80d745-4ccc-4bd2-9eb4-5be06ee9c39c"
OUTPUT = "matchResult.bin"
LEAGUE = ["master", "challenger"]
REGION = ["kr", "na", "br", "eune", "euw", "lan", "las", "oce", "ru", "tr"]

REGION.each{|region|
gameSets = Set.new
LEAGUE.each{|league|

url = URI.parse("https://"+region+".api.pvp.net/api/lol/"+region+"/v2.5/league/" + league + "?type=RANKED_TEAM_5x5&api_key=" + API_KEY)
req = Net::HTTP::Get.new url
res = Net::HTTP.start(url.host, url.port,
					:use_ssl => url.scheme == 'https') {|http| http.request req}
if(res.code != "200")
	puts "ERROR!"
	puts res.body
	next
end
entries = JSON.parse(res.body)["entries"]


if(entries == nil)
	next
end
puts res.body
entries.each{|entry|
	puts entry
	teamId = entry["playerOrTeamId"]
	url = URI.parse("https://"+region+".api.pvp.net/api/lol/"+region+"/v2.4/team/" + teamId + "?api_key=" + API_KEY)
	req = Net::HTTP::Get.new url
	res = Net::HTTP.start(url.host, url.port,
					:use_ssl => url.scheme == 'https') {|http| http.request req}
	
	if(res.code != "200")
		puts "ERROR!"
		puts res.body
		next
	end
	matchs = JSON.parse(res.body)[teamId]["matchHistory"]
	matchs.each{|match|
		puts match
		gameId = match["gameId"]
		if(match["gameMode"] != "CLASSIC")
			next
		end
		if(gameSets.include?(gameId))
			next
		end
		gameSets.add(gameId)
		sleep(2)
		url = URI.parse("https://"+region+".api.pvp.net/api/lol/"+region+"/v2.2/match/" + gameId.to_s + "?api_key=" + API_KEY)
		req = Net::HTTP::Get.new url
		res = Net::HTTP.start(url.host, url.port,
					:use_ssl => url.scheme == 'https') {|http| http.request req}
		if(res.code != "200")
			puts "ERROR!"
			puts res.body
			next
		end
		participants = JSON.parse(res.body)["participants"]
		team1 = Set.new
		team2 = Set.new
		puts res.body
		participants.each{|participant|
			teamId = participant["teamId"].to_s
			championId = participant["championId"].to_s
			puts teamId + ":" +championId
			if(teamId == "100")
				team1.add championId
			else
				team2.add championId
			end
		}
		if(team1.size == 5)
			comps.push team1
		end
		if(team2.size == 5)
			comps.push team2
		end
	}
}
}
}

 file = File.open(OUTPUT, "w")
    comps.each do |comp|
    	comp.each{|champ|
    		file.write(champ.to_s)
    		file.write(",")
    	}
        file.write("\n")
    end
    file.close


