module ForemanTeamdynamix
  # Example: Plugin's HostsController inherits from Foreman's HostsController
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    def teamdynamix
      find_resource
      render partial: 'foreman_teamdynamix/hosts/teamdynamix', :locals => { :host => @host }
    rescue ActionView::Template::Error => exception
      process_ajax_error exception, 'fetch teamdynamix tab information'
    end

    private

    def action_permission
      if params[:action] == 'teamdynamix'
        :view
      else
        super
      end
    end
  end
end
