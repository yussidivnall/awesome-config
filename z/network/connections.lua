local z=z
local timer=timer
local io=io
local naughty=naughty
local ipairs=ipairs
local table=table
module("z.network.connections")
connections_panel=nil
listen_panel=nil
tor_panel=nil
all_panel=nil

update_timer=nil
config={}
config.update_timeout=2
config.commands={}
config.commands.connections="/home/volcan/.config/awesome/testing/zutils/proc_net_table.py"
config.colors={
	STATE_LISTEN='blue',
	STATE_OTHER='green'
}


local connections_dump={}
local listening_ports={}
local tor_connections={}
local all_connections={}

function field_splitter(line)
	local ret={}
	local fields=z.utils.split(line,"%s")
	ret.src=fields[1]
	ret.dest=fields[2]
	ret.state=fields[3]
	return ret
end

function color(color,text)
	ret="<span color='"..color.."'>"..text.."</span>"
	--ret=""..text.."</span>"
	return ret
end

function display()
	local all_list={}
	local listen_list={}
	table.insert(listen_list,"listening")
	for idx,con in ipairs(all_connections) do 
		if(con.state=='LISTEN') then
			table.insert(listen_list,color(config.colors.STATE_LISTEN,con.src.."	"..con.dest))
		end
		table.insert(all_list , con.src.."	"..con.dest.."	"..con.state)
	end

	listening_panel:set_payload({payload=listen_list})
	listening_panel:update()
	connections_panel:set_payload({payload=all_list})
	connections_panel:update()
end

function populate()
	all_connections={}
	listening_ports={}
	if(connections_dump == nil)then return end
	for idx,val in ipairs(connections_dump) do
		local con=field_splitter(val)
		if(con.state=='LISTEN') then 
			table.insert(listening_ports,con)
		end
		table.insert(all_connections,con)	
	end	

end


function update_connections()
	
	t=z.utils.exec(config.commands.connections)
	t=z.utils.split(t,"\n")
	connections_dump=t
--	connections_panel:set_payload({payload=t})
--	connections_panel:update()
	populate()
	display()
end



function onstart()
	connections_panel:show()
	listening_panel:show()
--	update_connections()
	update_timer:start()
end

function onstop()
	update_timer:stop()
end

function init()
	connections_panel=z.panel({rows=40})
	listening_panel=z.panel({rows=20,wibox_params={x=100}})
	update_timer=timer({timeout=config.update_timeout})
	update_timer:connect_signal("timeout", function() update_connections() end )
	onstart()
	
end
init()
