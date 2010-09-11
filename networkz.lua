local utilz=require("utilz")
local naughty=require("naughty")
local panelz=require("panelz")
local awful=require("awful")
local os=os
local io=io
local timer=timer
local string=require("string")
local table=table
local widget=widget
local ipairs=ipairs
local keygrabber=keygrabber
local inotify=require("inotify")

module("networkz")
local config={}
config.alerts_panel = nil
config.netstat_panel = nil
config.netstat_args=" -nutpeed"
config.netstat_timer=nil
config.netstat_refresh_rate=1
config.netstat_header_widget=widget({type='textbox'})
config.netstat_footer_widget=widget({type='textbox'})
config.netstat_colors={
	["ESTABLISHED"]='green',
	["SYN_SENT"]='yellow',
	["SYN_RECV"]='#aaaa00',
	["FIN_WAIT1"]='orange',
	["FIN_WAIT2"]='orange',
	["TIME_WAIT"]='blue',
	["CLOSE"]='grey',
	["CLOSE_WAIT"]='grey',
	["LAST_ACK"]='grey',
	["LISTEN"]='red',
	["CLOSING"]='grey',
	["UNKNOWN"]='pink',
}

config.alerts=true
config.monitor=false

config.selectable={"net_alerts","netstat"}
config.selected=1
config.selected_wibox_color="#aa0ba9"
config.unselected_wibox_color="#0a0ba9"
net_widget=widget({type='textbox'})


function color_line_by_state(state,line)
	ret="<span color='"..config.netstat_colors[state].."'>"..line.."</span>"
	return ret
end
function update_netstat_panel_nutpeed(txt)
	local panel_output={}
        local lines=utilz.split(txt,"\n")
        for idx,line in ipairs(lines) do
		if (line=="" or line==nil) then naughty.notify({text="empty line"})end
                words=utilz.split(line,"%s+")
                local protocol=words[1]
                local rcv_que=words[2]
                local trx_que=words[3]
                local local_address=utilz.split(words[4],":")[1]
                local local_port=utilz.split(words[4],":")[2]
                local remote_address=utilz.split(words[5],":")[1]
                local remote_port=utilz.split(words[5],":")[2]
		local state=words[6]
                local program=words[9]
		out_line={text=color_line_by_state(state,program.." "..remote_address..":"..remote_port.."|tx:"..rcv_que.."|rx:"..trx_que)}
		table.insert(panel_output,out_line)
                --naughty.notify({text=out_line})
        end
	config.netstat_panel:update(panel_output)
end
function update_netstat_panel(d,txt)
	config.netstat_header_widget.text="netstat "..config.netstat_args.."\n"..d
	if txt=="" or txt==nil then return end
	if (config.netstat_args==" -nutpeed") then update_netstat_panel_nutpeed(txt) end
end
function update_listening_panel(d,txt)
end
function update_monitors()
	--@TODO use inotify to verify if update needed
	if(config.monitor==false) then return end --@TODO Also check files exist
	local FH=io.open("/tmp/.awesome.listening")
	if(FH) then 
		local listening_date=FH:read("*l")
		local listening_text=FH:read("*a")
		FH:close()
		FH=nil
		update_listening_panel(listening_date,listening_text)
	end
	
	FH=io.open("/tmp/.awesome.netstat_out")
	if(FH) then 
		local netstat_date=FH:read("*l")
		local netstat_text=FH:read("*a")
		FH:close()
		FH=nil
		update_netstat_panel(netstat_date,netstat_text)
	end
end

function reset_colors()
	config.alerts_panel.wibox.border_color=config.unselected_wibox_color
	config.netstat_panel.wibox.border_color=config.unselected_wibox_color
end

function highlight_selection()
	reset_colors()
	if(config.selectable[config.selected]=="net_alerts") then
		config.alerts_panel.wibox.border_color=config.selected_wibox_color
	elseif(config.selectable[config.selected]=="netstat") then
		config.netstat_panel.wibox.border_color=config.selected_wibox_color
	end
end
function scroll_selection(d)
	if(config.selectable[config.selected]=="net_alerts") then 
		config.alerts_panel:scroll({direction=d})
	end
end


function toggle_selection(direction)
	--if direction==nil then return end
	if(direction=="left") then 
		config.selected=config.selected-1
		if config.selected < 1 then config.selected=#config.selectable end
	end
	if(direction=="right") then
		config.selected=config.selected+1
		if config.selected > #config.selectable then config.selected=1 end
	end
	naughty.notify({text=config.selectable[config.selected]})
	highlight_selection()
end

function key_listener(mod_keys,key,action)
	if(key=="h" or key=="Left")and action=="press" then toggle_selection("left") end
	if(key=="l" or key=="Right") and action=="press" then toggle_selection("right")end
	if(key=="j" or key=="Up")and action=="press" then scroll_selection("up")end
	if(key=="k" or key=="Down")and action=="press" then scroll_selection("down")end
	return true
end

function alert(msg)
	config.alerts_panel:append({text="<span color='yellow'>"..msg.."</span>"})
	config.alerts_panel:resize({max_height=75})
	if config.alerts==true then config.alerts_panel:pop({timeout=2}) end
end
function set_widget_text()
	ret=""
	if(config.alerts==true) then
		ret="|<span color='white'>net alerts:</span><span color='green'>on</span>|"
	else
		ret="|<span color='white'>net alerts:</span><span color='red'>off</span>|"
	end
	net_widget.text=ret
end


function show_monitor()
	config.monitor=true
	config.netstat_panel:show()
	os.execute("echo "..config.netstat_args..">/tmp/.awesome.netstat")
end
function hide_monitor()
	config.monitor=false
	config.netstat_panel:hide()
	os.execute("rm /tmp/.awesome.netstat")
end

function toggle_network(args)
end
function toggle_alerts()
	if(config.alerts==true) then disable() 
	else enable() end
end
function enable()
	config.alerts=true
	set_widget_text()
end
function disable()
	config.alerts=false
	config.alerts_panel:hide()
	set_widget_text()
end
function main()
	config.alerts_panel=panelz.Panel.new({rows=3})
	config.alerts_panel.wibox.width=600
	config.alerts_panel.wibox.height=50
	--config.alerts_panel.wibox.y=200
	set_widget_text()

	config.netstat_header_widget.text="netstat "..config.netstat_args
	config.netstat_footer_widget.text="----"
	config.netstat_panel=panelz.Panel.new({rows=40,header=config.netstat_header_widget,footer=config.netstat_footer_widget})
	config.netstat_panel.wibox.width=275
	config.netstat_panel.wibox.height=500
	config.netstat_panel.wibox.x=5
	config.netstat_panel.wibox.y=100
end
function init()
	net_widget:buttons(
		awful.util.table.join(
			awful.button({},1,function() toggle_alerts(); config.alerts_panel:show() end)
		)
	)
	net_widget:add_signal("mouse::enter",function()
		show_monitor()
		config.alerts_panel:show()
		if(config.alerts_panel.hide_timer~=nil) then
			config.alerts_panel.hide_timer:stop()
			config.alerts_panel.hide_timer=nil;
		end
		keygrabber.run(function(m,k,a) return key_listener(m,k,a) end)
		
	end)
	net_widget:add_signal("mouse::leave",function()
		config.alerts_panel:hide()
		hide_monitor()
		keygrabber.stop()
	end)
	config.netstat_timer=timer({timeout=config.netstat_refresh_rate})
	config.netstat_timer:add_signal("timeout",function() update_monitors() end)
	config.netstat_timer:start()
	highlight_selection()
end
main()
init()
