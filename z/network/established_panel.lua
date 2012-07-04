local z=z
module('z.network.established_panel')
local panel={}

function new(args)
	naughty.notify({text="hi"});
	ret={}
        setmetatable(ret,{__index=panel})
        return ret

end
function add_connection(conn)
	panel.add(conn);	
end
function init()
	panel=z.panel({rows=40});
end
--init()
setmetatable(_M, { __call=function(_, ...) return established_panel.new(...) end })

