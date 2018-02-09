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
:teamdynamix:
  :api:
    :url: 'https://miamioh.teamdynamix.com/SBTDWebApi/api'
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
    :search:
      AppID: 741
      StatusName: In Use
      RequestingCustomerID: 00000000-0000-0000-0000-000000000000
      OwningDepartmentID: 15798
  :fields:
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
rake hosts:sync_with_teamdynamix
```
Gets existing assets in TeamDynamix based on search params [:teamdynamix][:api][:search]. Then scans the hosts and sync them with TeamDynamix.
* If host has teamdynamix_asset_id, update the corresponding TeamDynamix asset.
* If host name matches the asset Name or SerialNumber, update the host and the corresponding TeamDynamix asset.
* If host has no matching asset, create an asset in TeamDynamix with configured fields.

## Test mode
```
gem install foreman_teamdynamix --dev
rake test:foreman_teamdynamix
```

## Notes

This project is still incomplete and in development. 

Copyright (c) 2017 Joe Lyons Stannard III

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
