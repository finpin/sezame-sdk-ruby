#!/usr/bin/env ruby

require_relative '../lib/sezame-sdk/client'

client = Sezame::Client.new

response = client.register 'foo@example.com', 'rubysdk test'
if response.is_ok
  p response.get_clientcode
  p response.get_sharedsecret
end
