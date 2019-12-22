#!/usr/bin/env ruby

require "json"

paths = {}

groups = JSON.parse(`vault list -format=json secret`)

groups.each do |group|
  keys = JSON.parse(`vault list -format=json secret/#{group}/`)

  keys.each do |key|
    data = `vault read -format=json secret/#{group}/#{key} | jq .data`
    paths["secret/#{group}#{key}"] = data
    puts "secret/#{group}#{key}"
  end
end

File.write("vault.json", JSON.pretty_generate(paths))
puts "cat vault.json | pbcopy && pass edit Personal/Note/vault-secrets"
