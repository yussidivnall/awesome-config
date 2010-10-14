local io=io
local awful=require("awful")
local naughty=require("naughty")
local wibox=wibox
local string=string
local type=type
local table=table
module("z.utils")

---Creates a new wibox from a table of argumets
--@param x
--@param y
--@param width
--@param height
--@param screen
--@param visible
--@param opacity
--@return new wibox
function new_wibox(args)
        local X=args.x or 2
        local Y=args.y or 20
        local w=args.width or 200
        local h=args.height or 200
        local s = args.screen or 1
	local v = args.visible or false
	local o = args.opacity or 0.6
        local ret = wibox({fg="#ffffff", bg="#000000",border_color="#0a0ba9", border_width=2 })
        ret.opacity=o
        ret.ontop=true
        ret:geometry({ width=w,height=h,x=X,y=Y })
	ret.visible=v
        ret.screen=s
        return ret
end
