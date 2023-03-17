# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'neutrino/gateway/version'
Gem::Specification.new do |s|
  s.name     = 'neutrino_api_client'
  s.version  = Neutrino::Gateway::VERSION
  s.date     = '2020-01-30'
  s.summary  = 'Provides gateway to the Neutrino RESTful API'
  s.description = 'Provides gateway to interact with a Neutrino instance over HTTP'
  s.authors  = 'UPMC Enterprises'
  s.email    = 'upmcenterprisescdrissupport@upmc.edu'
  s.license  = 'UPMC'
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  s.files += Dir['README.md'] + Dir['Gemfile*'] + Dir['*.gemspec']
  s.homepage = 'https://upmcenterprises.atlassian.net/wiki/spaces/CDRIS/overview'

  s.add_runtime_dependency 'api-auth',        '2.3.1'
  s.add_runtime_dependency 'mime-types',      '3.2.2'
  s.add_runtime_dependency 'rest-client',     '2.0.2'
  s.add_runtime_dependency 'multipart-post',  '2.1.1'
  s.add_runtime_dependency 'activesupport',   '>= 6', '< 8'

  s.add_development_dependency 'webmock',       '3.8.0'
  s.add_development_dependency 'guard-rspec',   '4.7.3'
  s.add_development_dependency 'i18n',          '1.6.0'
  s.add_development_dependency 'multi_json',    '1.13.1'
  s.add_development_dependency 'rspec',         '3.8.0'
  s.add_development_dependency 'simplecov',     '0.17.0'
  s.add_development_dependency 'yard',          '0.9.20'

end
