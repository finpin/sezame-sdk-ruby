#!/usr/bin/env ruby

require_relative '../lib/sezame-sdk/client'


client = Sezame::Client.new

clientcode   = '5651f679e65670.83760762'
sharedsecret = 'ba10d3346f71853c4ead9e9b5ac26db99ad43a7c09f7b3f880387b6540963e19'
email        = 'foo@example.com'

request = client.makecsr(clientcode, email)

p request[:csr]
p request[:key]
# p key.to_pem
# p key.public_key.to_pem

response = client.sign(request[:csr], sharedsecret)
if response.is_ok
  p response.get_cert
else
  p response.get_message
end

