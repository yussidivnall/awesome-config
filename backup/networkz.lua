local utilz=require("utilz")
local naughty=require("naughty")
local panelz=require("panelz")
local awful=require("awful")
local os=os
local io=io
local timer=timer
local string=require("string")
local table=table
local wibox = wibox
local widget=widget
local ipairs=ipairs
local keygrabber=keygrabber
local inotify=require("inotify")
local netstatz=require("netstatz")
module("networkz")
local config={}
config.alerts_panel = nil

config.alerts=true
config.monitor=false

config.selectable={"net_alerts","netstat"}
config.selected=1
config.selected_wibox_color="#aa0ba9"
config.unselected_wibox_color="#0a0ba9"
net_widget=wibox.widget.textbox()

function reset_colors()
	config.alerts_panel.wibox.border_color=config.unselected_wibox_color
	netstatz.reset_colors()
end

function highlight_selection()
	reset_colors()
	if(config.selectable[config.selected]=="net_alerts") then
		config.alerts_panel.wibox.border_color=config.selected_wibox_color
	elseif(config.selectable[config.selected]=="netstat") then
		netstatz.highlight(config.selectable[config.selected])
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
	if config.alerts==true and config.alerts_panel.wibox.visible==false then config.alerts_panel:pop({timeout=2}) end
end
function set_widget_text()
	ret=""
	if(config.alerts==true) then
		ret="|<span color='#ffffff'>net alerts:</span><span color='#00aa00'>on</span>|"
	else
		ret="|<span color='#ffffff'>net alerts:</span><span color='#aa0000'>off</span>|"
	end
	net_widget.text=ret
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
	config.alerts_panel.wibox.y=725
	set_widget_text()
end
function init()
	net_widget:buttons(
		awful.util.table.join(
			awful.button({},1,function() toggle_alerts(); config.alerts_panel:show() end)
		)
	)
	net_widget:connect_signal("mouse::enter",function()
	--net_widget:add_signal("mouse::enter",function()
		netstatz.show_monitor()
		config.alerts_panel:show()
		if(config.alerts_panel.hide_timer~=nil) then
			config.alerts_panel.hide_timer:stop()
			config.alerts_panel.hide_timer=nil;
		end
		keygrabber.run(function(m,k,a) return key_listener(m,k,a) end)
		
	end)
	net_widget:connect_signal("mouse::leave",function()
		config.alerts_panel:hide()
		netstatz.hide_monitor()
		keygrabber.stop()
	end)
	highlight_selection()
end
main()
init()
