require 'test_helper'

class TeamDynamixApiTest < ActiveSupport::TestCase
  let(:subject) { TeamDynamixApi.new }
  let(:app_id) { SETTINGS[:team_dynamix][:api][:id] }
  let(:app_name) { 'Assets/CIs' }
  let(:owning_customer_id) { 'TestOwningCustomerID' }
  let(:serial_number) { 'test_host_serial_num' }
  # rubocop:disable Style/StringLiterals
  describe '#create_asset' do
    let(:host) { FactoryBot.create(:host, :managed) }

    context 'Valid Request' do
      let(:expected_asset) { { ID: '', AppID: app_id, OwningCustomerID: owning_customer_id, SerialNumber: serial_number } }
      let(:status_id) { '300' }
      let(:good_payload) { { StatusID: status_id, AppID: app_id, OwningCustomerID: owning_customer_id, SerialNumber: serial_number }.to_json }
      before do
        TeamDynamixApi.any_instance.stubs(:payload_to_create_asset).returns(good_payload)
      end
      it 'returns asset json' do
        assert_equal(subject.create_asset(host), expected_asset)
      end
    end

    context 'Invalid Request: Invalid Status' do
      let(:bad_payload) { { StatusID: 1, AppID: app_id, OwningCustomerID: owning_customer_id, SerialNumber: serial_number }.to_json }
      let(:error_body) { { "ID" => -1, "Message" => "The specified status is invalid." } }
      let(:error) { { "status": "400", "msg": "Bad Request", "body": error_body }.to_json }
      before do
        TeamDynamixApi.any_instance.stubs(:payload_to_create_asset).returns(bad_payload)
      end
      it 'raises error with status 400 for invalid payload' do
        assert_raises_with_message(RuntimeError, error) do
          subject.create_asset(host)
        end
      end
    end

    context 'Invalid Request: missing StatusID' do
      let(:bad_payload) { { AppID: app_id, OwningCustomerID: owning_customer_id, SerialNumber: serial_number }.to_json }
      let(:error_body) { { "ID" => -1, "Message" => "Status is required." } }
      let(:error) { { "status": "400", "msg": "Bad Request", "body": error_body }.to_json }
      before do
        TeamDynamixApi.any_instance.stubs(:payload_to_create_asset).returns(bad_payload)
      end
      it 'raises error with status 400 for invalid payload' do
        assert_raises_with_message(RuntimeError, error) do
          subject.create_asset(host)
        end
      end
    end

    context 'Invalid Request: missing SerialNumber' do
      let(:bad_payload) { { AppID: app_id, OwningCustomerID: owning_customer_id }.to_json }
      let(:error_body) { { "ID" => -1, "Message" => "Name or serial number must be provided for asset records." } }
      let(:error) { { "status": "400", "msg": "Bad Request", "body": error_body }.to_json }
      before do
        TeamDynamixApi.any_instance.stubs(:payload_to_create_asset).returns(bad_payload)
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
      let(:bk_username) { SETTINGS[:team_dynamix][:api][:username] }
      let(:error_body) { "Invalid username or password." }
      let(:error) { { "status": "403", "msg": "Forbidden", "body": error_body }.to_json }
      before do
        bk_username
        SETTINGS[:team_dynamix][:api][:username] = 'incorrect_username'
      end
      after do
        SETTINGS[:team_dynamix][:api][:username] = bk_username
      end
      it 'raises error with status 403' do
        assert_raises_with_message(RuntimeError, error) do
          subject.send(:auth_token)
        end
      end
    end
  end
end
