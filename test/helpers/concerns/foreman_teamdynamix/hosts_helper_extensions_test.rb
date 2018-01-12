require 'test_plugin_helper'

class HostsHelperExtensionsTest < ActiveSupport::TestCase
  include ForemanTeamdynamix::HostsHelperExtensions

  let(:os) { FactoryBot.create(:operatingsystem, name: 'CentOS', major: '7', type: 'Redhat') }
  let(:arch) { FactoryBot.create(:architecture) }
  # rubocop:disable Metrics/LineLength
  let(:host) { FactoryBot.create(:host, id: 'foreman.example.com', mac: '00:00:00:00:00:00', ip: '127.0.0.1', operatingsystem: os, arch: arch) }
  # rubocop:enable Metrics/LineLength
  let(:expected_fields) {}

  describe '#teamdynamix_fields(host)' do
    test 'returns fields as expected' do
      assert_equal teamdynamix_fields(host), expected_fields
    end
  end

  describe '#td_tab_title' do
    title_orig = SETTINGS[:teamdynamix][:title]
    test 'returns correct title' do
      assert_equal td_tab_title, title_orig
    end

    test 'settings title is not present' do
      SETTINGS[:teamdynamix][:title] = nil
      assert_equal td_tab_title, 'Team Dynamix'
      SETTINGS[:teamdynamix][:title] = title_orig
    end
  end
end
