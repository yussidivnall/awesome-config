local setmetatable=setmetatable
local table=table
module("z.menu")

--[[
	@param args
]]--
menu={}

function menu.new(args)
	local ret={}
	
	ret.wb_params = args.wibox_params or {}
	ret.wibox=z.utils.new_wibox(ret.wb_params) 
	ret.wibox.visible=true -- JUST TO TEST!!!
	ret.num_rows=args.rows or 15 -- number of visible rows
	setmetatable(ret,{__index=menu})
	ret.root_layout:set_middle(ret.payload_layout)
        ret.wibox:set_widget(ret.root_layout)
        ret.payload={}
        ret.actions={}
        ret.current_index=1
        ret.selected=1
        ret.pop_timer=nil
        ret.pop_on=false

	return ret
end
---Shows panel
function menu.show(me) me.wibox.visible=true end
---Hides panel
function menu.hide(me) me.wibox.visible=false end
---Toggle panel's visibility
function menu.toggle(me) me.wibox.visible=not me.wibox.visible end
--is visible
function menu.visible(me) return me.wibox.visible end

--@args
function menu.set_payload(me,args)
	if(not args.payload) then return -1 end;
	me.payload=args.payload
end

function menu.update(me,args)
	for i=me.current_index,(me.current_index+me.num_rows-1) do
	end
end
setmetatable(_M, { __call=function(_, ...) return menu.new(...) end })

