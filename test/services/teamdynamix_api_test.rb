require 'test_helper'

class TeamdynamixApiTest < ActiveSupport::TestCase
  let(:subject) { TeamdynamixApi.new }
  let(:app_id) { SETTINGS[:teamdynamix][:api][:id] }
  let(:host) { FactoryBot.build(:host, :managed) }
  let(:host_name) { 'delete.foreman_teamdynamix.com' }
  before do
    host.name = host_name
  end

  describe '#retire_asset' do
    let(:status_id) { 642 }
    before do
      SETTINGS[:teamdynamix][:api][:delete] = { StatusID: status_id }
    end
    let(:td_asset_id) do
      test_assets = subject.search_asset({}).select do |asset|
        asset['Name'] == host_name
      end
      test_assets = [subject.create_asset(host)] if test_assets.blank?
      test_assets.first['ID']
    end
    it 'marks the asset retired in Team Dynamix' do
      assert_nothing_raised do
        asset = subject.retire_asset(td_asset_id)
        assert_equal(asset['StatusID'], status_id)
      end
    end
  end

  describe '#create_asset' do
    context 'Valid Request' do
      let(:asset_ci_desc_expectation) { "Foreman host #{host.fqdn} created by ForemanTeamdynamix plugin" }
      it 'successfully creates an asset and return it' do
        skip()
        asset = subject.create_asset(host)
        assert_not_nil(asset['ID'])
        assert_equal(asset['SerialNumber'], host.name)
        assert_equal(asset['AppID'].to_s, app_id.to_s)
        assert_equal(asset['StatusID'], SETTINGS[:teamdynamix][:api][:create][:StatusID])
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
