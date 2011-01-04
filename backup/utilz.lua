local io=io
local awful=require("awful")
local naughty=require("naughty")
local wibox=wibox
local string=string
local type=type
local table=table
module("utilz")

function run_or_raise(args)

end


function new_wibox(args)
        local X=args.x or 2
        local Y=args.y or 20
        local w=args.width or 200
        local h=args.height or 200
        local s = args.screen or 1
	local v = args.visible or false
        local ret = wibox({fg="#ffffff", bg="#000000",border_color="#0a0ba9", border_width=2 })
        ret.opacity=0.6
        ret.ontop=true
        ret:geometry({ width=w,height=h,x=X,y=Y })
	ret.visible=v
        ret.screen=s
        --awful.wibox.align(ret,"left",s)
        return ret
end

--@PARAMS
--args.wibox - optional params for new_wibox()
function panel(args)


	wibox_params=args.wibox or {}
	update=args.update_timer or nil
	ret={}
	ret.wibox=new_wibox(wibox_params)
	ret.update_list = function(l)
		list=l
	end
	return ret
end



function exec(command)
        local fh = io.popen(command)
        ret=fh:read("*a")
        fh:close()
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

function trim (s) -- http://www.lua.org/pil/20.3.html
      return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
function string_to_table(args)
	str=args.str or nil
	mode=args.mode or "rows"
	line_deliminator=args.line_deliminator or "\n"
	word_deliminator=args.word_deliminator or "%s*"
	labels = args.labels or nil
	if (mode=="rows" and str ) then
--		return split(trim(str),"\\n");
	end
	if (mode=="columns" and str) then
	--	local lines = split(str,line_deliminator);
	--	local ret={};
	--	for i,v in ipairs(lines) do
	--		words=split(v,word_deliminator)
	--		label="";
	--		if labels[i] then
	--			local label=labels[i];
	--		else
	--			local label="column_"..i
	--		end
	--		table.insert(ret,{label=words[i]})
	--	end
		return ret;
	end


end
function file_to_table(file_name)
	local file=io.open(file_name)
	local text=file:read("*a")
	file:close()
	ret={}
	index=1
	for line in text:gmatch("[^\r\n]+") do
		ret[index]={}
		for word in line:gmatch("%w+") do
			table.insert(ret[index],word)
		end
		index=index+1
	end
	return ret;
end

function table_contains(t,v)
        for i in t do
                if i==v then return true end
        end
        return false
end
function out(t)
	naughty.notify({text=t})
end
