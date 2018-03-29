# CDRIS API Client gem

## Versioning
The gem follows the following versioning scheme
```
<CDRIS_version>dev<major_version>.<minor_version>
```
where
 - `<CDRIS_version>` is the compatible version of CDRIS of which the gem acts as a gateway
 - `<major_version` is the major version of the gem, indicating breaking changes for the given version of CDRIS
 - `<minor_version>` is the minor version of the gem, indicating non-breaking changes

The gem version can be updated in lib/cdris/gateway/version.rb

## Generating
In the project's root execute:
```
gem build cdris_api_client.gemspec
```

## Packaging in a Rails project
After generating the gem, unpack it into the Rails' project's `vendor` folder:
```
gem unpack cdris_api_client-<version>.gem --target <rails_project>/vendor/gems/
```
where
 - `<version>` is the version of the cdris_api_client
 - `<rails_project>` is the root directory of the rails project

Add a line like the following to the project's Gemfile:
```
gem 'cdris_api_client', '<version>', :path => 'vendor/gems/cdris_api_client-<version>'
```
where `<version>` is the version of the cdris_api_client

## Development
To pull in development dependencies, from the project's root execute:
```
bundle install
```
To see the availble development tasks execute:
```
rake -T
```

## To pack into CDRIS OP UI
To add into the CDRIS OP UI for the container build:
```
cp cdris_api_client-<version>.gem ../cdris_test_ui/lib
```

## Usage

```
require 'cdris_api_client'
```

### Configuration

```
Cdris::Api::Client.config = <some config hash>
```

Where `<some config hash>` is a ruby hash that specifies the required configurations

#### Example Configuration

```
Cdris::Api::Client.config = {
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

Requests to CDRIS are made through `Gateway` classes:

 - `Cdris::Gateway::Info`
 - `Cdris::Gateway::MapType`
 - `Cdris::Gateway::OidText`
 - `Cdris::Gateway::NamedQuery`
 - `Cdris::Gateway::PatientDocument`
 - `Cdris::Gateway::Patient`

Requests typically return a ruby `Hash` (parsed from JSON), but they may return other data as well (e.g. `String`)

### Example Usage

```
require 'cdris_api_client'

Cdris::Api::Client.config = {
  :protocol => 'http',
  :host => 'localhost',
  :port => '3000',
  :user_root => 'my_username',
  :user_extension => 'my_extension'
}

Cdris::Gateway::PatientDocument.get({ :id => "530fb1cce4b038c5cae1f417" })
```
