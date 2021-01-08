require 'test_plugin_helper'

class HostsControllerTest < ActionController::TestCase
  let(:td_tab_title) { SETTINGS[:teamdynamix][:title] || 'Team Dynamix' }
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:td_api) { FakeTeamdynamixApi.new }
  before do
    Host::Managed.any_instance.stubs(:td_api).returns(td_api)
  end
  # rubocop:disable Style/StringLiterals, Rails/HttpPositionalArguments
  describe 'Given host exist as an asset in TeamDynamix' do
    describe 'when TeamDynamix asset attributes are configured' do
      describe 'GET hosts/show' do
        test 'loads the TeamDynamix tab' do
          get :show, { :id => host.name }, set_session_user
          assert_includes response.headers['Content-Type'], 'text/html'
          assert_includes response.body, "<ul id=\"host-show-tabs\""
          assert_equal(200, response.status)
          assert_includes response.body, "<li><a href=\"#teamdynamix\" data-toggle=\"tab\">#{td_tab_title}</a></li>"
          assert_includes response.body,
                          "<div id=\"teamdynamix\" class=\"tab-pane\" data-ajax-url=\"/hosts/#{host.name}/teamdynamix\" data-on-complete=\"onContentLoad\">"
        end
        test 'TeamDynamix tab contains configured asset attributes' do
          skip
          get hosts_teamdynamix_path, { :id => host.name }, set_session_user
          assert_template 'foreman_teamdynamix'
        end
      end
    end
  end
  # rubocop:enable Style/StringLiterals, Rails/HttpPositionalArguments
end
