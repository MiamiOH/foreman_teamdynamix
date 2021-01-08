if SETTINGS[:teamdynamix]
  Deface::Override.new(:virtual_path => 'hosts/show',
                       :name => 'teamdynamix_add_tab',
                       :insert_bottom => 'ul#host-show-tabs',
                       :text =>
                       "<li><a href='#teamdynamix' data-toggle='tab'><%= _(teamdynamix_title) %></a></li>")
end
