local ipairs=ipairs
local naughty=require("naughty")
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

module("z.tags.tags")
local mpanel=nil
local config={
    tag_names={"sys","www"},
}

function dump()
    local ret=""
    for s=1,capi.screen.count(),1 do 
        ret=ret.."screen # "..s.."\n"
        for i,t in ipairs(capi.screen[s]:tags()) do
            ret=ret.."\t#"..i.."tag:"..t.."\n"
            end
        end
    msg(ret)
    return ret
end

function init()
    dump()
    msg("tags...")
    msg("mouse.screen"..capi.mouse.screen)
    mpanel=z.panel({})
    mpanel:set_payload({payload=config.tag_names})
    mpanel:pop()    
end
function msg(s)
    naughty.notify({text=s})
end
msg("John Smith was here")
init()
