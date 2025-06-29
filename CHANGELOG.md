# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-06-29

### Changed
- **BREAKING**: Updated OmniAuth dependency from `~> 1.0` to `~> 2.0`
- **BREAKING**: Added `omniauth-oauth2 ~> 1.8` dependency for compatibility
- Updated strategy implementation for OmniAuth 2.x compatibility
- Improved error handling in `raw_info` method with proper logging
- Enhanced `info` method to include email field and use safer `dig` method for nested hash access
- Improved `callback_url` method to handle both string and symbol keys

### Added
- Comprehensive RSpec test suite with 26 test cases
- Test coverage for all strategy methods and error conditions
- RSpec configuration and development dependencies
- Rake task for running tests
- Better error handling and logging throughout the strategy

### Security
- Updated to OmniAuth 2.x which includes mandatory CSRF protection
- Enhanced error handling to prevent information leakage

### Notes
- This is a major version upgrade due to OmniAuth 2.x compatibility requirements
- Applications using this gem will need to implement CSRF protection as required by OmniAuth 2.x
- For Rails applications, add the `omniauth-rails_csrf_protection ~> 1.0` gem
- Authentication requests must now be POST requests instead of GET requests

## [1.0.6] - Previous Release
- Last version supporting OmniAuth 1.x