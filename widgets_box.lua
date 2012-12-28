local z=require("z")
local wibox=require("wibox")
local awful=require("awful")
local vicious=require("vicious")
local naughty=require("naughty")
module("widgets_box")

local mwibox={}

function graph_widget()
    local ret = awful.widget.graph()
--    ret:set_width(20)
    ret:set_background_color("#494B4F")
    ret:set_color("#FF5656")
    return ret
end

--[[
 mytextbox:buttons(awful.util.table.join(
   awful.button({ }, 1, function () awful.util.spawn("echo Left mouse button pressed.") end)
 ))
]]--

function add_widgets()
    local root_layout=wibox.layout.align.vertical()
    local payload_layout=wibox.layout.fixed.vertical()

    --Memory stuff
    local mem_text_widget=wibox.widget.textbox()

    mem_text_widget:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.util.spawn("echo Left mouse button pressed.") end)
     ))
    vicious.register(mem_text_widget, vicious.widgets.mem, "Memory:<span color='red'> $1% ($2MB/$3MB) </span>", 10)
    local mem_graph_widget=graph_widget()
    vicious.register(mem_graph_widget, vicious.widgets.mem, "$1", 1)
    payload_layout:add(mem_text_widget)
    payload_layout:add(mem_graph_widget)
    --CPU stuff
    local cpu_text_widget=wibox.widget.textbox()
    vicious.register(cpu_text_widget, vicious.widgets.cpu, "CPU:<span color='green'>avg:$1%,cpu1:$2%,cpu2:$3%</span>", 1)
    local cpu_graph_widget=graph_widget()
    vicious.register(cpu_graph_widget, vicious.widgets.cpu, "$1", 1)
    payload_layout:add(cpu_text_widget)
    payload_layout:add(cpu_graph_widget)
--[[    --Battery stuff
    local bat_text_widget=wibox.widget.textbox({})
    vicious.register(bat_text_widget, vicious.widgets.bat, "bat:$['state'] $2 $3", 60)
    local cpu_graph_widget=graph_widget()
    vicious.register(cpu_graph_widget, vicious.widgets.cpu, "$1", 1)
    payload_layout:add(bat_text_widget)
    payload_layout:add(cpu_graph_widget)
]]--
    root_layout:set_middle(payload_layout)
    mwibox:set_widget(root_layout)
end


function toggle()
    mwibox.visible= not mwibox.visible
end






function init()
    mwibox=z.utils.new_wibox({opacity=0.9})
    add_widgets()
end
init()
