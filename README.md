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
secrets.get_password(1234)

## Private Key -> takes hash as argument, requires :scrt_id, :type, optional :scrt_item_id, :path
secrets.download_secret_file(:scrt_id => 2345, :path => 'secrets/', :type => "Private Key")

## Public Key -> takes hash as argument, requires :scrt_id, :type, optional :scrt_item_id, :path
secrets.download_secret_file(:scrt_id => 2345, :path => 'secrets/', :type => "Public Key")

## Attachment; only supports secrets with single attachment -> takes hash as argument, requires :scrt_id, :path, optional :scrt_item_id, :path
secrets.download_secret_file(:scrt_id => 2345, :path => 'secrets/', :type => "Attachment")

```

### Command Line

Zanzibar comes bundled with the [`zamioculcas`](http://en.wikipedia.org/wiki/Zamioculcas) command-line utility that can be used for fetching passwords and downloading keys from outside of Ruby.

`Zamioculcas` supports most actions provided by Zanzibar itself. Because it operates on the command-line, it can be used as part of a pipeline or within a bash script.

```bash
# if you don't pipe in a password, you will be prompted to enter one.
# this will download the private key from secret 1984 to the current directory
cat ./local-password | zamioculcas 1984 -s server.example.com -d example.com -t privatekey

ssh user@someremote -i ./private_key
```

## Contributing

1. Fork it ( https://github.com/Cimpress-MCP/zanzibar/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
