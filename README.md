# NEUTRINO API Client gem

## Versioning
The gem follows the following versioning scheme
```
<NEUTRINO_version>dev<major_version>.<minor_version>
```
where
 - `<NEUTRINO_version>` is the compatible version of NEUTRINO of which the gem acts as a gateway
 - `<major_version` is the major version of the gem, indicating breaking changes for the given version of NEUTRINO
 - `<minor_version>` is the minor version of the gem, indicating non-breaking changes

The gem version can be updated in lib/documents/gateway/version.rb

## Generating
In the project's root execute:
```
gem build document_api_client.gemspec
```

## Packaging in a Rails project
After generating the gem, unpack it into the Rails' project's `vendor` folder:
```
gem unpack document_api_client-<version>.gem --target <rails_project>/vendor/gems/
```
where
 - `<version>` is the version of the document_api_client
 - `<rails_project>` is the root directory of the rails project

Add a line like the following to the project's Gemfile:
```
gem 'document_api_client', '<version>', :path => 'vendor/gems/document_api_client-<version>'
```
where `<version>` is the version of the document_api_client

## Development
To pull in development dependencies, from the project's root execute:
```
bundle install
```
To see the availble development tasks execute:
```
rake -T
```

To run unit test:
```
bundle exec rspec
```

## Usage

```
require 'document_api_client'
```

### Configuration

```
Neutrino::Api::Client.config = <some config hash>
```

Where `<some config hash>` is a ruby hash that specifies the required configurations

#### Example Configuration

```
Neutrino::Api::Client.config = {
  :protocol => 'http',
  :host => 'localhost',
  :port => '3000',
  :user_root => 'some_root',
  :user_extension => 'some_extension',
  :api_version => '1',
  :hmac_key => '.....',
  :hmac_id => '.....',
  :auth_user => 'foobar',
  :auth_pass => 'spameggs'
}
```

**Notes**

 - The key`:api_version` is not required, but will default to `'1'` if not specified.
 - To follow the HIPAA Compliance, you should always pass :remote_ip in the option when you use Neutrino::Gateway

### Gateway

Requests to NEUTRINO are made through `Gateway` classes:

 - `Documents::Gateway::Info`
 - `Documents::Gateway::MapType`
 - `Documents::Gateway::OidText`
 - `Documents::Gateway::NamedQuery`
 - `Documents::Gateway::PatientDocument`
 - `Documents::Gateway::Patient`

Requests typically return a ruby `Hash` (parsed from JSON), but they may return other data as well (e.g. `String`)

### Example Usage

```
require 'document_api_client'

Neutrino::Api::Client.config = {
  :protocol => 'http',
  :host => 'localhost',
  :port => '3000',
  :user_root => 'my_username',
  :user_extension => 'my_extension',
  :tenant_id => <tenant_id>,
  :tenant_key => <tenant_key>,
  :hmac_id => <app_id>,
  :hmac_key => <app_key>
}

Documents::Gateway::PatientDocument.get({ id: "530fb1cce4b038c5cae1f417" }, { remote_ip: "100.1.24.1" })
```

## To generate release
 - Install github-release-notes https://github.com/github-tools/github-release-notes
 - To generate a release from a spcific tag:
```
  gren release --tags=<tag_name> --token ewsdewe26ffd4c1130337025b7a3f5bdewqse
```
