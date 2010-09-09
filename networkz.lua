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
module("networkz")
local config={}
config.alerts_panel = nil
config.netstat_panel = nil
config.netstat_args=" -nutpeed"

config.alerts=true
config.monitor=false
net_widget=widget({type='textbox'})


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
	return ret
end


function show_monitor()
	config.netstat_panel:show()
	os.execute("echo "..config.netstat_args..">/tmp/.awesome.netstat")
end
function hide_monitor()
	config.netstat_panel:hide()
	os.execute("rm /tmp/.awesome.netstat")
end

function toggle_network(args)
end

function main()
	config.alerts_panel=panelz.Panel.new({rows=3})
	config.alerts_panel.wibox.width=600
	config.alerts_panel.wibox.height=50
	--config.alerts_panel.wibox.y=200
	net_widget.text=set_widget_text()

	config.netstat_panel=panelz.Panel.new({rows=40})
	config.netstat_panel.wibox.width=200
	config.netstat_panel.wibox.height=500
	config.netstat_panel.wibox.x=5
	config.netstat_panel.wibox.y=100
end
function init()
	net_widget:buttons(
		awful.util.table.join(
			awful.button({},1,function()
				config.alerts=not config.alerts
				net_widget.text=set_widget_text()
			end)
		)
	)
	net_widget:add_signal("mouse::enter",function()
		show_monitor()
		config.alerts_panel:show()
		if(config.alerts_panel.hide_timer~=nil) then
			config.alerts_panel.hide_timer:stop()
			config.alerts_panel.hide_timer=nil;
		end
		
	end)
	net_widget:add_signal("mouse::leave",function()
		config.alerts_panel:hide()
		hide_monitor()
	end)
end
main()
init()
