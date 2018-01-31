require 'test_plugin_helper'
# rubocop:disable Metrics/ClassLength
class TeamdynamixApiTest < ActiveSupport::TestCase
  # rubocop:enable Metrics/ClassLength
  let(:subject) { TeamdynamixApi.instance }
  let(:api_config) { SETTINGS[:teamdynamix][:api] }
  let(:app_id) { api_config[:id] }
  let(:api_url) { api_config[:url] }
  let(:host) { FactoryBot.build(:host, :managed) }
  let(:auth_payload) { { username: api_config[:username], password: api_config[:password] }.to_json }
  let(:dummy_token) { 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfbmFtZSI6InR5YWdpbkBtaWFtaW9oLmVkdSIsImlzcyI6IlREIiwiYXVkIjoiaHR0cHM6Ly93d3cudGVhbWR5bmFtaXguY29tLyIsImV4cCI6MTUxNzA2OTU1OSwibmJmIjoxNTE2OTgzMTU5fQ.PkvKbYQCV-hY7_ni4-Zg3qJARBagSzz99fclBYyxxas' }
  let(:sample_asset) { FakeTeamdynamixApi.new.get_asset }
  let(:sample_asset_id) { sample_asset['ID'].to_s }
  let(:host_name) { 'delete.foreman_teamdynamix.com' }
  let(:get_asset_path) { api_url + '/' + app_id + '/assets/' + sample_asset_id }
  before do
    stub_request(:post, api_url + '/auth')
      .with(body: auth_payload,
            headers: { 'Content-Type' => 'application/json' })
      .to_return(status: 200, body: dummy_token)
    host.name = host_name
  end

  describe '#retire_asset' do
    let(:retire_status_id) { 642 }
    before do
      subject.stubs(:get_asset).returns(sample_asset)
      SETTINGS[:teamdynamix][:api][:delete] = { StatusID: retire_status_id }
    end
    describe 'valid request' do
      let(:retired_asset) { sample_asset.merge('StatusID' => retire_status_id) }
      let(:retire_path) { api_url + '/' + app_id + '/assets/' + sample_asset_id }
      before do
        stub_request(:post, retire_path)
          .with(headers: { 'Authorization' => 'Bearer ' + dummy_token,
                           'Content-Type' => 'application/json' })
          .to_return(status: 200, body: retired_asset.to_json)
      end
      it 'marks the asset retired in Team Dynamix' do
        assert_nothing_raised do
          asset = subject.retire_asset(sample_asset_id)
          assert_equal(asset['StatusID'], retire_status_id)
        end
      end
    end
  end

  describe '#create_asset' do
    let(:create_status_id) { 641 }
    let(:create_path) { api_url + '/' + app_id + '/assets' }
    let(:default_attributes) do
      [{ ID: 11_632, Name: 'mu.ci.Description', Value: "Foreman host #{host_name} created by ForemanTeamdynamix plugin" },
       { ID: 11_634, Name: 'mu.ci.Lifecycle Status', Value: 26_190 }]
    end
    let(:create_payload) do
      { AppID: app_id,
        SerialNumber: host_name,
        Name: host_name,
        StatusID: create_status_id,
        Attributes: default_attributes }
    end
    before do
      SETTINGS[:teamdynamix][:api][:create] = { StatusID: create_status_id }
    end
    context 'Valid Request' do
      let(:asset_ci_desc_expectation) { "Foreman host #{host.fqdn} created by ForemanTeamdynamix plugin" }
      before do
        stub_request(:post, create_path)
          .with(headers: { 'Authorization' => 'Bearer ' + dummy_token,
                           'Content-Type' => 'application/json' },
                body: create_payload)
          .to_return(status: 200, body: sample_asset.to_json)
      end
      it 'successfully creates an asset and return it' do
        asset = subject.create_asset(host)
        assert_not_nil(asset['ID'])
        assert_equal(asset['SerialNumber'], host.name)
        assert_equal(asset['AppID'].to_s, app_id.to_s)
        assert_equal(asset['StatusID'], SETTINGS[:teamdynamix][:api][:create][:StatusID])
        asset_ci_desc = asset['Attributes'].select { |attrib| attrib['Name'] == 'mu.ci.Description' }[0]['Value']
        assert_equal(asset_ci_desc, asset_ci_desc_expectation)
        asset_ci_lifecycle_status = asset['Attributes'].select { |attrib| attrib['Name'] == 'mu.ci.Lifecycle Status' }[0]['Value']
        assert_equal(asset_ci_lifecycle_status.to_s, subject.send(:lifecycle_status).to_s)
      end
    end

    context 'Invalid Request: missing SerialNumber' do
      # rubocop:disable Style/StringLiterals
      let(:error_body) { "Name or serial number must be provided for asset records" }
      let(:error) { { status: "400", msg: "", body: error_body }.to_json }
      # rubocop:enable Style/StringLiterals
      before do
        stub_request(:post, create_path)
          .with(headers: { 'Authorization' => 'Bearer ' + dummy_token,
                           'Content-Type' => 'application/json' },
                body: create_payload)
          .to_return(status: 400, body: error_body)
      end
      it 'raises error with status 400 for invalid payload' do
        assert_raises_with_message(RuntimeError, error) do
          subject.create_asset(host)
        end
      end
    end
  end

  describe '#request_token' do
    describe 'valida credentials' do
    end
    it 'returns a bearer token if credentials are correct' do
      assert_not_nil(subject.send(:request_token))
    end

    describe 'invalid credentials' do
      # rubocop:disable Style/StringLiterals
      let(:error_body) { "Invalid username or password." }
      let(:error) { { status: "403", msg: "", body: error_body }.to_json }
      # rubocop:enable Style/StringLiterals
      before do
        stub_request(:post, api_url + '/auth')
          .with(body: auth_payload)
          .to_return(status: 403, body: error_body)
      end
      it 'raises error with status 403' do
        assert_raises_with_message(RuntimeError, error) do
          subject.send(:request_token)
        end
      end
    end
  end

  describe '#get_asset' do
    context 'Valid Request' do
      before do
        stub_request(:get, get_asset_path)
          .with(headers: { 'Authorization' => 'Bearer ' + dummy_token })
          .to_return(status: 200, body: sample_asset.to_json)
      end
      it 'returns asset json' do
        assert_equal(subject.get_asset(sample_asset_id), sample_asset)
      end
    end
  end
end
