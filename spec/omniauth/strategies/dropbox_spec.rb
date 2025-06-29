require 'spec_helper'

describe OmniAuth::Strategies::Dropbox do
  subject do
    OmniAuth::Strategies::Dropbox.new({})
  end

  before(:each) do
    allow(subject).to receive(:request) {
      double('Request', params: {}, cookies: {}, env: {})
    }
  end

  describe '#client_options' do
    it 'has correct site' do
      expect(subject.client.site).to eq('https://api.dropbox.com/2')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('https://www.dropbox.com/oauth2/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('https://api.dropbox.com/oauth2/token')
    end

    it 'has correct user agent' do
      expect(subject.client.connection.headers['User-Agent']).to eq('Omniauth-Dropbox2')
    end
  end

  describe '#authorize_params' do
    it 'includes token_access_type' do
      expect(subject.authorize_params).to be_a(Hash)
      expect(subject.authorize_params[:token_access_type]).to eq('offline')
    end

    it 'allows override of token_access_type' do
      allow(subject).to receive(:request) {
        double('Request', params: {'token_access_type' => 'online'}, cookies: {}, env: {})
      }
      expect(subject.authorize_params[:token_access_type]).to eq('online')
    end

    it 'ignores nil token_access_type parameter' do
      allow(subject).to receive(:request) {
        double('Request', params: {'token_access_type' => nil}, cookies: {}, env: {})
      }
      expect(subject.authorize_params[:token_access_type]).to eq('offline')
    end

    it 'ignores empty token_access_type parameter' do
      allow(subject).to receive(:request) {
        double('Request', params: {'token_access_type' => ''}, cookies: {}, env: {})
      }
      expect(subject.authorize_params[:token_access_type]).to eq('offline')
    end
  end

  describe '#uid' do
    before(:each) do
      allow(subject).to receive(:raw_info) { {'account_id' => '123456789'} }
    end

    it 'returns the account_id from raw_info' do
      expect(subject.uid).to eq('123456789')
    end
  end

  describe '#info' do
    context 'with complete user data' do
      before(:each) do
        allow(subject).to receive(:raw_info) {
          {
            'name' => {'display_name' => 'John Doe'},
            'email' => 'john@example.com'
          }
        }
      end

      it 'returns the display name' do
        expect(subject.info[:name]).to eq('John Doe')
      end

      it 'returns the email' do
        expect(subject.info[:email]).to eq('john@example.com')
      end
    end

    context 'with incomplete user data' do
      before(:each) do
        allow(subject).to receive(:raw_info) { {} }
      end

      it 'handles missing name gracefully' do
        expect(subject.info[:name]).to be_nil
      end

      it 'handles missing email gracefully' do
        expect(subject.info[:email]).to be_nil
      end
    end
  end

  describe '#extra' do
    before(:each) do
      allow(subject).to receive(:raw_info) { {'account_id' => '123456789'} }
    end

    it 'returns the raw_info in extra' do
      expect(subject.extra['raw_info']).to eq({'account_id' => '123456789'})
    end
  end

  describe '#raw_info' do
    let(:access_token) { double('AccessToken') }
    let(:response) { double('Response') }

    before(:each) do
      allow(subject).to receive(:access_token) { access_token }
    end

    context 'successful API call' do
      before(:each) do
        allow(access_token).to receive(:post).with('users/get_current_account', body: nil.to_json) { response }
        allow(response).to receive(:parsed) { {'account_id' => '123456789'} }
      end

      it 'makes a POST request to users/get_current_account' do
        expect(access_token).to receive(:post).with('users/get_current_account', body: nil.to_json)
        subject.raw_info
      end

      it 'returns the parsed response' do
        expect(subject.raw_info).to eq({'account_id' => '123456789'})
      end

      it 'caches the result' do
        expect(access_token).to receive(:post).once
        2.times { subject.raw_info }
      end
    end

    context 'failed API call' do
      before(:each) do
        allow(access_token).to receive(:post).and_raise(StandardError.new('API Error'))
        allow(subject).to receive(:log)
      end

      it 'logs the error' do
        expect(subject).to receive(:log).with(:error, 'Failed to fetch user info from Dropbox: API Error')
        subject.raw_info
      end

      it 'returns empty hash on error' do
        expect(subject.raw_info).to eq({})
      end
    end
  end

  describe '#callback_url' do
    it 'uses redirect_uri from token_params if present' do
      token_params_double = double('TokenParams')
      allow(token_params_double).to receive(:respond_to?).with(:to_hash).and_return(true)
      allow(token_params_double).to receive(:to_hash).and_return({'redirect_uri' => 'http://example.com/callback'})
      allow(subject).to receive(:token_params).and_return(token_params_double)
      expect(subject.callback_url).to eq('http://example.com/callback')
    end

    it 'falls back to super if no redirect_uri in token_params' do
      token_params_double = double('TokenParams')
      allow(token_params_double).to receive(:respond_to?).with(:to_hash).and_return(true)
      allow(token_params_double).to receive(:to_hash).and_return({})
      allow(subject).to receive(:token_params).and_return(token_params_double)
      allow(subject).to receive(:full_host) { 'http://example.com' }
      allow(subject).to receive(:script_name) { '' }
      allow(subject).to receive(:callback_path) { '/auth/dropbox/callback' }
      allow(subject).to receive(:request) {
        double('Request', params: {}, cookies: {}, env: {}, query_string: '')
      }
      expect(subject.callback_url).to include('/auth/dropbox/callback')
    end
  end

  describe '#query_string' do
    context 'during callback' do
      before(:each) do
        allow(subject).to receive(:request) {
          double('Request', params: {'code' => 'auth_code'}, cookies: {}, env: {})
        }
      end

      it 'returns empty string during callback to ignore provider query params' do
        expect(subject.query_string).to eq('')
      end
    end

    context 'during authorization' do
      before(:each) do
        allow(subject).to receive(:request) {
          double('Request', params: {}, cookies: {}, env: {})
        }
      end

      it 'returns the normal query string' do
        allow(subject).to receive(:request) {
          double('Request', params: {}, cookies: {}, env: {}, query_string: 'test=value')
        }
        expect(subject.send(:query_string)).to eq('?test=value')
      end
    end
  end
end