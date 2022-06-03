# OmniAuth Dropbox Strategy

This gem provides a simple way to authenticate to Dropbox using OmniAuth with OAuth2.

Modified original strategy to adapt the Dropbox's short live token policy from 2020 Oct

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-dropbox2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-dropbox2

## Usage

### with Devise gem
```
# config/initializers/devise.rb
  # ==> OmniAuth
  config.omniauth :dropbox, Rails.application.credentials[:dropbox][:client_id], Rails.application.credentials[:dropbox][:client_secret], token_access_type: 'offline'
```
Default token_access_type is `offline`. If you'd like to get `online` token, change the last parameter as `, token_access_type: 'online'` 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
