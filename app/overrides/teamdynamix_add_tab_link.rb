if SETTINGS[:teamdynamix]
  Deface::Override.new(:virtual_path => 'hosts/show',
                       :name => 'teamdynamix_add_tab_link',
                       :insert_bottom => 'div#myTabContent',
                       :text =>
                       "\n  <div id='teamdynamix' class='tab-pane'
                       data-ajax-url='<%= teamdynamix_host_path(@host)%>' data-on-complete='onContentLoad'>
                       <%= spinner(_('Loading Team Dynamix information for the host ...')) %>
                       </div>")
end
