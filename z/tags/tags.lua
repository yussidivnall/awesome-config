local naughty=require("naughty")
local z=z
module("z.tags.tags")
local mpanel=nil
local config={
    tag_names={"sys","www"},
}
function init()
    msg("tags...")
    mpanel=z.panel({})
    mpanel:set_payload({payload=config.tag_names})
    mpanel:pop()    
end
function msg(s)
    naughty.notify({text=s})
end
msg("John Smith was here")
init()
