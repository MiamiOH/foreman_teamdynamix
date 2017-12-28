require 'test_helper'

class TeamDynamixApiTest < ActiveSupport::TestCase
  let(:subject) { TeamDynamixApi.new }

  describe '#create_asset' do
    let(:host) { FactoryBot.create(:host, :managed) }

    it 'returns an asset' do
      assert_not_nil(subject.create_asset(host))
    end

    it 'raises error if API credentials are incorrect' do
      bk_url = SETTINGS[:team_dynamix][:api][:url]
      SETTINGS[:team_dynamix][:api][:url] = 'https://teamdynamix.com/bad/api'
      assert_raise do
        subject.create_asset(host)
      end
      SETTINGS[:team_dynamix][:api][:url] = bk_url
    end
  end

  describe '#auth_token' do
    it 'returns a bearer token if credentials are correct' do
      assert_not_nil(subject.send(:auth_token))
    end

    it 'raises error for invalid credentials' do
      bk_username = SETTINGS[:team_dynamix][:api][:username]
      SETTINGS[:team_dynamix][:api][:username] = 'bad'
      assert_raises_with_message(RuntimeError, 'Forbidden') do
        subject.send(:auth_token)
      end
      SETTINGS[:team_dynamix][:api][:username] = bk_username
    end
  end
end