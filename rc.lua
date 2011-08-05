-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
beautiful.init("/usr/local/share/awesome/themes/default/theme.lua")
-- Notification library
require("naughty")
require("z")
require ("zapps")
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
local wibox=wibox
local widget=wibox.widget
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
	awful.key({ config.modkey,	     }, "space",function() awful.layout.inc(config.layouts,1);naughty.notify({text=awful.layout.get(screen):getname()}) end),
	awful.key({ config.modkey,	     }, "Return", function() awful.util.spawn(config.terminal) end),
	awful.key({ config.modkey,	     },"r",function() config.widgets.promptbox:run() end),
	awful.key({ config.modkey,	     },"x",function() lua_prompt() end),
	--monitor stuff
	awful.key({ config.modkey,	     },"@",function() z.network.connections.show() end ),
	--clipboard stuff
	awful.key({ config.modkey,     	     },"p", function() 
						    	zapps.clips.next_select()
						    end),
	awful.key({ config.modkey,           },"c", function()
                                                        zapps.clips.clip()
                                                    end),
	
key({ config.modkey,"Control"  }, "r",awesome.restart),
        awful.key({ config.modkey,"Control"  }, "Escape",awesome.quit)
)
config.keys.client=awful.util.table.join(
	awful.key({ config.modkey,	     },"q", function(c) c:kill() end),
	awful.key({ config.modkey,	     },"m", function(c) maximize_client(c) end),
	awful.key({ config.modkey,	     },"k", function(c) float_client(c,{}) end)
)

config.mouse={}
config.mouse.client=awful.util.table.join(
	awful.button({ config.modkey },3,awful.mouse.client.resize),
	awful.button({ config.modkey },1,awful.mouse.client.move),
	awful.button({},1,function(c) client.focus=c; c:raise() end)
)
config.mouse.tags=awful.util.table.join(
	awful.button({ config.modkey },3,awful.client.movetotag)
)

config.tags={}

config.widgets={}
config.widgets.text_clock=awful.widget.textclock()
config.widgets.systray=wibox.widget.systray()
config.widgets.promptbox=awful.widget.prompt()
config.widgets.tags={}
config.widgets.tasks={}
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
	    c.ontop=true
	    c.focus=true
end
function float_client(c,args)
	awful.client.floating.toggle(c)
	if(args=={}) then 
		return 
	else
	end
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
	        if not c:isvisible() then
                	awful.tag.viewonly(c:tags()[1])
                end

	end

end

function get_default_tags(args)
        local s=args.screen or 1
        local t=args.tags or {"main","www"}
        return awful.tag(t,s,config.layouts[1])
end



if (screen.count()==1) then
	config.tags[1]=get_default_tags({screen=1,tags={"main","www","test1","test2","test3"}})
	config.widgets.tags=awful.widget.taglist(1,awful.widget.taglist.filter.all,config.mouse.tags)
	config.widgets.tasks=awful.widget.tasklist(1, awful.widget.tasklist.filter.currenttags,{})
	config.topbar_wibox={}
	config.topbar_wibox[1]=awful.wibox({position="top",screen=1})

	local left_widgets=wibox.layout.fixed.horizontal()
	left_widgets:add(config.widgets.tags)
	left_widgets:add(config.widgets.promptbox)
	left_widgets:add(config.widgets.tasks)
	local right_widgets=wibox.layout.fixed.horizontal()
	right_widgets:add(config.widgets.text_clock)
	right_widgets:add(config.widgets.systray)
	right_widgets:add(z.logs.panel.widget)
	local horizontal_widgets=wibox.layout.align.horizontal()
	horizontal_widgets:set_left(left_widgets)
	horizontal_widgets:set_right(right_widgets)
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
		border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = true,
		keys=config.keys.client,
		buttons = config.mouse.client
	}}
}

client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)


--Tests randmoness follows:
---------------------------
--os.execute("xclip -o > /tmp/clip")
--local f=io.open("/tmp/clip")
--if(f) then
--	naughty.notify("File opened!")
--
--	io.close(f)
--end
--local txt=f:read("*l")
--zapps.panel_switcher.clip("hlkjhjk")
zapps.panel_switcher.show_buffer()
zapps.panel_switcher.handle_paste()
---------------------------
--local f=io.popen("xclip -o")

--f:close()



client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)



