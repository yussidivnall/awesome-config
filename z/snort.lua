local inotify=require("inotify")
local naughty=naughty
local io=io
local timer=timer
local ipairs=ipairs
local z=z
module("snort")
local config={}
config.log_path="/var/log/snort/"
config.filename=""
config.lastdump={}
config.update_timer=5
config.enabled=true
function watch()
	if not config.enabled then return end
	local events,nread,err_no,err_str = inot:nbread()
	if events then
		naughty.notify({text=event})
		f,d=get_dumpfile()
		--TODO put lines in diff to table
		diff=z.utils.diff(d,config.lastdump)
		for idx,l in ipairs(diff) do
			naughty.notify({text=l})
		end
		config.lastdump=d
	end
end
function get_dumpfile()
	f=io.popen("ls -tru "..config.log_path.."tcpdump.log*|tail -1")
	filename=f:read("*a")
	f:close()
	f=io.popen("tshark -Nn -r "..filename)
	dump=f:read("*a")
	f:close()
	return filename,z.utils.split(dump,"\n")
end

function register_inotify()
	local err_no,err_msg
	inot,err_no,err_msg=inotify.init(true)
	wd,err_no,err_msg=inot:add_watch(config.log_path , {"IN_MODIFY"})
	local tmr=timer({timeout=config.update_timer})
	tmr:connect_signal("timeout",function() watch() end)
	tmr:start()
end



function init()
	config.filename,config.lastdump=get_dumpfile()
	register_inotify()
end
init()
