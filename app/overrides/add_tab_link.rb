if SETTINGS[:team_dynamix]
  Deface::Override.new(:virtual_path => 'hosts/show',
                       :name => 'create_link',
                       :insert_bottom => 'div#myTabContent',
                       :text =>
                       "\n  <div id='team_dynamix' class='tab-pane'
                       data-ajax-url='<%= team_dynamix_host_path(@host)%>' data-on-complete='onContentLoad'>
                       <%= spinner(_('Loading Team Dynamix information for the host ...')) %>
                       </div>")
end
