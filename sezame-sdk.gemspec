# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'sezame-sdk/version'

Gem::Specification.new do |s|
  s.name        = 'sezame-sdk'
  s.version     = SezameSDK::VERSION
  s.date        = '2015-11-27'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Michael Bretterklieber']
  s.email       = ['sezame-ruby@bretterklieber.com']
  s.homepage    = 'https://www.seza.me/'
  s.license     = 'MIT'
  s.summary     = 'Sezame ruby SDK'
  s.description = <<EOF
SezameSDK allows you to integrate the next generation
authentication system into your application.
EOF

  s.add_dependency 'rqrcode', '~> 0'
  s.add_dependency 'httpclient', '~> 2.7'

#  s.extra_rdoc_files = `ls examples/*.rb`.split("\n")
  s.files = `ls lib/sezame-sdk/*.rb`.split("\n")
  s.files.push 'lib/sezame-sdk.rb'
  s.require_paths = ['lib']
end