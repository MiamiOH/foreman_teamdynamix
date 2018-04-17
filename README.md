# foreman_teamdynamix
A Foreman Plugin for TeamDynamix. It manages a host's life cycle as a corresponding Asset in TeamDynamix.

## Installation

To install foreman_teamdynamix require it in your gem file by adding the line.
```
gem 'foreman_teamdynamix'
```
Then update foreman to include the gem with the command.
```
bundle update foreman_teamdynamix
```

## Configuration
To setup the configuration file create a new file named 'foreman_teamdynamix.yaml' at the location /etc/foreman/plugins/

If there is no configuration file then the tab should not appear on the detailed hosts screen, but if there is one and it is empty then it will appear without any fields.

Example Configuration

```
---
:teamdynamix:
  :api:
    :url: https://miamioh.teamdynamix.com/SBTDWebApi/api
    :appId: 741
    :username: 'xxxxxx'
    :password: 'xxxxxx'
    :create:
      :StatusID: 641
      :OwningCustomerName: foreman_teamdynamix_plugin_test
      :Attributes:
      - name: mu.ci.Lifecycle Status
        id: 11634
        value: 26190
      - name: mu.ci.Description
        id: 11632
        value: "created by ForemanTeamdynamix plugin, owner is #{host.owner_id}"
      - name: Ticket Routing Details
        id: 11636
        value: "Asset for host running on OS #{host.operatingsystem_id}"
    :delete:
      :StatusId: 642
  :fields:
    :url: https://miamioh.teamdynamix.com/SBTDNext/Apps
    Asset ID: ID
    Owner: OwningCustomerName
    Parent Asset: ParentID
    mu.ci.Description: Attributes.mu.ci.Description
    Ticket Routing Details: Attributes.Ticket Routing Details
    mu.ci.Lifecycle Status: Attributes.mu.ci.Lifecycle Status
```
[:api][:create] or [:delete]
* All attributes are passed to the TeamDynamix API as is, while creating or deleting a TeamDynamix Asset.
* An asset gets created or deleted with the Foreman Host create or delete life cycle event.

[:api][:create][:Attributes]
* To configure any [Custom Attributes](https://api.teamdynamix.com/TDWebApi/Home/type/TeamDynamix.Api.CustomAttributes.CustomAttribute) for the asset.
* It must contain expected value for 'id' and 'value' fields.
* rest of the fields are optional, check the Custom Attribute's definition for what other fields are updatable.
* String interpolation is supported for custom attribute's value.

[:fields]
* The keys are the display title and the values are the methods that are actually called to produce the value.
* A link to the asset in Teamdynamix is displayed by default, as first field labelled as URI.
* Nested attributes i.e custom attributes can be configured as mentioned in example configuration.
* If an attribute or nested attribute does not exist or is not found, it would simply not be displayed.

## Add additional host attribute
```
rake db:migrate
```

## Verify the TeamDynamix Tab is loaded
Navigate to /hosts/, click on one of the listed host. There should be tabs: 'Properties', 'Metrics', 'Templates', 'NICs' and 'teamdynamix.title or Team Dynamix Tab'

## Development mode
foreman running locally (i.e not installed via rpm/debian package) does not use settings from /etc/foreman/plugins/
Add the teamdynamix config to <foreman_repo>/config/settings.yaml

## Rake Task
```
rake teamdynamix:sync:hosts
```
Scans the hosts and sync them with TeamDynamix.
* If host has teamdynamix_asset_uid, update the corresponding TeamDynamix asset.
* If host name matches the asset SerialNumber, update the host and the corresponding TeamDynamix asset.
* If host has no matching asset, create an asset in TeamDynamix with configured fields.

## Test mode
```
gem install foreman_teamdynamix --dev
rake test:foreman_teamdynamix
```
