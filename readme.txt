This is my awesome configurations.
If you want to use if feel free, I won't bother putting the GPL on it, but please mention me... I need some recognition for something.
Anyway, to get it to run as is you'll need:
* luanotify
    wget http://www3.telus.net/taj_khattra/luainotify/luainotify-20090818.tar.gz
    tar -xvzf  luainotify-20090818.tar.gz
    cd luainotify-20090818.tar.gz
    make
    install -D -s inotify.so /usr/lib/lua/5.1/inotify.so
* vicious
    cd ~/.config/awesome #Or where ever awesome configs are
    git clone http://git.sysphere.org/vicious

On my machine it's tested using awesome v3.4-742-gd2f06a1
if you just want to incorporate this into your config file, use:
    local z = require("z")
But note that for the time being it's using naughty for some error messages, and naughty uses beautiful, so this must be done AFTER beautiful.init()

beautiful.init("...")
local z = require("z")

There are a couple of scripts and links i use, which you'd have to figure out, to get the console like terminal, you'd need to have in your path a "konsole" command which starts a terminal with the name 'konsole' (urxvt -name 'konsole' in my case). 
to get the tshark monitor you'd need a 'shark' in your path, (which executes 'urxvt -name "shark" -e tshark -i wlan0' in my case). I hope i am not forgetting anything.

The most useful and unique part of this configuration is the heavy use of the z.panel, this is a "floating wibox" which can do all sorts of things.
It's a list of text widgets which you can update by setting payload, and scroll up or down it, pop up, hide, add items and add your own binding to.

This is done in the following way:
--First you define some panel:
local mpanel=z.panel({rows=40,wibox_params={x=1075,y=225,opacity=0.9}})
--Then, if you want to set a payload, you define a table of strings:
local mpayload={"One","Two","Three","A","B","C"}
--Then you set payload using:
listening_panel:set_payload({payload=mpayload})
--Than update the wibox using
mpanel:update()
--you can, show, hide or toggle the panel using:
mpanel:show()
mpanel:hide()
mpanel:toggle()

--if you want to append an element to an existing list, you can use:
mpanel:append("D")
--You can scroll up or down the panel,either through key bindings, or through implementing your own key grabber using:
mpanel:scroll("up")
mpanel:scroll("down")
mpanel:scroll("first")
mpanel:scroll("last")
--You can also pop a panel which by default will show for 5 seconds, or specify a timeout
mpanel:pop()
mpanel:pop({timeout=10})


There are loads of other features i would like to implement, and some i did partially implement already, if you care you can scroll through my commit histories to find loads of little gems i wrote over the years.

There's a lot of room for improvment, but i would love it if ANYONE AT ALL finds this useful.

bugs:
z.panel.lua panel.append() does not limit the amount of elements a panel may contain, this means that each call to it will make the panel grow a tiny bit, after long enough it will use significant amounts of memory (i haven't tested this, but in theory this should take a long time or many many calls to append) I need to put a cap on that

z.panel.lua Most methods just implement text= to modify existing elements, and at the moment it's all i need, but I would like to be able to append widgets and tables and values for graphs too. This will now require a way to incorporate the wierdass layout implementation.

logs.panel.lua could do with slight improvement to the logging functions

networkz.lua should color and handle to alerts better (no need to popup for localhost>localhost etc (maybe some fine tuning of my tcpspy is in order but i like seing all connections regardsless)

Better multiple screens handling

todo:
make a video of some of this in action, 
make a simple webpage on github
make networz.lua handle other netstat arguments
make a netstat -lptu panel
allow to pin panels so they don't disapear (mostly in networkz.lua)
make a reference table for consistent keyhandling in networkz
make the best ever hacker desktop!!!

