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
local keygrabber=keygrabber
local networkz=require("networkz")
module("logz")
local config={}
config.quiet=false
config.panel=nil
config.update_time=1
config.logs={
	auth={
		file="/var/log/auth.log",
		func=function(n,e) return default_syslog_format(n,e,{color='red'}) end
	},

	syslog={
		file="/var/log/syslog",
		func=function(n,e)
			local lines=utilz.split(e,"\n")
			local ret=""
			for idx,line in ipairs(lines) do
				if string.find(line,"registration state changed:") then
				elseif string.find(line,"tcpspy") then
					local l=chop_syslog_line(line)
					networkz.alert(l)
				elseif line~="" and line ~=nil and line~="^%s+$" then
					local fn=config.logs[n].file
					local msg=chop_syslog_line(line)
					msg=awful.util.escape(msg)
					local l="<span color='white'>"..fn.."</span><span color='blue'>"..msg.."</span>..\n"
					ret=ret..l
				end
			end
			ret=ret:sub(1,#ret-1)
			return ret
		end
	},
	messages={
		file="/var/log/messages",
		func=function(n,e) local ret=default_syslog_format(n,e); return ret end
	},
	snort={
		file="/var/log/snort/alert",
		func=function(n,e) return any_log_format(n,e) end
	},
	xsession={
		file="/home/volcan/.xsession-errors",
		func=function(n,e) return any_log_format(n,e,{color='grey'}) end
	},
	user={
		file="/var/log/user.log",
		func=function(n,e) return default_syslog_format(n,e,{color='red'}) end
	},
	wvdialconf={
                file="/var/log/wvdialconf.log",
                func=function(n,e) return any_log_format(n,e) end
        },
        kern={
                file="/var/log/kern.log",
                func=function(n,e) return default_syslog_format(n,e,{color='red'}) end
        },
        debug={
                file="/var/log/debug",
                --func=function(n,e) return default_syslog_format(n,e,{color='orange'}) end
		func=function(n,e)
                        local lines=utilz.split(e,"\n")
                        local ret=""
                        for idx,line in ipairs(lines) do
                                if string.find(line,"registration state changed:") then
                                elseif line~="" and line ~=nil and line~="^%s+$" then
                                        local fn=config.logs[n].file
                                        local msg=chop_syslog_line(line)
                                        msg=awful.util.escape(msg)
                                        local l="<span color='white'>"..fn.."</span><span color='orange'>"..msg.."</span>..\n"
                                        ret=ret..l
                                end
                        end
                        ret=ret:sub(1,#ret-1)
                        return ret
                end
        },
	

}

function any_log_format(n,e,args)
                        local color="#555555"
                        if args then
                                color=args.color or color
                        end
                        local ret=""
                        local fn=config.logs[n].file
                        if(e==nil) then return end

                        local lines=utilz.split(e,"\n")
                        for i,l in ipairs(lines) do
                                local txt=l
                                if (txt~="" and txt~=nil and txt~="^%s+$") then
                                        txt=awful.util.escape(txt)
                                        ret=ret.."<span color='white'>"..fn.."</span>".."<span color='"..color.."'>"..txt.."</span>\n"
                                end
                        end
                        local ret=ret:sub(1,#ret-1)
                        return ret
end

--[[ takes a line from syslog type format and remove the date ]]--
function chop_syslog_line(l)
	ret=l:sub(16)
	return ret
end
function default_syslog_format(n,e,args)

			local color="#2212bb"
			if args then 
				color=args.color or color
			end
                        local ret=""
                        local fn=config.logs[n].file
                        if(e==nil) then return end

                        local lines=utilz.split(e,"\n")
                        for i,l in ipairs(lines) do
                                local txt=l:sub(16)
                                if (txt~="" and txt~=nil and txt~="^%s+$") then
					txt=awful.util.escape(txt)
                                        ret=ret.."<span color='white'>"..fn.."</span>".."<span color='"..color.."'>"..txt.."</span>\n"
                                end
                        end
                        local ret=ret:sub(1,#ret-1)
                        return ret
end 



function watch_logs()
	--if config.quiet==true then return end
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
	config.panel:resize({max_height=200})
	if(config.quiet==false) then config.panel:pop({timeout=3}) end
end
function set_logs()
	local err_no,err_str
        inot,err_no,err_str = inotify.init(true)
        for name,log in pairs(config.logs) do
		local log=config.logs[name];
		local f=io.open(log.file)
		local t=f:read("*a")
		f:close()
		config.logs[name].length=#t
		log.length=#t
		--naughty.notify({text="<span color='red'>"..log.length.."</span>",timeout=0})
	        log.wd,err_no,err_str=inot:add_watch(log.file,{"IN_MODIFY"})
	end 	

end

function set_widget_text()
        if (config.quiet==false) then
                logs_widget.text="<span color='white'>logs:</span><span color='green'>on</span>|"
        else
                logs_widget.text="<span color='white'>logs:</span><span color='red'>off</span>|"
        end
end

function toggle()
	if(config.quiet==true) then
		enable()
	else
		disable()
	end
end
function enable()
	config.quiet=false
	set_widget_text()
end
function disable()
	config.quiet=true
	config.panel:hide()
	set_widget_text()
end

function key_listener(mod_keys,key,action)
	--naughty.notify({text=key.." action:"..action})
	if (key=="Up" or key=="j") and action=="press" then 
		config.panel:scroll({direction="up"})
		config.panel:resize({max_height=600})
	end
	if (key=="Down" or key=="k") and action=="press" then  
                config.panel:scroll({direction="down"})
                config.panel:resize({max_height=600})
	end
	return true
end


logs_widget=widget({type="textbox"})
function init()
	set_widget_text()
	set_logs()
        logs_widget:buttons(
                awful.util.table.join(
                        awful.button({},1,function() toggle() end)
                )
        )
	logs_widget:add_signal("mouse::enter",function() 
		config.panel:show()
		if(config.panel.hide_timer ~= nil) then 
			config.panel.hide_timer:stop()
			config.panel.hide_timer=nil 
		end
		keygrabber.run(function(m,k,a) return key_listener(m,k,a) end)
	end)
	logs_widget:add_signal("mouse::leave",function() 
		--if(config.panel.hide_timer ~= nil) then  config.panel.hide_timer:stop() end
		config.panel:hide() 
		keygrabber.stop()
	end)
end



function main()
	config.panel=panelz.Panel.new({rows=3})
	config.panel.wibox.width=600
	config.panel.wibox.height=10
	config.panel.wibox.x=675
	config.panel.wibox.orientation="east"
	config.panel.wibox.opacity=0.95
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
init()
