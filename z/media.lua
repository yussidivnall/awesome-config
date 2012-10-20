local naughty=require("naughty")
local awful=require("awful")
local pairs=pairs
local ipairs=ipairs
local io=io
local os=os
module("z.media")
panel={}
volume_bar_widget={}
function volume_up()
    cmd="amixer set Master 5%+"
    os.execute(cmd)
    end
function volume_down()
    cmd="amixer set Master 5%-"
    os.execute(cmd)
    end
function init()
    naughty.notify({text='<span color="yellow">z.media LOADED!</span>'})
    volume_bar_wiget=awful.widget.progressbar()
    end
init()
