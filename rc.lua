--[[[
    I Am never sure which of these i need as local a=require("a) and which just require("a")
    This is just my rc.
]]--
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
beautiful.init("/home/volcan/Desktop/development/awesome/testing/theme/theme.lua")
naughty.notify({text="This is a testing config"})

--Sometimes it helps if you require something after beautiful init, Naughty does that
local z = require("z")

--z.tags=require("z.tags")
local widgets_box=require("widgets_box")
--local z.tags=require("z.tags")
local tags=require("z.tags")
--local shifty=require("shifty")
local zapps = require ("zapps")
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--local wibox=z.wibox()
--local widget=z.wibox.widget

--General configurations
local config={}
--Screens settings
local screens={}
--Widgets which are shared on all screens
local shared={}
shared.systray=wibox.widget.systray()
shared.promptbox=awful.widget.prompt()

local keys={}
keys.global={}
keys.client={}

local buttons={}
buttons.client={}
buttons.taglist={}
buttons.tasklist={}

config.terminal="rxvt-unicode"
config.konsole=nil
config.konsole_ontop=false
config.modkey="Mod4"
config.menukey="Mod3"
config.layouts={
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

config.geometry={}
config.geometry.drawable={x=0,y=15,width=800,height=600}
--Corner geometry
config.geometry.top_left_corner={x=config.geometry.drawable.x,y=20,width=300,height=300}
config.geometry.top_right_corner={x=config.geometry.drawable.width-300,y=20,width=300,height=300}
--Pane Geometry
config.geometry.left_pane={x=0,y=20,width=200,height=config.geometry.drawable.height}
config.geometry.right_pane={x=config.geometry.drawable.width-200,y=20,width=200,height=config.geometry.drawable.height}
config.geometry.top_pane={x=0,y=20,width=config.geometry.drawable.width,height=200}
config.geometry.bottom_pane={x=0,y=config.geometry.drawable.height-200,width=config.geometry.drawable.width,height=200}


keys.global=awful.util.table.join(
    awful.key({ config.modkey,       }, "z",function() naughty.notify({text='menu key'})end),
	awful.key({ config.modkey,       }, "Up",   awful.tag.viewnext	  ),
	awful.key({ config.modkey,       }, "Down",   awful.tag.viewprev      ),
	awful.key({ config.modkey,       }, "Left",  function() switch_client("next") end ),
	awful.key({ config.modkey,       }, "Right", function() switch_client("prev") end ),
    awful.key({ config.modkey,       },"z",function() z.network.connections.toggle() end ),
	awful.key({ config.modkey,       }, "space",function() awful.layout.inc(config.layouts,1) end),
	awful.key({ config.modkey,	     }, "Return", function() awful.util.spawn(config.terminal) end),
	awful.key({ config.modkey,	     },"r",function() shared.promptbox:run() end),
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
--    awful.key({ config.modkey,           }, "a",function() widgets_box.toggle() end),
    awful.key({ config.modkey,"Control"  }, "r",awesome.restart),
    awful.key({ config.modkey,"Control"  }, "Escape",awesome.quit),
    --volume stuff
    awful.key({                          }, "XF86AudioRaiseVolume",function() z.media.volume_up() end),
    awful.key({                          }, "XF86AudioLowerVolume",function() z.media.volume_down() end)
)
--[[Client keys ]]--
keys.client=awful.util.table.join(
	awful.key({ config.modkey,	     },"q", function(c) c:kill() end),
	awful.key({ config.modkey,	     },"m", function(c) maximize_client(c) end),
	awful.key({ config.modkey,	     },"w", function(c) fullscreen_client(c) end),
	awful.key({ config.modkey,	     },"f", function(c) float_client(c,{}) end),
	awful.key({ config.modkey,	     },"t", function(c) top_client(c) end),
    awful.key({ config.modkey,       },"o", awful.client.movetoscreen),    
    --Client position settings , Menukey
    --GAME LIKE, PANE 
    awful.key({ config.menukey,},"w", function(c) c:geometry(config.geometry.top_pane ) end), 
    awful.key({ config.menukey,},"x", function(c) c:geometry(config.geometry.bottom_pane) end), 
    awful.key({ config.menukey,},"a", function(c) c:geometry(config.geometry.left_pane) end),
    awful.key({ config.menukey,},"d", function(c) c:geometry(config.geometry.right_pane) end), 
    --GAME LIKE, CORNERS
    awful.key({ config.menukey,},"e", function(c) c:geometry(config.geometry.top_right_corner) end), 
    awful.key({ config.menukey,},"q", function(c) c:geometry(config.geometry.top_left_corner) end), 
    --@TODO Add bottom corners
    --cLIent resizing
    awful.key({ config.modkey,      },"=", function(c)resize_client(c,0.2) end),
    awful.key({ config.modkey,      },"-", function(c)resize_client(c,-0.2) end),
    --Client to tags
    awful.key({ config.menukey,      },"<", function(c) c:geometry(config.geometry.top_right_corner) end), 
    awful.key({ config.menukey,      },">", function(c) c:geometry(config.geometry.top_left_corner) end)
)

buttons.client=awful.util.table.join(
	awful.button({ config.modkey },3,awful.mouse.client.resize),
	awful.button({ config.modkey },1,awful.mouse.client.move),
	awful.button({},1,function(c) client.focus=c; c:raise() end)
)
buttons.taglist=awful.util.table.join(
	awful.button({ config.modkey },3,awful.client.movetotag)
)

config.tags={}

config.widgets={}
config.widgets.text_clock=awful.widget.textclock()

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
    shared.promptbox.widget,
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
function position_client(c,args)
end
function resize_client(c,fact)
    if(not c) then return end

    local factor=fact
    local geom=c:geometry()
--    if(c.floating==true) then
       geom["width"]=geom["width"] + geom["width"]*factor
       geom["height"]=geom["height"] + geom["height"]*factor
       c:geometry(geom)
--    else

--    end
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
    return awful.tag.add(text,{})
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
    for i,v in ipairs(screens[mouse.screen].tags) do
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


function allocate_screens(args)
    if(config.multiple_screens=="duplicate") then
        --Only create these once:
        for s=1,screen.count() do
            screens[s]={}
            screens[s].tags=get_default_tags({screen=s,tags={"main","sys"}})
            screens[s].widgets={} 
            screens[s].widgets.taglist=awful.widget.taglist(s,awful.widget.taglist.filter.all,buttons.taglist)
            screens[s].widgets.tasklist=awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags,{})
            screens[s].widgets.layoutbox=awful.widget.layoutbox(s)
            screens[s].wiboxes={}
            screens[s].wiboxes[1]=awful.wibox({position="top",screen=s})

            local left_widgets=wibox.layout.fixed.horizontal()
            left_widgets:add(screens[s].widgets.layoutbox)
            left_widgets:add(screens[s].widgets.taglist)
            left_widgets:add(shared.promptbox)
            left_widgets:add(screens[s].widgets.tasklist)
            local right_widgets=wibox.layout.fixed.horizontal()
            right_widgets:add(awful.widget.textclock())
            right_widgets:add(shared.systray)
            right_widgets:add(z.logs.panel.widget)
            local horizontal_widgets=wibox.layout.align.horizontal()
            horizontal_widgets:set_left(left_widgets)
            horizontal_widgets:set_right(right_widgets)
            screens[s].wiboxes[1]:set_widget(horizontal_widgets)
        end
    else
    end
end
allocate_screens(args)


--[[ Testing lpanel ]]--
local pan=z.lpanel({})
pan:show()

root.keys(keys.global)
awful.rules.rules = {
    { rule = { },
    properties= { 
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        keys=keys.client,
        buttons = buttons.client
    },
    callback=function(c)
        c.size_hints_honor = false
    end
    },
    --{ rule={ class="Icedove"},properties={tag = config.tags[1][2]},callback=function(c) naughty.notify({text='match icedove'})end},
    { rule={ class="Icedove",instance="Mail"}, properties={tag = function() return move_to_tag({name='email'}) end} },
    { rule={ class="Iceweasel",instance="Navigator"}, properties={tag = function() return move_to_tag({name='www'}) end} },
    { rule={ class="emulator-arm",instance="emulator-arm"}, properties={tag = function() return move_to_tag({name='and-emu'}) end} },
--    { rule={ class="Xephyr"}, properties={tag = function() return move_to_tag({name='awesome_test'}) end} },

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
		ontop=true,
        opacity=0.5
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


client.connect_signal("focus", function(c) 
    c.border_color = beautiful.border_focus 
--    c.opacity=1.0
end)
client.connect_signal("unfocus", function(c) 
    c.border_color = beautiful.border_normal 
--    c.opacity=0.75
end)

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
