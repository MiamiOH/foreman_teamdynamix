module ForemanTeamdynamix
  # Example: Plugin's HostsController inherits from Foreman's HostsController
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    def team_dynamix
      find_resource
      render partial: 'foreman_teamdynamix/hosts/team_dynamix', :locals => { :host => @host }
    end

    private

    def action_permission
      if params[:action] == 'team_dynamix'
        :view
      else
        super
      end
    end
  end
end
