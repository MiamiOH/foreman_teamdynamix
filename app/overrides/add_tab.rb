if SETTINGS[:teamdynamix]
  Deface::Override.new(:virtual_path => 'hosts/show',
                       :name => 'add_tab_link',
                       :insert_bottom => 'ul#myTab',
                       :text =>
                       "<li><a href='#teamdynamix' data-toggle='tab'><%= _(teamdynamix_title) %></a></li>")
end
