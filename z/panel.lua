--------------------------------------
--@author Yussi Divnal
--------------------------------------
local setmetatable=setmetatable
local table=table
require("z.utils")
--local utilz=require("z.utils")
local z=z
local wibox=wibox
local timer=timer
module("z.panel")

panel={
}

---Creates a new panel from a table of arguments
--@param args.rows - number of rows to display, default 15 \n
--@param args.wibox_params - parameters for z.utils.new_wibox()
--@param args.root_layout
--@param args.payload_layout
--@return a new panel
function panel.new(args)
	local ret={}
	ret.num_rows=args.rows or 15	
	ret.wb_params = args.wibox_params or {}
	if not ret.wb_params.height then ret.wb_params.height=ret.num_rows*13 end
	ret.wibox=z.utils.new_wibox(ret.wb_params)
	ret.root_layout = args.root_layout or wibox.layout.align.vertical()
	ret.payload_layout = args.payload_layout or wibox.layout.fixed.vertical()
	for i=1,ret.num_rows do
		local w=wibox.widget.textbox()
		w:set_text(i.." : ")
		ret.payload_layout:add(w)
	end
	ret.root_layout:set_middle(ret.payload_layout)
	ret.wibox:set_widget(ret.root_layout)
	ret.payload={}
	ret.current_index=1
	ret.pop_timer=nil
	ret.pop_on=false
	setmetatable(ret,{__index=panel})
	return ret
end


---Sets the payload of the panel
--@param me - a panel context
--@param args - a table of arguments
--args.payload - a table of strings to use as payload
function panel.set_payload(me,args)
	if(not args.payload) then return end
	me.payload=args.payload
	me:update()

end
---Updates the displayed widgets list
--@TODO check the type of payload element, and modify the widget accordingly
--Ath the moment only accepts a table of strings as payload
function panel.update(me)
	for i=me.current_index,(me.current_index+me.num_rows-1) do
		local widget_index=i-me.current_index+1
		if(me.payload[i]~=nil) then
			--Check type (see todo)
			me.payload_layout.widgets[widget_index]:set_markup(me.payload[i])
		else
			me.payload_layout.widgets[widget_index]:set_markup(i..": empty")
		end
	end	
end

---Appends an element (a string) to end of list and scroll to bottom
--@param element - a string to append
function panel.append(me,element)
	table.insert(me.payload,element)
	me:scroll("last")
end

---Scroll the displayed list
--@param direction (up,down,first,last)
function panel.scroll(me,args)
	if(args==nil) then return end
	if(args=="last") then
		if(#me.payload > me.num_rows) then
			me.current_index=#me.payload-me.num_rows+1
		else
			me.current_index=1
		end
	elseif(args=="first") then
		me.current_index=1
	elseif(args=="down") then
		if(me.current_index <(#me.payload-me.num_rows))then
			me.current_index=me.current_index+1
		end
	elseif(args=="up") then
		if(me.current_index > 1) then
			me.current_index=me.current_index-1
		end
	else return end
	me:update()
end

---Shows panel
function panel.show(me) me.wibox.visible=true end
---Hides panel
function panel.hide(me) me.wibox.visible=false end
---Toggle panel's visibility
function panel.toggle(me) me.wibox.visible=not me.wibox.visible end
--is visible
function panel.visible(me) return me.wibox.visible end

---Pops panel 
-- If panel is already on a pop timer, restart it, 
-- If panel is visible and not on a pop timer, do nothing
-- else pop up panel for a given time
--@param args.timeout the timeout to pop for default 5
function panel.pop(me,args)
	local to=args.timeout or me.default_pop_timeout or 5
	if(me.wibox.visible==true and me.pop_timer_on==false) then return end -- no need to popup
	me:show()
	me.pop_timer_on=true
	if(me.pop_timer ~=nil) then me.pop_timer:stop() end --stop old timer
	me.pop_timer=timer({timeout=to})
	me.pop_timer:connect_signal("timeout",function() me:hide();me.pop_timer_on=false end)
	me.pop_timer:start()
end

setmetatable(_M, { __call=function(_, ...) return panel.new(...) end })
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
