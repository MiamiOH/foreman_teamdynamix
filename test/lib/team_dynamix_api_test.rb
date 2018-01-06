require 'test_helper'
class TeamDynamixApiTest < ActiveSupport::TestCase
  let(:subject) { TeamDynamixApi.new }
  let(:app_id) { SETTINGS[:team_dynamix][:api][:id] }
  let(:host) { FactoryBot.build(:host, :managed) }

  describe '#create_asset' do
    context 'Valid Request' do
      let(:asset_ci_desc_expectation) { "Foreman host #{host.fqdn} created by ForemanTeamdynamix plugin" }
      it 'successfully creates an asset and return it' do
        asset = subject.create_asset(host)
        assert_not_nil(asset['ID'])
        assert_equal(asset['SerialNumber'], host.name)
        assert_equal(asset['AppID'].to_s, app_id.to_s)
        assert_equal(asset['StatusID'], SETTINGS[:team_dynamix][:api][:create][:StatusID])
        asset_ci_desc = asset['Attributes'].select { |attrib| attrib['Name'] == 'mu.ci.Description' }[0]['Value']
        assert_equal(asset_ci_desc, asset_ci_desc_expectation)
        asset_ci_lifecycle_status = asset['Attributes'].select { |attrib| attrib['Name'] == 'mu.ci.Lifecycle Status' }[0]['Value']
        assert_equal(asset_ci_lifecycle_status.to_s, subject.send(:get_lifecycle_status).to_s)
      end
    end

    context 'Invalid Request: missing SerialNumber' do
      let(:owning_customer_id) { 'TestOwningCustomerID' }
      let(:bad_payload) { { AppID: app_id, OwningCustomerID: owning_customer_id } }
      let(:error_body) { { "ID" => -1, "Message" => "Name or serial number must be provided for asset records." } }
      let(:error) { { "status": "400", "msg": "Bad Request", "body": error_body }.to_json }
      before do
        TeamDynamixApi.any_instance.stubs(:create_asset_payload).returns(bad_payload)
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
