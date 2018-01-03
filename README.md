# foreman_teamdynamix
A Foreman Plugin for TeamDynamix. It manages a host lifecycle as a corresponding Asset in TeamDynamix.

# configuration
All attributes under [:api][:create] are passed as is to the Team Dynmamix API while creating an asset for the Foreman host.

```
:team_dynamix:
  :api:
    :url: 'td_api_url'
    :id: 'id'
    :username: 'username'
    :password: 'password'
    :create:
      :StatusID: integer_id
      :OwningCustomerName: string
  :fields: {}
```

# Add additional host attirbute
rake db:migrate
