local naughty=require("naughty")
local awful=require("awful")
local pairs=pairs
local ipairs=ipairs
local io=io
local os=os
module("z.media")
panel={}
volume_widget={}
cmd_volume_up="amixer set Master 5%+| egrep -o \"[0-9]+%\""
cmd_volume_down="amixer set Master 5%-| egrep -o \"[0-9]+%\""
msg_id=23

function update_widget()
    
    end
function volume_up()
    f=io.popen(cmd_volume_up)
    txt=f:read("*a")
    f:close()
    n=naughty.notify({text="<span color='gray'>Volume:</span><span color='green'>\n"..txt.."</span>" ,replaces_id=msg_id,position="top_left"})
    msg_id=n.id
    end
function volume_down()
    f=io.popen(cmd_volume_down)
    txt=f:read("*a")
    f:close()
    n=naughty.notify({text="<span color='gray'>Volume:</span><span color='green'>\n"..txt.."</span>" ,replaces_id=msg_id,position="top_left"})
    msg_id=n.id
    end
function init()
    naughty.notify({text='<span color="yellow">z.media LOADED!</span>'})
    wolume_widget=awful.widget.progressbar()
    end
init()
