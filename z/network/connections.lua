local z=z
local timer=timer
local io=io
module("z.network.connections")
connections_panel=nil
listen_panel=nil
tor_panel=nil

update_timer=nil
config={}
config.update_timeout=2
config.commands={}
config.commands.connections="/home/volcan/.config/awesome/testing/zutils/proc_net_table.py"

connections_dump={}
listening_ports={}
tor_connections={}




function update_connections()
	
	t=z.utils.exec(config.commands.connections)
	t=z.utils.split(t,"\n")
	connections_panel:set_payload({payload=t})
	connections_panel:update()
	connections_dump=t
end



function onstart()
	connections_panel:show()
--	update_connections()
	update_timer:start()
end

function onstop()
	update_timer:stop()
end

function init()
	connections_panel=z.panel({rows=40})
	update_timer=timer({timeout=config.update_timeout})
	update_timer:connect_signal("timeout", function() update_connections() end )
	onstart()
	
end
init()
