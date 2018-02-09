# foreman_teamdynamix
A Foreman Plugin for TeamDynamix. It manages a host's life cycle as a corresponding Asset in TeamDynamix.

## Configuration

Example Configuration, add to settings.yaml

```
:teamdynamix:
  :api:
    :url: 'td_api_url'
    :appId: 'id'
    :username: 'username'
    :password: 'password'
    :create:
      :StatusID: integer_id
      :attribute_name: string
      :Attributes:
      - name: custom attribute name
        id: integer_id
        value: integer or string value
      - name: custom attribute with dynamic value
        id: integer_id
        value: "lorem ipsum #{host.host_attribute_name}"
    :delete
      :StatusID: integer_id
    :search:
      AppID: 741
      StatusName: In Use
      RequestingCustomerID: 00000000-0000-0000-0000-000000000000
      OwningDepartmentID: 15798
  :title: 'custom title for TeamDynamix Tab'
  :fields:
    Asset ID: ID
    attribute label: Attribute_Name_as_in_asset
    custom attribute name: Attributes.custom attribute name
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
rake db:migrate

## Rake Task
Gets existing assets in TeamDynamix based on search params [:teamdynamix][:api][:search]. Then scans the hosts and sync them with TeamDynamix.
* If host has teamdynamix_asset_id, update the corresponding TeamDynamix asset.
* If host name matches the asset Name or SerialNumber, update the host and the corresponding TeamDynamix asset.
* If host has no matching asset, create an asset in TeamDynamix with configured fields.

It could be run as:
* rake hosts:sync_with_teamdynamix

## Development
gem install foreman_teamdynamix --dev
