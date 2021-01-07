desc <<~DESC.squish
  Scans existing hosts and creates or updates the asset in TeamDynamix.
    * If found, update the fields in the TeamDynamix asset.
    * If not found, create a TeamDynamix asset with desired fields.

  It could be run for all the hosts as:
    * rake teamydynamix:sync:hosts

  Available options:
    * where => where string for limiting host query
    * limit => limit for limiting host query

DESC
namespace :teamdynamix do
  namespace :sync do
    task :hosts => :environment do
      errors = []
      created = 0
      updated_search = 0
      updated_id = 0

      console_user = User.find_by(login: 'foreman_console_admin')
      User.current = console_user

      hosts = Host
      hosts = hosts.where(ENV['where']) if ENV['where']
      hosts = hosts.limit(ENV['limit']) if ENV['limit']

      hosts.all.each do |h|
        if h.create_or_update_teamdynamix_asset(true)
          case h.teamdynamix_asset_status
          when :created then created += 1
          when :updated_search then updated_search += 1
          when :updated_id then updated_id += 1
          end
        else
          errors.push("Could not save host: #{h.name} (#{h.id}):\n  #{h.errors.full_messages.join("\n  ")}")
        end
        sleep(1.5) # TD only allows 60 api calls per minute
      end
      puts "Assets created: #{created}" unless created.eql?(0)
      puts "Assets updated from serial search: #{updated_search}" unless updated_search.eql?(0)
      puts "Assets updated from ID: #{updated_id}" unless updated_id.eql?(0)
      puts "Errors:\n#{errors.join("\n")}" unless errors.empty?
    end
  end
end
