-----------------------------------
--@author Yussi Divnal
----------------------------------

require("z")
io=require("io")
local io=io
local z=z




module("zapps.showfile")

showfile={
}
function display(filename)
	f=io.open(filename)
	dump=f:read("*a")
	f:close()
	pl=z.utils.split(dump,"\n")
	panel:set_payload({payload=pl})
end

function showfile.new(filename)
	ret={}
	panel_args={
		wibox_params={
		x=300,
		y=0,
		width=1000,
		height=200
		}
	}
	ret.panel = z.panel(panel_args)
	display(filename)
	--panel:show()
	--panel.hide()
	return ret
end
