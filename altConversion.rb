#!/usr/bin/env ruby

require 'rubygems'
require 'net/http'
require 'net/https'
require 'json'

alt_list = ARGV.first

uri = URI.parse("https://api.mojang.com/profiles/page/1")

output = File.new("uuid_list.txt", "w")

if (alt_list != nil)
	if (File.exist?(alt_list))
		puts "Parsing #{alt_list}"

		File.open(alt_list).each do |line|
			linked_uuids = Array.new

			line.split.each do |account|
				json_body = JSON.generate({'agent' => 'minecraft', 'name' => account})

				http = Net::HTTP.new(uri.host, uri.port)
				http.use_ssl = true
				# I don't think we have to distrust the mojang server, no matter how dumb mojang is
				# and this eliminates a bunch of annoying warnings that the client will start printing
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE

				request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
				request.body = json_body

				response = http.request(request)

				profile = JSON.parse(response.body)

				if profile['profiles'][0]['id'] != nil
					linked_uuids << profile['profiles'][0]['id']
					puts "#{account} : #{profile['profiles'][0]['id']}"
				end
			end

			unless linked_uuids.empty?
				line = linked_uuids.join(' ')
				output.puts(line)
			end
		end
	end
end