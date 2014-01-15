# CDRIS API Client gem

## Generating
In the project's root execute:
```
gem build cdris_api_client.gemspec
```

## Installing
After generating the gem, in the project's root execute:
```
gem install cdris_api_client -v <version>
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

 - `Cdris::Gateway::Clu`
 - `Cdris::Gateway::Info`
 - `Cdris::Gateway::MapType`
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
