naughty=require("naughty")
utils=require("utilz")
z=require("z")
io=require("io")
table = require("table")
local ipairs=ipairs
local pairs=pairs
local string =string
local io=io
local z=z
local naughty=naughty
local utilz=utilz
local table=table
local keygrabber=keygrabber
module("zapps.clips")

panels={
}
buffer_panel={}
selection=1

function next_select()
	selection=selection+1

	if (selection > #panels) then selection =1 end
	buffer_panel.selected=selection
	buffer_panel:pop({})
	buffer_panel:update()
	hideboard()
	panels[selection].panel:pop({})
	local txt=panels[selection].text
	f=io.popen("echo '"..txt.."'|xclip -i")
	f:close()
	--os.execute("echo '"..txt.."'|xclip -i") --won't do the trick!

end

function show_buffer()
	pl={}
	for i,v in ipairs(panels) do
		table.insert(pl,v.title)
	end
	buffer_panel:show()
	--Handle key events here...
end
function hideboard()
	for i,v in ipairs(panels)do
                v.panel:hide()
        end
end

function hideall()
	hideboard()
	buffer_panel:hide()
end

function init()
        panel_args={
                wibox_params={
                x=0,
                y=150,
                width=175,
                height=200
                }
        }
	buffer_panel= z.panel(panel_args)
end

function get_panel()
	ret={}
        panel_args={
                wibox_params={
                x=300,
                y=15,
                width=1000,
                height=200
                }
        }
        ret = z.panel(panel_args)
	return ret
end



function clip()
		--local f=io.popen("cat /etc/hosts")
		local f=io.popen("xclip -o") -- won't work(In test?)!
		if (f) then
			local txt=f:read("*a")
			f:close()
			local clipboard=utilz.split(txt,"\n")
			p = get_panel()
			p:set_payload({payload=clipboard})
			p:update()
			local t = string.sub(clipboard[1],1,25)
			table.insert(panels,{title=t,panel=p,text=txt})
			buffer_panel:append(t)
			p:pop({})

		else
		end
end

init()

