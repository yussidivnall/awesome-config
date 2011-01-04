local io=io
local os=os
local table=table
local ipairs=ipairs
local widget=wibox.widget
local wibox=wibox
local timer=timer
local naughty=require("naughty")
local awful=require("awful")
local utilz=require("utilz")
local panelz=require("panelz")

module("netstatz")
local config={}
config.netstat_panel = nil
config.netstat_args=" -Wutpeed"
config.netstat_timer=nil
config.netstat_refresh_rate=1
config.netstat_header_widget=wibox.widget.textbox()
config.netstat_footer_widget=wibox.widget.textbox()
config.netstat_colors={
        ["ESTABLISHED"]='green',
        ["SYN_SENT"]='yellow',
        ["SYN_RECV"]='#aaaa00',
        ["FIN_WAIT1"]='orange',
        ["FIN_WAIT2"]='orange',
        ["TIME_WAIT"]='blue',
        ["CLOSE"]='grey',
        ["CLOSE_WAIT"]='grey',
        ["LAST_ACK"]='grey',
        ["LISTEN"]='red',
        ["CLOSING"]='grey',
        ["UNKNOWN"]='pink',
}
config.monitor=false
config.selected_wibox_color="#aa0ba9"
config.unselected_wibox_color="#0a0ba9"


function reset_colors()
	config.netstat_panel.wibox.border_color=config.unselected_wibox_color
end

function highlight(selection)

end

function color_line_by_state(state,line)
        ret="<span color='"..config.netstat_colors[state].."'>"..line.."</span>"
        return ret
end

function update_netstat_panel(d,txt)
	config.netstat_header_widget.text="netstat "..config.netstat_args.."\n"..d
        local panel_output={}
        local lines=utilz.split(txt,"\n")
        for idx,line in ipairs(lines) do
                if (line=="" or line==nil) then naughty.notify({text="empty line"})end
                words=utilz.split(line,"%s+")
                local protocol=words[1]
                local rcv_que=words[2]
                local trx_que=words[3]
                local local_address=utilz.split(words[4],":")[1]
                local local_port=utilz.split(words[4],":")[2]
                local remote_address=utilz.split(words[5],":")[1]
                local remote_port=utilz.split(words[5],":")[2]
                local state=words[6]
                local program=words[9]
                out_line={text=color_line_by_state(state,program.." "..remote_address..":"..remote_port.."|tx:"..rcv_que.."|rx:"..trx_que)}
                table.insert(panel_output,out_line)
                --naughty.notify({text=out_line})
        end
        config.netstat_panel:update(panel_output)
end

function update_listening_panel(d,txt)
end

function update_monitors()
        --@TODO use inotify to verify if update needed
        if(config.monitor==false) then return end 
        local FH=io.open("/tmp/.awesome.listening")
        if(FH) then
                local listening_date=FH:read("*l")
                local listening_text=FH:read("*a")
                FH:close()
                FH=nil
                update_listening_panel(listening_date,listening_text)
        end

        FH=io.open("/tmp/.awesome.netstat_out")
        if(FH) then
                local netstat_date=FH:read("*l")
                local netstat_text=FH:read("*a")
                FH:close()
                FH=nil
                update_netstat_panel(netstat_date,netstat_text)
        end
end
function show_monitor()
        config.monitor=true
        config.netstat_panel:show()
        os.execute("echo "..config.netstat_args..">/tmp/.awesome.netstat")
end
function hide_monitor()
        config.monitor=false
        config.netstat_panel:hide()
        os.execute("rm /tmp/.awesome.netstat")
end

function set_netstat_panel(panel)
	config.netstat_panel=panel
	config.netstat_header_widget=config.netstat_panel.header
end

function main()
        config.netstat_header_widget.text="netstat "..config.netstat_args
        config.netstat_footer_widget.text="----"
        config.netstat_panel=panelz.Panel.new({rows=35,header=config.netstat_header_widget,footer=config.netstat_footer_widget})
        config.netstat_panel.wibox.width=275
        config.netstat_panel.wibox.height=500
        config.netstat_panel.wibox.x=5
        config.netstat_panel.wibox.y=100
end
function init()
        config.netstat_timer=timer({timeout=config.netstat_refresh_rate})
        --config.netstat_timer:add_signal("timeout",function() update_monitors() end)
        config.netstat_timer:connect_signal("timeout",function() update_monitors() end)
	config.netstat_timer:start()
end

main()
init()

