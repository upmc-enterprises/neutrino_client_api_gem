require 'rake'

Gem::Specification.new do |s|
  s.name     = 'cdris_api_client'
  s.version  = '3.1.0dev0.01'
  s.date     = '2015-04-20'
  s.summary  = 'Provides gateway to the CDRIS RESTful API'
  s.authors  = 'TDC data transformation, CDRIS'
  s.email    = 'tdccdrissupport@upmc.edu'
  s.files    = FileList['lib/**/*.rb',
                        'spec/**/*.rb',
                        'README.md',
                        'Gemfile*',
                        '*.gemspec'].to_a
  s.homepage = 'http://wiki.tdc.upmc.com/mediawiki/index.php/CDRIS'

  s.add_runtime_dependency 'api-auth',        '1.0.3'
  s.add_runtime_dependency 'rest-client',     '1.6.7'
  s.add_runtime_dependency 'multipart-post',  '2.0.0'

  s.add_development_dependency 'yard',          '0.8.7'
  s.add_development_dependency 'simplecov',     '0.8.2'
  s.add_development_dependency 'rspec',         '3.1'
  s.add_development_dependency 'fakeweb',       '1.3'
  s.add_development_dependency 'guard-rspec',   '4.5'
  s.add_development_dependency 'activesupport', '3.0'
  s.add_development_dependency 'i18n',          '0.6.4'
  s.add_development_dependency 'multi_json',    '1.8.4'
  s.add_development_dependency 'tzinfo',        '0.3.29'
end
