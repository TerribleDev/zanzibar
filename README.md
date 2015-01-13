# Zanzibar
[![Gem Version](https://badge.fury.io/rb/zanzibar.svg)](http://badge.fury.io/rb/zanzibar)

Zanzibar is a utility to retrieve secrets from a Secret Server installation. It supports retrieval of a password, public/private key, or secret attachment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zanzibar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zanzibar

## Usage

In your ruby project, rakefile, etc., create a new Zanzibar object. The constructor takes a hash of optional parameters for the WSDL location, the domain of the Secret Server, a hash of global variables to pass to savon (necessary for windows environments with self-signed certs) and a password for the current user (intended to be passed in through some encryption method, unless you really want a plaintext password there.). All of these parameters are optional and the user will be prompted to enter them if they are missing.

```ruby
  my_object = Zanzibar::Zanzibar.new(:domain => 'my.domain.net', :wsdl => 'my.scrt.srvr.com/webservices/sswebservice.asmx?wdsl', :pwd => get_encrypted_password_from_somewhere)
```

Example:

```ruby
require 'zanzibar'

## Constructor takes hash as argument, all optional :domain, :wsdl, :pwd, :globals
secrets = Zanzibar::Zanzibar.new(:domain => 'mydomain.net', :wsdl => "https://my.scrt.server/webservices/sswebservice.asmx?wsdl")
# On windows with self-signed certs,
# Zanzibar::Zanzibar.new(:domain => 'mydomain.net', :wsdl => "https://my.scrt.server/webservices/sswebservice.asmx?wsdl", :globals => {:ssl_verify_mode => :none})

## Simple password -> takes secret id as argument
secrets.get_secret(1234)

## Private Key -> takes hash as argument, requires :scrt_id, optional :scrt_item_id, :path
secrets.download_private_key(:scrt_id => 2345, :path => 'secrets/')

## Public Key -> takes hash as argument, requires :scrt_id, optional :scrt_item_id, :path
secrets.download_public_key(:scrt_id => 2345, :path => 'secrets/')

## Attachment; only supports secrets with single attachment -> takes hash as argument, requires :scrt_id, optional :scrt_item_id, :path
secrets.download_attachment(:scrt_id => 3456, :path => 'secrets/')

```

## Contributing

1. Fork it ( https://github.com/Cimpress-MCP/zanzibar/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
