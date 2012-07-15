local setmetatable=setmetatable
local table=table
local type=type
local ipairs=ipairs
--local naughty=require("naughty")
local awful=require("awful")
local z=z
local capi = {
    client = client,
    tag = tag,
    image = image,
    screen = screen,
    button = button,
    mouse = mouse,
    root = root,
    timer = timer
}
module("z.tags")
local tags={}
local mpanel=nil
local config={
    tag_names={"sys","www"},
}

function dump()
    local ret=""
    for s=1,capi.screen.count(),1 do 
        ret=ret.."screen # "..s.."\n"
        for i,t in ipairs(capi.screen[s]:tags()) do
            tp=type(p)
            ret=ret.."\t#"..i.."tag:"..tp.."\n"
            end
        end
        print(ret)
    --msg(ret)
    return ret
end
function msg(s)
--    naughty.notify({text=s})
end

function tags.new(args)
    ret={}
    ret.version="0.001"
    setmetatable(ret,{__index=tags})
    return ret;
end

msg("John Smith was here")
init()
setmetatable(_M, { __call=function(_, ...) return tags.new(...) end })

