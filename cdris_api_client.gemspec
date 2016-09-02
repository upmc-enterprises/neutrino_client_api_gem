# coding: utf-8
require 'rake'
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cdris/gateway/version'
Gem::Specification.new do |s|
  s.name     = 'cdris_api_client'
  s.version  = Cdris::Gateway::VERSION
  s.date     = '2016-09-08'
  s.summary  = 'Provides gateway to the Neutrino RESTful API'
  s.description = 'Provides gateway to interact with a Neutrino instance over HTTP'
  s.authors  = 'UPMC Enterprises'
  s.email    = 'tdccdrissupport@upmc.edu'
  s.license  = 'UPMC'
  s.files    = FileList['lib/**/*.rb',
                        'spec/**/*.rb',
                        'README.md',
                        'Gemfile*',
                        '*.gemspec'].to_a
  s.homepage = 'https://confluence.upmc.com/display/CDRIS/CDRIS+Project+Space'

  s.add_runtime_dependency 'api-auth',        '1.4.1'
  # Mime-types is a unbounded dependancy of rest-client, newer versions
  # requre ruby 2 which is not desired
  s.add_runtime_dependency 'mime-types',      '< 2.99'
  s.add_runtime_dependency 'rest-client',     '1.6.7'
  s.add_runtime_dependency 'multipart-post',  '2.0.0'
  s.add_runtime_dependency 'activesupport',   '~> 3.0'

  s.add_development_dependency 'fakeweb',       '1.3'
  s.add_development_dependency 'guard-rspec',   '4.5'
  s.add_development_dependency 'i18n',            '~> 0.6', '>= 0.6.4'
  s.add_development_dependency 'multi_json',    '1.8.4'
  s.add_development_dependency 'rspec',         '3.1'
  s.add_development_dependency 'simplecov',     '0.8.2'
  s.add_development_dependency 'tzinfo',        '0.3.29'
  s.add_development_dependency 'yard',          '0.8.7'
end
