local io=io;
local os=os
local table=table;
local widget=widget;
local inotify=require("inotify")
local naughty=naughty
--local naughty=require("naughty")
local awful=require("awful")
local pairs=pairs
local timer=timer
local ipairs=ipairs
local panelz=require("panelz")
local string=string
local utilz=require("utilz")
module("logz")
local config={}
config.panel=nil
config.update_time=1
config.logs={
	auth={
		file="/var/log/auth.log",
		func=function(n,e)
			local ret=""
			local fn=config.logs[n].file
			if(e==nil) then return end

			local lines=utilz.split(e,"\n")
			for i,l in ipairs(lines) do
				local txt=l:sub(16)
				if (txt~="" and txt~=nil and txt~="^%s+$") then 
					ret=ret.."<span color='white'>"..fn.."</span>".."<span color='#aa0011'>"..txt.."</span>\n"
				end
			end
			ret=ret:sub(1,#ret-1)
			return ret
		end
	},
	syslog={
		file="/var/log/syslog",
		func=function(n,e)
                        local ret=""
                        local fn=config.logs[n].file
                        if(e==nil or e=="") then return end
                        local lines=utilz.split(e,"\n")
                        for i,l in ipairs(lines) do
                                local txt=l:sub(16)
                                if (txt~="" and txt~=nil and txt~="^%s+$") then
					txt=awful.util.escape(txt)
                                        ret=ret.."<span color='white'>"..fn.."</span>".."<span color='#aa0011'>\'"..txt.."\'</span>\n"
                                end
                        end
                        ret=ret:sub(1,#ret-1)
                        return ret
                end
	},
	messages={
		file="/var/log/messages",
		func=function(n,e) local ret=default_syslog_format(n,e); return ret end
	}
}
function test(a)
	naughty.notify({text=a})
end
function default_syslog_format(n,e)
                        local ret=""
                        local fn=config.logs[n].file
                        if(e==nil) then return end

                        local lines=utilz.split(e,"\n")
                        for i,l in ipairs(lines) do
                                local txt=l:sub(16)
                                if (txt~="" and txt~=nil and txt~="^%s+$") then
					txt=awful.util.escape(txt)
                                        ret=ret.."<span color='white'>"..fn.."</span>".."<span color='#aa0011'>"..txt.."</span>\n"
                                end
                        end
                        local ret=ret:sub(1,#ret-1)
                        return ret
end 



function watch_logs()
	local events,nread,err_no,err_str = inot:nbread()
	if events then
		for idx,event in ipairs(events) do
			for name,log in pairs(config.logs)do
				updated(name)
			end
		end
	end
end
function parse(name,elements)
	ret=""
	if config.logs[name].func~= nil then
		ret=config.logs[name].func(name,elements)
	else ret=config.logs[name].file.." "..elements
	end
	return ret

end



function updated(name)
	local log = config.logs[name]
	local f=io.open(log.file)
	local l=f:read("*a")
	f:close()
	--naughty.notify({text="<span color='yellow'>"..log.length.."</span>"})
	local diff=l:sub(log.length+1,#l-1)
	local msg=parse(name,diff)

	if diff=="(\r?\n)%s*\r?\n" then return end
	if diff==nil then return end
	--naughty.notify({text=diff})
	--config.panel:show()
	--txt="<span color='yellow'>"..log.file.."</span>"..msg
	local txt=msg
	if (txt==nil or txt=="") then return end
	--naughty.notify({text="In updated:"..txt})
	config.panel:append({text=txt})
	config.logs[name].length=#l
	config.panel:resize()
	config.panel:pop({timeout=10})
end
function set_logs(n)
	log=config.logs[n];
	local f=io.open(log.file)
	local t=f:read("*a")
	f:close()
	config.logs[n].length=#t
	log.length=#t
	--naughty.notify({text="<span color='red'>"..log.length.."</span>",timeout=0})
end

function main()
	config.panel=panelz.Panel.new({rows=5})
	config.panel.wibox.width=800
	config.panel.wibox.height=300
	--config.panel.wibox.visible=true
	local err_no,err_str
	inot,err_no,err_str = inotify.init(true)
	for name,log in pairs(config.logs) do
		set_logs(name)
		log.wd,err_no,err_str=inot:add_watch(log.file,{"IN_MODIFY"})
	end
	local tmr=timer({timeout=config.update_time})
	tmr:add_signal("timeout",function() watch_logs() end)
	tmr:start()
end
main()
