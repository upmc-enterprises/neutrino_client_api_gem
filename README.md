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

The gem version can be updated in lib/neutrino/gateway/version.rb

## Generating
In the project's root execute:
```
gem build neutrino_api_client.gemspec
```

## Packaging in a Rails project
After generating the gem, unpack it into the Rails' project's `vendor` folder:
```
gem unpack neutrino_api_client-<version>.gem --target <rails_project>/vendor/gems/
```
where
 - `<version>` is the version of the neutrino_api_client
 - `<rails_project>` is the root directory of the rails project

Add a line like the following to the project's Gemfile:
```
gem 'neutrino_api_client', '<version>', :path => 'vendor/gems/neutrino_api_client-<version>'
```
where `<version>` is the version of the neutrino_api_client

## Development
To pull in development dependencies, from the project's root execute:
```
bundle install
```
To see the availble development tasks execute:
```
rake -T
```

## To pack into NEUTRINO OP UI
To add into the NEUTRINO OP UI for the container build:
```
cp neutrino_api_client-<version>.gem ../neutrino_test_ui/lib
```

## Usage

```
require 'neutrino_api_client'
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

### Gateway

Requests to NEUTRINO are made through `Gateway` classes:

 - `Neutrino::Gateway::Info`
 - `Neutrino::Gateway::MapType`
 - `Neutrino::Gateway::OidText`
 - `Neutrino::Gateway::NamedQuery`
 - `Neutrino::Gateway::PatientDocument`
 - `Neutrino::Gateway::Patient`

Requests typically return a ruby `Hash` (parsed from JSON), but they may return other data as well (e.g. `String`)

### Example Usage

```
require 'neutrino_api_client'

Neutrino::Api::Client.config = {
  :protocol => 'http',
  :host => 'localhost',
  :port => '3000',
  :user_root => 'my_username',
  :user_extension => 'my_extension'
}

Neutrino::Gateway::PatientDocument.get({ :id => "530fb1cce4b038c5cae1f417" })
```
