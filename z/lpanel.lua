--------------------------------------
--@author Yussi Divnal
--------------------------------------
--[[[ 
    A Panel like implementation for stacked layouts
]]

local setmetatable=setmetatable
local table=table
require("z.utils")
--local utilz=require("z.utils")
local z=z
local wibox=require("wibox")
local timer=timer
local naughty=require("naughty")
module("z.lpanel")
lpanel={}

function printsomthing(args)
    print("Hi")
    end

function lpanel.new(args)
    local ret={}
    if(args==nil)then args={} end
	ret.wb_params = args.wibox_params or {}
	ret.wibox=z.utils.new_wibox(ret.wb_params)
    ret.root_layout = args.root_layout or wibox.layout.align.vertical()
    ret.num_rows=args.rows or 15
    setmetatable(ret,{__index=lpanel})
    return ret
end

---Shows panel
function lpanel.show(me) me.wibox.visible=true end
---Hides lpanel
function lpanel.hide(me) me.wibox.visible=false end
---Toggle lpanel's visibility
function lpanel.toggle(me) me.wibox.visible=not me.wibox.visible end
--is visible
function lpanel.visible(me) return me.wibox.visible end

function lpanel.append(me,lout)
--    me.root_layout:add(lout)
end
setmetatable(_M, { __call=function(_, ...) return lpanel.new(...) end })

