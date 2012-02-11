local z=z
local naughty=naughty
module('z.network.control')
main_panel = nil

function toggle_capture()
end


function init()
	local buttons={
		established={text='est',actions={onMouseOver=function() end, onMouseOut=function() end}},
		listening={text='lsn',actions={}}
	}
	main_panel=z.panel({rows=40})
	local args={
		options={
			payload_type='buttons'
		},
		payload=buttons
	}
	main_panel:set_payload(args)
--	z:set_buttons(buttons)
end
init()

