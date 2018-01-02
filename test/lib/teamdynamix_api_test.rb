require 'test_helper'

class TeamdynamixApiTest < ActiveSupport::TestCase
  let(:subject) { TeamdynamixApi.new }
  let(:app_id) { SETTINGS[:teamdynamix][:api][:id] }
  let(:app_name) { 'Assets/CIs' }
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:owning_customer_id) { 'TestOwningCustomerID' }
  let(:serial_number) { 'test_host_serial_num' }
  # rubocop:disable Style/StringLiterals

  describe '#create_asset' do
    context 'Valid Request' do
      let(:expected_asset) { { AppID: app_id, OwningCustomerID: owning_customer_id, SerialNumber: serial_number } }
      before do
        SETTINGS[:teamdynamix][:api][:status_id] = 641
      end
      it 'returns asset json' do
        assert_equal(subject.create_asset(host), expected_asset)
      end
    end

    context 'Invalid Request: missing SerialNumber' do
      let(:bad_payload) { { AppID: app_id, OwningCustomerID: owning_customer_id } }
      let(:error_body) { { "ID" => -1, "Message" => "Name or serial number must be provided for asset records." } }
      let(:error) { { "status": "400", "msg": "Bad Request", "body": error_body }.to_json }
      before do
        TeamdynamixApi.any_instance.stubs(:create_asset_payload).returns(bad_payload)
      end
      it 'raises error with status 400 for invalid payload' do
        assert_raises_with_message(RuntimeError, error) do
          subject.create_asset(host)
        end
      end
    end
  end

  describe '#auth_token' do
    it 'returns a bearer token if credentials are correct' do
      assert_not_nil(subject.send(:auth_token))
    end

    describe 'invalid credentials' do
      let(:bk_username) { SETTINGS[:teamdynamix][:api][:username] }
      let(:error_body) { "Invalid username or password." }
      let(:error) { { "status": "403", "msg": "Forbidden", "body": error_body }.to_json }
      before do
        bk_username
        SETTINGS[:teamdynamix][:api][:username] = 'incorrect_username'
      end
      after do
        SETTINGS[:teamdynamix][:api][:username] = bk_username
      end
      it 'raises error with status 403' do
        assert_raises_with_message(RuntimeError, error) do
          subject.send(:auth_token)
        end
      end
    end
  end

  describe '#search_asset' do
    context 'Valid Request' do
      let(:asset_id) { '10175' }
      let(:search_params) { { AppID: app_id, ID: asset_id } }
      it 'returns asset json' do
        assert_not_nil(subject.search_asset(search_params))
      end
    end
  end

  describe '#get_asset' do
    context 'Valid Request' do
      let(:asset_id) { '10175' }
      it 'returns asset json' do
        assert_not_nil(subject.get_asset(asset_id))
      end
    end
  end
end
