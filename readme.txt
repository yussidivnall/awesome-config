This is the sandbox configs i use for my awesome WM.
It's pretty neat i think, but needs a lot of polishing, it relies heavily on panelz.lua
at some point i will need to completely rewrite panelz.lua as it's quite buggy, it's inconsistent at times, and has some minor memory leaks, but it works and it gives me what i need.

to get the netstat update you need to be runing the update_netstat.sh, prefarably as root.

note that this isn't exatly the rc.lua i'm using, it a minimal rc i use for testing.

bugs:
panelz.lua Panel.append() does not limit the amount of elements a panel may contain, this means that each call to it will make the panel grow a tiny bit, after long enough it will use significant amounts of memory (i haven't tested this, but in theory this should take a long time or many many calls to append) I need to put a cap on that

panelz.lua Most methods just implement text= to modify existing elements, and at the moment it's all i need, but I would like to be able to append widgets and tables and values for graphs too.

networkz.lua, needs to implement inotify to make sure you don't update the netstat wibox needlessly

logz.lua could do with slight improvement to the logging functions

networkz.lua should color and handle to alerts better (no need to popup for localhost>localhost etc (maybe some fine tuning of my tcpspy is in order but i like seing all connections regardsless)

if your reading this... then... well someone's interested i guess

todo:
make a video of some of this in action, 
make a simple webpage on github
make networz.lua handle other netstat arguments
make a netstat -lptu panel
allow to pin panels so they don't disapear (mostly in networkz.lua)
make a reference table for consistent keyhandling in networkz
make the best ever hacker desktop!!!
