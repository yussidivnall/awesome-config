local z=z
local timer=timer
local io=io
local naughty=naughty
local ipairs=ipairs
local table=table
local utils=z.utils
module("z.network.connections")
connections_panel=nil
listen_panel=nil
tor_panel=nil
all_panel=nil
established_panel=nil


visible=false
update_timer=nil
config={}
config.update_timeout=2
config.commands={}
config.commands.connections="/home/volcan/.config/awesome/testing/zutils/proc_net_table.py"
config.colors={
	STATE_LISTEN='blue',
	STATE_ESTABLISHED='red',
	STATE_OTHER='green'
	
}


local connections_dump={}
local listening_ports={}
local tor_connections={}
local established_connections={}

local all_connections={}

function field_splitter(line)
	local ret={}
	local fields=z.utils.split(line,"%s")
	ret.src_ip=z.utils.split(fields[1],":")[1]
	ret.src_port=z.utils.split(fields[1],":")[2]

	ret.dest_ip=z.utils.split(fields[2],":")[1]
	ret.dest_port=z.utils.split(fields[2],":")[2]

	
	ret.state=fields[3]
	return ret
end

function color(color,text)
	ret="<span color='"..color.."'>"..text.."</span>"
	--ret=""..text.."</span>"
	return ret
end
function paint_established(conn)
	ret=""
	if(conn.src_port==443) then
		ret="<span color='red'> https://"..conn.src_ip.." "..conn.src_port.."</span>"
	else
		ret="<span color='white'>"..conn.src_ip.." "..conn.src_port.."</span>"
	end
	return ret
end


function display()
	local all_list={'other'}
	local listen_list={'listening'}
	local established_list={'established'}
	local tor_list={'tor'}
	for idx,con in ipairs(all_connections) do 
		if(con.state=='LISTEN') then
			--established
			table.insert(listen_list,color(config.colors.STATE_LISTEN,con.src_port.."	"..con.src_ip))
                elseif (con.src_port == '8118' or con.dest_port=='8118' or con.src_port=='9050' or con.dest_port=='9050') then
                        table.insert(tor_list,color('green',con.src_ip..":"..con.src_port.."     "..con.dest_ip..":"..con.dest_port))
		elseif (con.state=='ESTABLISHED') then
			txt=paint_established(con)
			table.insert(established_list,txt)
			--table.insert(established_list,color(config.colors.STATE_ESTABLISHED,con.src_port.."	"..con.dest_ip..":"..con.dest_port))
		else
			table.insert(all_list , con.src_ip..":"..con.src_port.."   "..con.dest_ip.."       "..con.state)
		end
		
		--table.insert(all_list , con.src_ip.."	"..con.dest_ip.."	"..con.state)
	end

	listening_panel:set_payload({payload=listen_list})
	listening_panel:update()
	connections_panel:set_payload({payload=all_list})
	connections_panel:update()
	established_panel:set_payload({payload=established_list})
	established_panel:update()
	tor_panel:set_payload({payload=tor_list})
	tor_panel:update()
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
	f=io.popen(config.commands.connections)
	t=f:read("*a")
	f:close()	
	t=utils.split(t,"\n")
	connections_dump=t
--	connections_panel:set_payload({payload=t})
--	connections_panel:update()
	populate()
	display()
end



function onstart()
	visible=true
	connections_panel:show()
	listening_panel:show()
	established_panel:show()
	tor_panel:show()
	update_connections()
	update_timer:start()
end

function onstop()
	visible=false
	update_timer:stop()
	connections_panel:hide()
	established_panel:hide()
	listening_panel:hide()
	tor_panel:hide()
end
function toggle()
	if(visible==true) then onstop()
	else onstart()
	end
end
function init()
	--Newer...
	--est_panel=z.network.network_panel()
	--old ...
	connections_panel=z.panel({rows=40})
	listening_panel=z.panel({rows=20,wibox_params={x=100}})
	established_panel=z.panel({rows=20,wibox_params={x=100,y=200}})
	tor_panel=z.panel({rows=15,wibox_params={x=200, width=300}})
	update_timer=timer({timeout=config.update_timeout})
	update_timer:connect_signal("timeout", function() update_connections() end )
--	toggle()
end
init()
