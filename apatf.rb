#!/usr/bin/ruby

###
#
# apatf - web application testing toolkit based on the levenshtein function (distance)
# calculates the distance between two http/s replies / files / strings
# > dev 002
#
# by me! ;) richard
#
# set ts=3
#
###

require 'net/http'

begin
	require "./mylev/Mylev.so"
rescue LoadError
	$stderr.puts "ERROR: Wasn't able to load the Levenshtein C implementation (Mylev.so)!"
	$stderr.puts "ERROR: Please check the README!"
	exit
end


#globals
$uriA = nil
$uriB = nil
$compare = 0
$stability = 0

$fcnt = 5
$threshold = 0.10

$verbose = false
$debug = false

def cargs()

	if ARGV[0] == nil or ARGV[1] == nil then
		puts "USAGE: SCRIPT OPTION ARGUMENT1 [ARGUMENT2] [PARAMTER=VALUE]"
		puts "  Options:"
		puts "    compare - call it with two resource uris (http/s|file) and get the distance"
		puts "    stable  - call it with one resource uri (http/s|file) see if its stable"
		puts "  Paramters:"
		puts "    threshold  - any value from 0.0 to 1.0; default: 0.10; means 10% diff is fine"
		puts "    count      - the amount responses to fetch"
		exit
	end

	ARGV.each do |x|
		if /^(compare|comp|cmp)/.match(x) and $compare == 0 then
			$compare = 1
			if ARGV[1] == nil or ARGV[2] == nil then
				puts "ERROR: need two URIs two test!"
				exit
			end
			$uriA = URI(ARGV[1])
			$uriB = URI(ARGV[2])
		end
		if /^(stability|stab|stable)/.match(x) and $stability == 0 then
			$stability = 1
			$uriA = URI(ARGV[1])
		end
		if /^count=(?<rcnt>\d+)/ =~ x then
			$fcnt = rcnt.to_i
		end
		if /^threshold=(?<rthresh>\d+\.\d+)/ =~ x then
			$threshold = rthresh.to_f
		end
		if /^(v|verbose)/.match(x) then
			$verbose = true
			puts "VERBOSE: verbose == true"
		end
		if /^(d|debug)/.match(x) then
			$debug = true
			puts "DEBUG: debug == true"
		end
	end

end

def fetch(uri)

	if uri.scheme.match("http|https") then
		http = Net::HTTP.new(uri.host, uri.port)
		if uri.scheme == 'https' then 
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
		end
		res = http.request(Net::HTTP::Get.new(uri.request_uri))
		c = res.body
	else 
		if uri.scheme.match("file") then
			res = File.read(uri.path)
			c = res
		else
			puts "UNKOWN SCHEME FOR res! (#{uri.scheme})"
			exit
		end
	end

	if $debug == true then
		puts "--------------------------- DEBUG ---------------------------"
		puts c
		puts "--------------------------- DEBUG ---------------------------"
	end

	if $verbose == true then
		puts "VERBOSE: fetched #{c.length} bytes"
	end

	return c

end

def lev(a, b)

	size=[a.length, b.length].max.to_f
	return Mylev.mydist(a, b).to_f/size

end

def stability(a)

	aa = fetch(a)
	
	unstable=0
	t = 0.00
	c = 0

	$fcnt.times do 
		t = lev(aa, fetch(a)).to_f
		if $verbose == true then
			puts "VERBOSE: response #{c+=1} has lev(#{t})"
		end
		if t > $threshold then
			unstable+=1
		end
	end

	if unstable > 0 then
		puts "UNSTABLE (#{unstable}/#{$fcnt} did not meet the threshold [#{$threshold}])"
	else
		puts "STABLE (all responses were within the threshold [#{$threshold}])"
	end

end


def compare(a, b)

	aa = fetch(a)
	bb = fetch(b)

	puts lev(aa, bb)

end

cargs()

if $stability == 1 then
	stability($uriA)
end

if $compare == 1 then
	compare($uriA, $uriB)
end

