local beautiful = require("beautiful")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
--local tagz=require("z.tags")
--require("eminent")
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}
beautiful.init("/home/volcan/.config/awesome/theme/theme.lua")
naughty.notify({text="This is a testing config"})
local z = require("z")
--z.tags=require("z.tags")
local widgets_box=require("widgets_box")
--local z.tags=require("z.tags")

--local shifty=require("shifty")
local zapps = require ("zapps")
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--local wibox=z.wibox()
--local widget=z.wibox.widget
local config={}

if (screen.count() ==1) then
	config.screen=1
else
	config.screen=2
end
config.terminal="rxvt-unicode"
config.consoles={}
config.konsole=nil
config.konsole_ontop=false

config.modkey="Mod4"
config.layouts={
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.top,
	awful.layout.suit.max,
}
config.keys={}
config.keys.global=awful.util.table.join(
	awful.key({ config.modkey,       }, "Up",   awful.tag.viewnext	  ),
	awful.key({ config.modkey,       }, "Down",   awful.tag.viewprev      ),
	awful.key({ config.modkey,       }, "Left",  function() switch_client("next") end ),
	awful.key({ config.modkey,       }, "Right", function() switch_client("prev") end ),
    awful.key({ config.modkey,       },"z",function() z.network.connections.toggle() end ),
	awful.key({ config.modkey,       }, "space",function() awful.layout.inc(config.layouts,1) end),
	awful.key({ config.modkey,	     }, "Return", function() awful.util.spawn(config.terminal) end),
	awful.key({ config.modkey,	     },"r",function() config.widgets.promptbox:run() end),
	awful.key({ config.modkey,	     },"x",function() lua_prompt() end),
    --Window manipulations
    awful.key({ config.modkey,       },"\\",function() toggle_master() end),
    awful.key({ config.modkey,       },"]",function() awful.tag.incmwfact( 0.05) end),
    awful.key({ config.modkey,       },"[",function() awful.tag.incmwfact( -0.05) end),
    
    --Tag manipulation
    awful.key({ config.modkey,       },"n",function() add_tag({}) end),
    awful.key({ config.modkey,       },"d",function() delete_tag({}) end),

    --run or raise stuff
    awful.key({ config.modkey,       }, "s", function() tstog(); end), -- toggle tshark
    awful.key({ config.modkey,       }, "k", function() ktog();end), --toggle konsole
    awful.key({ config.modkey,       }, "d", function() tog("dmesg");end), --toggle dmesg
	--clipboard stuff
	awful.key({ config.modkey,     	     },"v", function() zapps.clips.next_select() end),
	awful.key({ config.modkey,           },"c", function() zapps.clips.clip() end),
    awful.key({ config.modkey,           }, "a",function() widgets_box.toggle() end),
    awful.key({ config.modkey,"Control"  }, "r",awesome.restart),
    awful.key({ config.modkey,"Control"  }, "Escape",awesome.quit)
)
config.keys.client=awful.util.table.join(
	awful.key({ config.modkey,	     },"q", function(c) c:kill() end),
	awful.key({ config.modkey,	     },"m", function(c) maximize_client(c) end),
	awful.key({ config.modkey,	     },"w", function(c) fullscreen_client(c) end),
	awful.key({ config.modkey,	     },"f", function(c) float_client(c,{}) end),
	awful.key({ config.modkey,	     },"t", function(c) top_client(c) end)
--	awful.key({ config.modkey,"Alt"  },"e", function(c) position_client(c,{}) end)
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
config.widgets.layoutbox={}
config.widgets.tags={}
config.widgets.tasks={}
config.widgets.networkalertmenu={
	{"toggle background capture", "xterm"}
}
config.widgets.alertmenu= awful.menu({ items = {
                                    { "network", config.widgets.networkalertmenu,beautiful.awesome_icon},
                                    }
                        })
config.widgets.alertmenulauncher= awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = config.widgets.alertmenu})



config.multiple_screens="duplicate"

function lua_prompt()
    awful.prompt.run({prompt="lua >"},
    config.widgets.promptbox.widget,
    awful.util.eval,nil,
    awful.util.getdir("cache").."/history_eval")
end
function toggle_master()
    naughty.notify({text="toggling master"})
    c=awful.client.next(1)
    --c:raise()
    --c:setslave()
    client.focus = c
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        awful.client.setslave(c)
    end
    --awful.client.focus=c
    --awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
