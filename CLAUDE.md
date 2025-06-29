# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an OmniAuth strategy gem for Dropbox OAuth2 authentication. It's a Ruby gem that provides integration between Rails applications and Dropbox's OAuth2 API, specifically adapted for Dropbox's short-lived token policy implemented in October 2020.

**Version 2.0+** is compatible with OmniAuth 2.x and includes mandatory CSRF protection requirements.

## Code Architecture

The gem follows standard Ruby gem structure:

- `lib/omniauth-dropbox2.rb` - Main strategy implementation extending `OmniAuth::Strategies::OAuth2`
- `lib/omniauth-dropbox2/version.rb` - Version definition
- `omniauth-dropbox2.gemspec` - Gem specification with dependencies
- `spec/` - RSpec test suite with comprehensive test coverage

The core strategy class is `OmniAuth::Strategies::Dropbox` which handles:
- OAuth2 authorization flow with Dropbox API
- Token access type configuration (online/offline)
- User info retrieval via Dropbox API with error handling
- Callback URL handling with custom query string logic
- Enhanced security and error logging for OmniAuth 2.x compatibility

## Common Development Commands

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run tests with coverage
bundle exec rspec --format documentation

# Build the gem
bundle exec rake build

# Install the gem locally
bundle exec rake install

# Release the gem (if you have permissions)
bundle exec rake release

# Run default rake task (tests)
bundle exec rake
```

## Key Implementation Details

- **OmniAuth 2.x Compatibility**: Updated to `omniauth ~> 2.0` with CSRF protection support
- **Dependencies**: Requires `omniauth-oauth2 ~> 1.8` for OAuth2 functionality
- **Token Access**: Default token access type is 'offline' for refresh token support
- **API Integration**: Uses Dropbox API v2 endpoints with proper error handling
- **Security**: Enhanced error logging and safe data access using `dig` method
- **Callback Handling**: Custom callback URL handling to strip provider-added query parameters
- **User Identification**: Uses `account_id` field from Dropbox API as primary identifier
- **Testing**: Comprehensive RSpec test suite with 26 test cases covering all functionality

## OmniAuth 2.x Migration Notes

- Authentication requests must be POST requests (not GET)
- Rails applications need `omniauth-rails_csrf_protection ~> 1.0` gem
- CSRF protection is mandatory for security compliance
- Strategy includes enhanced error handling and logging