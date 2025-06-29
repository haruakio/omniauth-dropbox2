# OmniAuth Dropbox Strategy

This gem provides a simple way to authenticate to Dropbox using OmniAuth with OAuth2.

Modified original strategy to adapt the Dropbox's short live token policy from 2020 Oct.

**Version 2.0+** is compatible with **OmniAuth 2.x** and includes mandatory CSRF protection.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-dropbox2', '~> 2.0'
```

For Rails applications, you'll also need CSRF protection:

```ruby
gem 'omniauth-rails_csrf_protection', '~> 1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-dropbox2

## Usage

### Basic Configuration

```ruby
# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :dropbox, ENV['DROPBOX_CLIENT_ID'], ENV['DROPBOX_CLIENT_SECRET'], 
           token_access_type: 'offline'
end
```

### With Devise gem

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  config.omniauth :dropbox, 
                  Rails.application.credentials.dig(:dropbox, :client_id), 
                  Rails.application.credentials.dig(:dropbox, :client_secret), 
                  token_access_type: 'offline'
end
```

### Token Access Types

- `offline` (default): Provides a refresh token for long-term access
- `online`: Provides a short-lived access token

### CSRF Protection (OmniAuth 2.x Requirement)

**Important**: OmniAuth 2.x requires CSRF protection. Authentication requests must be POST requests.

#### In your views:

```erb
<!-- Instead of a regular link -->
<%= link_to "Sign in with Dropbox", "/auth/dropbox", method: :post %>

<!-- Or using a form -->
<%= form_with url: "/auth/dropbox", method: :post, local: true do |form| %>
  <%= form.submit "Sign in with Dropbox" %>
<% end %>
```

#### Using JavaScript:

```javascript
// Create a form and submit it
function authenticateWithDropbox() {
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '/auth/dropbox';
  document.body.appendChild(form);
  form.submit();
}
```

### User Information

The strategy provides the following user information:

```ruby
# In your callback handler
def omniauth_callback
  auth = request.env['omniauth.auth']
  
  # User ID
  user_id = auth.uid  # Dropbox account_id
  
  # User info
  name = auth.info.name    # Display name
  email = auth.info.email  # Email address (if available)
  
  # Raw Dropbox user data
  raw_info = auth.extra.raw_info
end
```

## Development

### Running Tests

```bash
bundle install
bundle exec rspec
```

### Building the Gem

```bash
bundle exec rake build
```

## Migration from 1.x to 2.x

1. Update your Gemfile to use version `~> 2.0`
2. Add `omniauth-rails_csrf_protection` gem for Rails applications
3. Change all authentication links/buttons to use POST requests instead of GET
4. Update OmniAuth configuration if needed

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This gem is available as open source under the terms of the [MIT License](LICENSE.txt).
