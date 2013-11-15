#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'net/https'
require 'json'

alt_list = ARGV.first

uri = URI.parse("https://api.mojang.com/profiles/page/1")

output = File.new("uuid_list.txt", "w")

associations = 1

if (alt_list != nil)
	if (File.exist?(alt_list))
		puts "Parsing #{alt_list}"

		File.open(alt_list).each do |line|
			linked_uuids = Array.new

			query_list = line.split.map {|x| x = {'agent' => 'minecraft', 'name' => x}}

			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			# I don't think we have to distrust the mojang server, no matter how dumb mojang is
			# and this eliminates a bunch of annoying warnings that the client will start printing
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE

			request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
			request.body = JSON.generate(query_list)

			response = http.request(request)
			profile = JSON.parse(response.body)

			# We found some profiles associated with these users if the returned size is larger than 0
			if profile['size'] > 0
				profile['profiles'].inject(linked_uuids) {|result, element| result << element['id']}

				unless linked_uuids.empty?
					output.puts(linked_uuids.join(' '))
					puts "#{associations} association lists converted"
					associations += 1
				end
			end
		end
	end
end