# foreman_teamdynamix
A Foreman Plugin for TeamDynamix. It manages a host's life cycle as a corresponding Asset in TeamDynamix.

## Configuration

Example Configuration, add to settings.yaml

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
* A link to the asset in Teamdynamix is displayed by default, as first field labelled as URI.
* Make sure the Asset Attribute Name is spelled right. Label is to label it in the TeamDynamix Tab.
* Nested attributes i.e custom attributes can be configured as mentioned in example configuration.
* If an attribute or nested attribute does not exist or is not found, it would simply not be displayed.

## Add additional host attribute
```
rake db:migrate
```

## Rake Task
```
rake hosts:sync_with_teamdynamix
```
Gets existing assets in TeamDynamix based on search params [:teamdynamix][:api][:search]. Then scans the hosts and sync them with TeamDynamix.
* If host has teamdynamix_asset_id, update the corresponding TeamDynamix asset.
* If host name matches the asset Name or SerialNumber, update the host and the corresponding TeamDynamix asset.
* If host has no matching asset, create an asset in TeamDynamix with configured fields.


## Development
```
gem install foreman_teamdynamix --dev
```
