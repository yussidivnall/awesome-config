local table=table
local setmetatable=setmetatable
local utilz=require("utilz")
local widget=widget
local awful = require("awful")
local table=table
local type=type
local wibox=wibox
local ipairs = ipairs
local pairs = pairs
local beautiful=require("beautiful")
local naughty=require("naughty")
local gsub=gsub
local timer=timer
module("panelz")

Panel={
}



function Panel.new(args)
	local  ret={}
	local wb_params=args.wibox_params or {}
	local num_rows=args.rows or 15
	local wi_list_layout=args.list_layout or awful.widget.layout.vertical.topdown
	local wibox_layout=args.wibox_layout or awful.widget.layout.vertical.topdown
	ret.header = args.header or nil
	ret.footer = args.footer or nil
	ret.wibox=utilz.new_wibox(wb_params)
	ret.wibox.ontop=true
	ret.wibox.screen=1
	ret.wi_list={}
	for i=1,num_rows do
		local w=widget({type="textbox"})
		w.text=""
		--w.text="empty:"..i
		table.insert(ret.wi_list,w)
	end
	ret.wi_list["layout"]=wi_list_layout
	ret.wibox.widgets={args.header or "" ,ret.wi_list,ret.footer or "",["layout"] = wibox_layout}

	ret.current_index=1
	ret.num_rows=num_rows
	ret.wibox_layout=wibox_layout
	ret.element_list={}
	setmetatable(ret,{__index=Panel})
	return ret
end

function Panel.update(me,l)
	local l = l
	for i=me.current_index,me.num_rows do
		--naughty.notify({text="hlkjhl"..i})
		local element_index=i-me.current_index+1
		if(l[i]==nil) then
			local empty=widget({type='textbox'})
			empty.text=i.." : -"
			me.wi_list[i]=empty
			--me.wi_list[i].text=i.." : -"
			--me.wi_list[element_index].text=i.." : -"
		else
			if l[i].widgets ~= nil then
				--@TODO figure out why this doesn't do the trick
				--Doesn't work for a table of widgets (does work if table is defined here instead???!?!??
				--@UPDATE works now, no idea why
				--@Update, Memory leak, probably from here
				--me.wi_list[element_index]=nil
				el=me.wi_list[element_index];
				--@TODO Unregister all signals too
				table.remove(me.wi_list,element_index)
				me.wi_list[element_index]=l[i].widgets 
			end
			if l[i].text~=nil then me.wi_list[element_index].text=l[element_index].text end
			if l[i].signals~=nil then
				for sig,funk in pairs(l[i].signals) do
					--@TODO Needs to check if signal and function already the same for the widget and if so skip all of this
					if (me.element_list ~= nil ) then -- Remove old signals - do i really have to do all of this?
						if(me.element_list[i] ~=nil) then 
							if (me.element_list[i].signals~=nil) then 
								if(me.element_list[i].signals[sig]~=nil) then 
									me.wi_list[element_index]:remove_signal(sig,me.element_list[i].signals[sig])
								end
							end	
						end
					end
					me.wi_list[element_index]:add_signal(sig,funk)
				end	
			end
		end
	end
	me.element_list=nil
	me.element_list=l
end

function Panel.show(me)
	me.wibox.visible=true
end

function Panel.hide(me)
	me.wibox.visible=false
end
function Panel.toggle(me)
	me.wibox.visible=not me.wibox.visible
end

Panel.hide_timer=nil
Panel.on_timer=false
function Panel.pop(me,args)
	to=args.timeout or 5
	if me.wibox.visible==true and me.on_timer==false then return end 
	me:show()
	me.on_timer=true
	if(me.hide_timer~=nil) then me.hide_timer:stop() end
	me.hide_timer=timer({timeout=to})
	me.hide_timer:add_signal("timeout",function() me:hide();me.on_timer=false end)
	me.hide_timer:start()
end

function Panel.bottom(me)
	if(#me.element_list < me.num_rows) then	
		for i=1,me.num_rows do
			if (me.element_list[i]==nil) then 
				return
				--me.wi_list[i].text="ljk;khj;l"
				--next i;
			end
			if (me.element_list[i].text~=nil) then
				me.wi_list[i].text=me.element_list[i].text
				--me.wi_list[i].text=i.." - "..me.element_list[i].text
			end			
		end
	else
		local s=#me.element_list-me.num_rows+1
		local e=#me.element_list
		--naughty.notify({text="start:"..s.." end:"..e})
		for i=s,e do
			--naughty.notify({text="index:"..i})
			local wl_index=i-s+1
			--if (me.element_list[i]==nil) then return end
			if (me.element_list[i].text~=nil)then
				me.wi_list[wl_index].text=me.element_list[i].text
				--me.wi_list[wl_index].text=i.." - "..me.element_list[i].text
			end
		end
		me.current_index=s
		--naughty.notify({text="bottom:"..s})
	end
end
function Panel.redraw(me)
	--naughty.notify({text="REDRAW!!!"})
	for i=me.current_index,(me.current_index+me.num_rows-1) do
		--naughty.notify({text="<span color='green'>"..i.."</span>"})
		local wi_index=i-me.current_index+1
		if me.element_list[i] == nil then
			--naughty.notify({text="NIL value"}) 
		end
		if me.element_list[i].text ~= nil then 
			me.wi_list[wi_index].text=me.element_list[i].text
		end
		--naughty.notify({text="Redrawing row:"..i})
	end
end

function Panel.scroll(me,args)
	if(#me.element_list < 1) then return end
	local direction=args.direction
	local rows=args.rows or 1
	if direction=="up" then 
		--naughty.notify({text="Scrool up"})
		--if me.current_index==1 then return end
		if (me.current_index-rows <= 1)then  
			me.current_index=1 
		else
			me.current_index=me.current_index-rows
		end
		--naughty.notify({text="current_index:"..me.current_index})
	end
	if direction=="down" then
		if me.current_index > (#me.element_list-me.num_rows) then 
			me.current_index=(#me.element_list-me.num_rows) 
		end
		me.current_index=me.current_index+1
	end
	me:redraw() 
end
function Panel.append(me,args)
	table.insert(me.element_list,args)
	me:bottom()
end
function Panel.resize(me,args)
	if args~=nil then
	end
	local total_height=0;
	for i=1,me.num_rows do
		local ext=me.wi_list[i]:extents()
		total_height = total_height+ext.height
	end
	if (args.max_height and total_height > args.max_height) then 
		me.wibox.height=args.max_height
	else 
		me.wibox.height=total_height
	end
end
