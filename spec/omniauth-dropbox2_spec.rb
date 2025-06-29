require 'spec_helper'

describe 'OmniAuth::Dropbox2' do
  it 'loads the strategy class' do
    expect(OmniAuth::Strategies::Dropbox).to be_a(Class)
  end

  it 'inherits from OmniAuth::Strategies::OAuth2' do
    expect(OmniAuth::Strategies::Dropbox.superclass).to eq(OmniAuth::Strategies::OAuth2)
  end

  it 'has the correct strategy name' do
    strategy = OmniAuth::Strategies::Dropbox.new({})
    expect(strategy.options.name).to eq('dropbox')
  end
end