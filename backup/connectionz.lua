
local table=table
local string=string
local io=io
local os=os
local pairs=pairs
local ipairs=ipairs
local timer=timer
local inotify=require("inotify")
local utilz=require("utilz")
local naughty = require("naughty")
local awful=require("awful")
module("connectionz")
local inot=nil
local config={}
config.watch={
	["TEST"]={file="/tmp/test",wd=nil},
	["tcp"]={file="/proc/net/tcp",wd=nil},
	["udp"]={file="/proc/net/udp",wd=nil},
	["tcp6"]={file="/proc/net/tcp6",wd=nil},
	["udp6"]={file="/proc/net/udp6",wd=nil},
}
config.timeout=1

objects={}
objects.timer=nil
--This was an experiment to see if i can take this from the kernel
--It seems like inotify (or maybe just luanotify) can't recieve
-- "IN_MODIFY" from procfs (or maybe procfs don't)
--

function watch()
	local events,nread,err_no,err_str=inot:nbread()
	if events then
	--	naughty.notify({text="Something happened"})
		for idx,event in ipairs(events) do
			naughty.notify({text=event.name})
		end
	end
end

function main()
	local err_no,err_str
	inot,err_no,err_str = inotify.init(true)
	naughty.notify({text=err_str})
	for proto,dat in pairs(config.watch) do
		naughty.notify({text=dat.file})
		dat.wd,err_no,err_str=inot:add_watch(dat.file,{"IN_MODIFY","IN_ACCESS"})
		naughty.notify({text=err_no})
		--config.watch[proto].wd,err_no,err_str=inot:add_watch(config.watch[proto].file,{"IN_MODIFY"})
	end
	objects.timer=timer({timeout=config.timeout})
	objects.timer:connect_signal("timeout",function() watch() end)
	objects.timer:start()
end
function init()
end

main()
init()
