# foreman_teamdynamix
A Foreman Plugin for TeamDynamix. It manages a host lifecycle as a corresponding Asset in TeamDynamix.

## configuration
All attributes under [:api][:create] are passed as is to the Team Dynamix API while creating an asset for the Foreman host.

Note: A link to the asset in Teamdynamix is displayed as URI, the first field in Team Dynamix Tab by default.

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
    'Asset ID': ID
    'Owner': OwningCustomerName
    'Parent Asset': ParentID
    'Nested Attribute': Attributes.'attribute name'
    'mu.ci.Description': Attributes.'mu.ci.Description'
    'Ticket Routing Details': Attributes.'Ticket Routing Details'
```

## Add additional host attirbute
rake db:migrate
