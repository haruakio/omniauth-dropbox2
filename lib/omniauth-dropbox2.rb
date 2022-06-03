require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Dropbox < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, 'dropbox'

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options,
             site: 'https://api.dropbox.com/2',
             authorize_url: 'https://www.dropbox.com/oauth2/authorize',
             token_url: 'https://api.dropbox.com/oauth2/token',
             connection_opts: { headers: { user_agent: 'Omniauth-Dropbox2', accept: 'application/json', content_type: 'application/json' } }

      option :authorize_options, %i[token_access_type]

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['account_id'] }

      info do
        {
          name: raw_info['name']['display_name']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end
          params[:token_access_type] = 'offline' if params['token_access_type'].nil?
        end
      end

      def raw_info
        @raw_info ||= access_token.post('users/get_current_account', body: nil.to_json).parsed
      end

      def callback_url
        # If redirect_uri is configured in token_params, use that
        # value.
        token_params.to_hash(symbolize_keys: true)[:redirect_uri] || super
      end

      def query_string
        # This method is called by callback_url, only if redirect_uri
        # is omitted in token_params.
        if request.params['code']
          # If this is a callback, ignore query parameters added by
          # the provider.
          ''
        else
          super
        end
      end
    end
  end
end
