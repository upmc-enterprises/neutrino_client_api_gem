require 'rake'

Gem::Specification.new do |s|
  s.name     = 'cdris_api_client'
  s.version  = '2.3.0dev2.2'
  s.date     = '2014-03-07'
  s.summary  = 'Provides gateway to the CDRIS RESTful API'
  s.authors  = 'TDC data transformation, CDRIS'
  s.email    = 'tdccdrissupport@upmc.edu'
  s.files    = FileList['lib/**/*.rb',
                        'spec/**/*.rb',
                        'README.md',
                        'Gemfile*',
                        '*.gemspec'].to_a
  s.homepage = 'http://wiki.tdc.upmc.com/mediawiki/index.php/CDRIS'
#  s.license  = '???'

  s.add_runtime_dependency 'api-auth',        '1.0.3'
  s.add_runtime_dependency 'rest-client',     '1.6.7'
  s.add_runtime_dependency 'multipart-post',  '2.0.0'

  s.add_development_dependency 'yard',        '0.8.7'
  s.add_development_dependency 'simplecov',   '0.8.2'
  s.add_development_dependency 'rspec',       '2.14'
  s.add_development_dependency 'fakeweb',     '1.3'
  s.add_development_dependency 'guard-rspec', '2.5'
end
