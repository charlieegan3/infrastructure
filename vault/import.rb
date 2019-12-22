#!/usr/bin/env ruby

require "json"

unless File.exists?("vault.json")
  puts "vault.json missing"; exit 1
end

data = JSON.parse(File.read("vault.json"))

data.each do |k, v|
  File.write("data.json", v)
  puts `vault write #{k} @data.json`
end
