require 'deface'
module ForemanTeamdynamix
  class Engine < ::Rails::Engine
    engine_name 'foreman_teamdynamix'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]

    initializer 'foreman_teamdynamix.load_app_instance_data' do |app|
      if ForemanTeamdynamix::Engine.paths['db/migrate'].existent
        app.config.paths['db/migrate'].concat(ForemanTeamdynamix::Engine.paths['db/migrate'].to_a)
      end
    end

    initializer 'foreman_teamdynamix.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_teamdynamix do
        requires_foreman '>= 1.7'

        # Add permissions
        security_block :foreman_teamdynamix do
          ps = permission :view_hosts,
                          { :hosts => [:teamdynamix] },
                          :resource_type => 'Host'
          pn = ps.pop
          po = ps.detect { |p| p.name == :view_hosts }
          po.actions << pn.actions.first
        end
      end
    end

    # Include concerns in this config.to_prepare block
    config.to_prepare do
      begin
        HostsHelper.send(:include, ForemanTeamdynamix::HostsHelperExtensions)
        ::HostsController.send(:include, ForemanTeamdynamix::HostsControllerExtensions)
        ::Host::Managed.send(:include, ForemanTeamdynamix::HostExtensions)
      rescue StandardError => e
        Rails.logger.warn "ForemanTeamdynamix: skipping engine hook (#{e})"
      end
    end

    initializer 'foreman_teamdynamix.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_teamdynamix'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
