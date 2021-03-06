-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("utilz")
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
local wibox=wibox
local widget=wibox.widget
beautiful.init("/usr/local/share/awesome/themes/default/theme.lua")
config={}
if (screen.count() ==1) then
	config.screen=1
else
	config.screen=2
end
config.terminal="rxvt-unicode"
config.modkey="Mod4"
config.layouts={
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.top,
	awful.layout.suit.max,
}
config.keys={}
config.keys.global=awful.util.table.join(
	awful.key({ config.modkey,           }, "Up",   awful.tag.viewnext	  ),
	awful.key({ config.modkey,           }, "Down",   awful.tag.viewprev      ),
	awful.key({ config.modkey,	     }, "Left",  function() switch_client("next") end ),
	awful.key({ config.modkey,	     }, "Right", function() switch_client("prev") end ),
	awful.key({ config.modkey,	     }, "space",function() awful.layout.inc(config.layouts,1) end),
	awful.key({ config.modkey,	     }, "Return", function() awful.util.spawn(config.terminal) end),
	awful.key({ config.modkey,"Shift"    }, "Up", function() naughty.notify({text="what does i do"}) end),
	awful.key({ config.modkey,	     },"r",function() config.widgets.promptbox:run() end),
	awful.key({ config.modkey,	     },"x",function() lua_prompt() end)
)
config.keys.client=awful.util.table.join(
	awful.key({ config.modkey,	     },"q", function(c) c:kill() end),
	awful.key({ config.modkey,	     },"m", function(c) maximize_client(c) end)
)

config.mouse={}
config.mouse.client=awful.util.table.join(
	awful.button({ config.modkey },3,awful.mouse.client.resize),
	awful.button({ config.modkey },1,awful.mouse.client.move),
	awful.button({},1,function(c) client.focus=c; c:raise() end)
)
config.tags={}

config.widgets={}
config.widgets.text_clock=awful.widget.textclock()
config.widgets.systray=wibox.widget.systray()
config.widgets.promptbox=awful.widget.prompt()
config.widgets.tags={}

config.multiple_screens="duplicate"

function lua_prompt()
		awful.prompt.run({prompt="lua >"},
		config.widgets.promptbox.widget,
		awful.util.eval,nil,
		awful.util.getdir("cache").."/history_eval")
end
function maximize_client(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
end
function switch_client(args)
	if(args=="next" or args=="prev" ) then
		local idx=""
		if args=="next" then 
			idx=1 
		else
			idx=-1
		end
		awful.client.focus.byidx(idx)
		if client.focus then client.focus:raise() end 
	end

end

function get_default_tags(args)
        local s=args.screen or 1
        local t=args.tags or {"main","www"}
        return awful.tag(t,s,config.layouts[1])
end



if (screen.count()==1) then
	config.tags[1]=get_default_tags({screen=1,tags={"main","www"}})
	config.widgets.tags=awful.widget.taglist(1,awful.widget.taglist.filter.all,{})
	config.topbar_wibox={}
	config.topbar_wibox[1]=awful.wibox({position="top",screen=1})

	local left_widgets=wibox.layout.fixed.horizontal()
	left_widgets:add(config.widgets.tags)
	left_widgets:add(config.widgets.text_clock)
	left_widgets:add(config.widgets.systray)
	left_widgets:add(config.widgets.promptbox)
	local horizontal_widgets=wibox.layout.align.horizontal()
	horizontal_widgets:set_left(left_widgets)
	config.topbar_wibox[1]:set_widget(horizontal_widgets)
else
	if (config.multiple_screens=="duplicate") then
		--@TODO all screens same
	else
		--@TODO different contents to each screen
	end
end

root.keys(config.keys.global)

awful.rules.rules = {
	{ rule = { },
	properties= { 
		border_width=beautiful.border_width,
		border_color=beautiful.border_normal,
		focus=true,
		keys=config.keys.client,
		buttons = config.mouse.client
	}}
}

client.add_signal("manage",
		function (c,startup)
			c:add_signal("mouse::enter",
				function(c)
					if (awful.layout.get(c.screen)~=awful.layout.suit.magnifier and awful.client.focuse.filter(c)) then
						client.focus=c
					end
				end)
			if not startup then
				if not c.size_hints.user_position and not c.size_hints.program_position then
					awful.placement.no_overlap(c)
					awful.placement.no_offscreen(c)
				end
			end
		end)

client.add_signal("focus",function(c) c.border_color=beautiful.border_focus end)
client.add_signal("unfocus",function(c) c.border_color=beautiful.border_normal end)
