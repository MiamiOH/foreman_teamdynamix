desc <<-DESC.strip_heredoc.squish
  Scans existing hosts and creates or updates the asset in TeamDynamix.
    * If found, update the fields in the TeamDynamix asset.
    * If not found, create a TeamDynamix asset with desired fields.
    * If host does not have a teamdynamix_asset_id or it is deleted via backend, it creates a new asset.

  It could be run for all the hosts as:
    * rake hosts:sync_with_teamdynamix

  Or for specific hosts as (No space b/w hostnames):
    * rake hosts:sync_with_teamdynamix[hostname1,hostname2,..,hostnameX]
DESC
namespace :hosts do
  task :sync_with_teamdynamix, [:hostnames] => :environment do |_task, args|
    hostnames = Array.wrap(args.hostnames) + args.extras
    if hostnames.present?
      hosts = hostnames.collect { |hostname| Host.find_by(name: hostname) }
    else
      hosts = Host.all
    end
    error_count = 0

    hosts.each do |host|
      td_api = host.td_api
      asset_id = host.teamdynamix_asset_id
      action = asset_id && td_api.asset_exist?(asset_id) ? :update : :create
      begin
        td_api.send("#{action}_asset", host)
      rescue StandardError => e
        puts "\n\tS.No | hostname | action | result" if error_count.zero?
        error_count += 1
        puts "\t#{error_count} | #{host.name} | #{action} | Failed(#{e.message})"
      end
    end
  end
end
