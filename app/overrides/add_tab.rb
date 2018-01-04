if SETTINGS[:team_dynamix]
  Deface::Override.new(:virtual_path => 'hosts/show',
                       :name => 'add_tab_link',
                       :insert_bottom => 'ul#myTab',
                       :text =>
                       "<li><a href='#team_dynamix' data-toggle='tab'><%= _(td_tab_title) %></a></li>")
end
