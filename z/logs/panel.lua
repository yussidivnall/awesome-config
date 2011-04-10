local z=z
local inotify=require("inotify")
local naughty=require("naughty")
local awful=require("awful")
local pairs=pairs
local ipairs=ipairs
local io=io
local timer=timer
local wibox=wibox
local keygrabber=keygrabber
panel={}
widget={}
module("z.logs.panel")

config={}
config.logs={
        auth={
                file="/var/log/auth.log",
                func=function(n,e) return default_syslog_format(n,e,{color='red'}) end
        },
        messages={
                file="/var/log/messages",
                func=function(n,e) return default_syslog_format(n,e,{color='red'}) end
        },
	snort={
		file="/var/log/snort/alert",
		func=function(n,e) return plain_log_format(n,e,{color='blue'}) end
	}

}
config.update_time=1
config.quiet=false
function plain_log_format(n,e,args)
	if(e==nil) then return end
	local color=args.color or "#2212bb"
	local ret=""
	local file_name=config.logs[n].file
	local lines=z.utils.split(e,"\n")
	for i,l in ipairs(lines) do
		local txt=l
		if (txt~="" and txt~=nil and txt~="^%s+$") then
			txt=awful.util.escape(txt)
			ret=ret.."<span color='#ffffff'>"..file_name.."</span>".."<span color='"..color.."'>"..txt.."</span>\n"
		end
	end
	local ret=ret:sub(1,#ret-1)
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

                        local lines=z.utils.split(e,"\n")
                        for i,l in ipairs(lines) do
                                local txt=l:sub(16)
                                if (txt~="" and txt~=nil and txt~="^%s+$") then
                                        txt=awful.util.escape(txt)
                                        ret=ret.."<span color='#ffffff'>"..fn.."</span>".."<span color='"..color.."'>"..txt.."</span>\n"
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
                               if(event.wd==log.wd) then updated(name) end
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
        --naughty.notify({text="<span color='yellow'>"..log.length.."</span>"..name})
        local diff=l:sub(log.length+1,#l-1)
        local msg=parse(name,diff)

	if diff=="(\r?\n)%s*\r?\n" then return end
        if diff==nil then return end
        local txt=msg
        if (txt==nil or txt=="") then return end
	for idx,ln in ipairs(z.utils.split(txt,"\n"))do
		panel:append(ln)
	end
	if not config.quiet then
		panel:pop({})
	end
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

function key_listener(mod_keys_,key,action)
	if(key=="DOWN" or key=="k") and action=="press" then
		panel:scroll("down")
	end
	if(key=="UP" or key =="j") and action=="press" then
		panel:scroll("up")
	end
	return true
end



--[[ Widget setting ]]--
function set_widget()
	if(config.quiet==false) then 
		widget:set_markup("log:<span color='#00aa00'>on</span>")	
	else
		widget:set_markup("log:<span color='#aa0000'>off</span>")
	end
	return true
end
function toggle_widget()
	config.quiet=not config.quiet
	set_widget()
end
function init_widget()
        widget=wibox.widget.textbox({})
        set_widget()
        widget:buttons(
                awful.button({},1,function() 
			toggle_widget() 
		end )
        )
	widget:connect_signal("mouse::enter",function() 
		keygrabber.run(function(m,k,a) return key_listener(m,k,a) end)
		panel.pop_on=false
		panel:show()
		if(panel.pop_timer~=nil) then
			if (panel.pop_timer.started==true) then panel.pop_timer:stop()end
			panel.pop_timer=nil
		end
	end)
	widget:connect_signal("mouse::leave",function() 
		panel:hide()
		keygrabber.stop()
	end)
end



--[[ ]]--
function init()
	init_widget()

	panel=z.panel({wibox_params={x=575,y=30,width=700},rows=5})
	local err_no,errstr
	inot,err_no,errstr=inotify.init(ture)
		for name,log in pairs(config.logs) do
                	set_logs(name)
                	log.wd,err_no,err_str=inot:add_watch(log.file,{"IN_MODIFY"})
        	end
        local tmr=timer({timeout=config.update_time})
        tmr:connect_signal("timeout",function() watch_logs() end)
        tmr:start()

	
end
init()
