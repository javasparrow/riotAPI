require 'set'
require 'net/http'
require 'uri'
require 'json'

API_KEY = "5b80d745-4ccc-4bd2-9eb4-5be06ee9c39c"

rank = Hash.new
champRank = Hash.new
champName = Hash.new

url = URI.parse("https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key=" + API_KEY)
req = Net::HTTP::Get.new url
res = Net::HTTP.start(url.host, url.port,
				:use_ssl => url.scheme == 'https') {|http| http.request req}

JSON.parse(res.body)["data"].each{|name,content|
	champName[content["id"].to_s] = name
}

open("matchResult.bin") {|file|
  while l = file.gets
    hoge = l[0...-1].split(',')
    team = Set.new
    hoge.each{|champ|
    	team.add champ
    	if(champRank[champ] == nil)
    		champRank[champ] = 0
    	end
    	champRank[champ] = champRank[champ] + 1
    }
    if(rank[team] == nil)
    	rank[team] = 0
    else
    	puts "count:" + rank[team].to_s
    	hoge.each{|champ|
    		puts champName[champ]
    	}
    	puts "\n"
    end
    rank[team] = rank[team] + 1
  end
}

champRank.each{|a,b|
	puts champName[a] + ":" + b.to_s
}