# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'sezame-sdk/version'

Gem::Specification.new do |s|
  s.name        = 'sezame-sdk'
  s.version     = SezameSDK::VERSION
  s.date        = '2016-03-19'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Finpin']
  s.email       = ['office@finpintech.com']
  s.homepage    = 'https://www.seza.me/'
  s.license     = 'BSD'
  s.summary     = 'Sezame ruby SDK'
  s.description = <<EOF
Passwordless multi-factor authentication.

Unlike password-based solutions that require you to remember just another PIN or password,
sezame is a secure and simple multi-factor authentication solution.
You only need the username and your fingerprint on your smartphone to log into any sezame-enabled site.
EOF

  s.add_dependency 'rqrcode', '~> 0'
  s.add_dependency 'httpclient', '~> 2.7'

#  s.extra_rdoc_files = `ls examples/*.rb`.split("\n")
  s.files = `ls lib/sezame-sdk/*.rb`.split("\n")
  s.files.push 'lib/sezame-sdk.rb'
  s.require_paths = ['lib']
end