local io=io
local os=os
local awful=require("awful")
local naughty=require("naughty")
local wibox=require("wibox")
local string=string
local type=type
local ipairs=ipairs
local pairs=pairs
local table=table
module("z.utils")

---Creates a new wibox from a table of argumets
--@param x
--@param y
--@param width
--@param height
--@param screen
--@param visible
--@param opacity
--@return new wibox
function new_wibox(args)
        local X=args.x or 2
        local Y=args.y or 20
        local w=args.width or 200
        local h=args.height or 200
        local s = args.screen or 1
	    local v = args.visible or false
	    local o = args.opacity or 0.6
        local ret = wibox({fg="#ffffff", bg="#000000",border_color="#0a0ba9", border_width=2 })
        ret.opacity=o
        ret.ontop=true
        ret:geometry({ width=w,height=h,x=X,y=Y })
    	ret.visible=v
        ret.screen=s
        return ret
end

function split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function has_key(list,key)
	for idx,k in ipairs(list) do
		if(k==key) then return true end
	end
	return false
end

function diff(a,b)
	ret={}
	--naughty.notify({text="diff..."})
	for idx,k in ipairs(a) do
		--naughty.notify({text="in key:"..k})
		if(not has_key(b,k)) then table.insert(ret,k) end
	end
	return ret
end


function exec(command)
        local fh = io.popen(command)
        ret=fh:read("*a")
        fh:close()
        return ret
end

function ror(instance)
        local clients = client.get()
        for i, c in pairs(clients) do
--                dbg(i)
--                dbg("name:"..c.name.."          class:"..c.class.."     type:"..type(c))
                dbg(c.instance)
                if(c.instance==instance) then
                        local curtag = awful.tag.selected()
                        awful.client.movetotag(curtag, c)
                        c:raise()
                        c.ontop=true
                        client.focus = c

                        return
                end
        end
        awful.util.spawn(instance)

end

function dbg(s)
        naughty.notify({text=s,timeout=15})
end



local level=0
local transvesal=""
function spaces(n)
    local ret=""
    if(n==0)then return ret end
    for i=0,n,1 do
        ret=ret.."\t" 
    end
    return ret
end


function decend(tbl)
    local ret=""
    --if(type(tbl)~=table) then return type(tbl) end
    level=0
    ret=trasverse(tbl)
    return ret;
end

function trasverse(tbl)
    naughty.notify({text='tas lever'..level})
    local max=50
    local ret=""
    --local ret=transvesal
    for i,v in pairs(tbl) do
        --os.execute("sleep 1")
        --naughty.notify({text="i"..i.." t"..type(v)})
        if type(v)=='table' then 
            --naughty.notify({text='tbl'})
            --print('tbl')
            ret=ret..spaces(level).."table\n"
            if(max >= level) then ret=ret..trasverse(v) end
            level=level+1
        elseif(type(v)=='function') then
            --naughty.notify({text='fn'})
            --print('fn')
            ret=ret..spaces(level).."function\n" 
        elseif(type(v)=='string') then
            --naughty.notify({text='s'})
            ret=ret..spaces(level)..'string='..v.."\n" 
        elseif(type(v)=='number') then ret=ret..spaces(level)..'number='..v.."\n"
        elseif(type(v)=='nil') then 
            ret=ret..spaces(level)..'nil\n'
            --naughty.notify({text='nil'})
        else
            ret=ret..level.."I AM NOT CHECKED:"..type(v).."\n"
        end
        --level=level-1
    end
    --naugty.notify({text=ret})
    return ret
end


