# foreman_teamdynamix
A Foreman Plugin for TeamDynamix. It manages a host lifecycle as a corresponding Asset in TeamDynamix.

## Configuration
[:api][:create]
* All attributes are passed as is to the Team Dynamix API while creating an asset for the Foreman host.

[:fields]
* A link to the asset in Teamdynamix is displayed by default, as first field labelled as URI
* Nested attributes can be configured as mentioned in example configuration below.
* If an attribute or nested attribute does not exist or is not found, it would simply not be displayed.

```
:teamdynamix:
  :api:
    :url: 'td_api_url'
    :id: 'id'
    :username: 'username'
    :password: 'password'
    :create:
      :StatusID: integer_id
      :OwningCustomerName: string
  :title: 'custom title for Team Dynamix Tab'
  :fields:
    Asset ID: ID
    Owner: OwningCustomerName
    Parent Asset: ParentID
    mu.ci.Description: Attributes.'mu.ci.Description'
    Ticket Routing Details: Attributes.'Ticket Routing Details'
    mu.ci.Lifecycle Status: Attributes.mu.ci.Lifecycle Status
    Not an Attribute: Not an Attribute.none
    non-existent nested attribute: Attributes.does not exist
```

## Add additional host attirbute
rake db:migrate