end
function maximize_client(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
    c.ontop=true
    c.focus=true
end
function fullscreen_client(c)
    c.fullscreen = not c.fullscreen
--    c.ontop=true
--    c.focus=true
end
function position_client(c,args)
    if not args then return end
    local pos=args.pos
    if pos then 
        if pos=="top_left" then
            elseif pos=="top_right" then
            elseif pos=="bottom_left" then
            elseif pos=="bottom_right" then
            end
    end
end


function float_client(c,args)
	awful.client.floating.toggle(c)
	if(args=={}) then 
		return 
	else
	end
end
function top_client(c)
     c.ontop = not c.ontop  
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
function add_tag(args)
    local screen = args.screen or mouse.screen or 1
    local text   = args.name or "Aux"
    naughty.notify({text='screen: '..screen})
    --for i,v in ipairs(config.tags[screen]) do
--    for i,v in ipairs(awful.tag[screen]) do
--        naughty.notify({text="Tag num:"..i})
--        
--    end
    return awful.tag.add(text,{})
--    local tags=config.tags[screen]
--    local tag = awful.tag({"YOU MUMMA"})
--    tags:taglist_update(screen,tag,awful.widget.taglist.filter.all,config.mouse.tags)
--    awful.widget.taglist.taglist_update(screen,tag,awful.widget.taglist.filter.all,config.mouse.tags)
end
--[[[
    TODO Not working properly for new tags
    Search if tag already exist, return tag or new tag
    @args a table of arguments
    @args.name The tag we want
]]--
function move_to_tag(args)
    if not args then return end
    if not args.name then return end
    print(type(mouse.screen))

    --for i,v in ipairs(config.tags[mouse.screen]) do
    --for i,v in ipairs(awful.tag.selectedlist(mouse.screen)) do
    for i,v in pairs(awful.widget.taglist) do
        naughty.notify({text="Tag#"..i..v.name})
        if v.name==args.name then 
            naughty.notify({text='found tag corresponding to'})
            return v 
            end
        end
    return add_tag({name=args.name})
end
function delete_tag(args)
    --local current_tag=awful.tag.selected(mouse.screen)
    --current_tag:delete()
    awful.tag.delete()
end


if (screen.count()==1) then
	config.tags[1]=get_default_tags({screen=1,tags={"main","sys"}})
	config.widgets.tags=awful.widget.taglist(1,awful.widget.taglist.filter.all,config.mouse.tags)
	config.widgets.tasks=awful.widget.tasklist(1, awful.widget.tasklist.filter.currenttags,{})
	config.topbar_wibox={}
    config.widgets.layoutbox=awful.widget.layoutbox(s)
	config.topbar_wibox[1]=awful.wibox({position="top",screen=1})

	local left_widgets=wibox.layout.fixed.horizontal()
    left_widgets:add(config.widgets.layoutbox)
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
        focus = awful.client.focus.filter,
        keys=config.keys.client,
        buttons = config.mouse.client
    },
    callback=function(c)
        c.size_hints_honor = false
    end
    },
    --{ rule={ class="Icedove"},properties={tag = config.tags[1][2]},callback=function(c) naughty.notify({text='match icedove'})end},
    { rule={ class="Icedove"}, properties={tag = function() return move_to_tag({name='email'}) end} },
    { rule={ class="Iceweasel"}, properties={tag = function() return move_to_tag({name='www'}) end} },
    { rule={ class="Xephyr"}, properties={tag = function() return move_to_tag({name='awesome_test'}) end} },
    { rule={ class="Wireshark"}, properties={tag = function() return move_to_tag({name='wireshark'}) end} },
    { rule={ class="Eclipse"}, properties={tag = function() return move_to_tag({name='eclipse'}) end} },

    { rule={ name="^Gnuplot"},
      properties={
--		x=880,
--		y=20,
		floating=true,
		ontop=true,
--		width=400,
--		height=300
		},
	callback=function(c) 
		c:geometry({x=880,y=20,width=400,height=300})
		--awful.client.floating.set(c,true)
		--c:ontop(true)
	end
	} ,
	{ rule ={  name="konsole" },
	  properties={
		floating=true,
		ontop=true,
		width=1280,
		height=100,
		x=0,y=1180,
	   },
       callback=function(c) 
	    naughty.notify({text="Matched konsole rule"})
		c:geometry({x=0,y=700,width=1280,height=100} )
		config.konsole=c
		end
	},
--	{ rule ={},properties={},callback=function(c) end},
	{ rule ={ name="shark"},
	properties={
		floating=true,
		ontop=true
	},
	callback=function(c) 
		c:geometry({x=0,y=400,width=1280,height=400} )
	end}
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







client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

kons_ontop=false
kons=""

function ror(instance)
    local clients = client.get()
    for i, c in pairs(clients) do
        if(c.instance==instance) then
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
			c:raise()
			c.ontop=true
			client.focus = c
            return
        end
    end
	awful.util.spawn(instance)
end

function hide(instance)
	local clients = client.get()
	for i,c in pairs(clients) do 
		if(c.instance==instance) then
			c:lower()
			c.visible=false
			c.selected=false
			c.ontop=false
			c.minimized=true
		end
	end
end

--toggles the "konsole" - the game like consle
konsole_visible=false;
function ktog()
	konsole_visible=not konsole_visible; 
	if(konsole_visible) then
		ror("konsole");
	else
		hide("konsole");
	end
end
--toggles the tshark capture
tshark_visible=false
function tstog()
	tshark_visible= not tshark_visible;
	if (tshark_visible) then
		ror("shark");
	else 
		hide("shark");
	end
	
end


function tog(cmd)
	ror(cmd);
end


function msg(s)
	naughty.notify({text=s,timeout=15})
end

