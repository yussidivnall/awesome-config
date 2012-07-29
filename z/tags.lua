--require("z.tags.tags")
local naughty=require("naughty")
module("z.tags")
tags_table={
}

--[[For tag managment ]]--
function sort_by(args) end
function group_by(args) end
function toggle_all(args) end
function toggle_in_group(args) end
function toggle_current_group(args) end

function add_tag() end
function remove_tag() end
function rename_tag() end
function init()
    naughty.notify({text="z.tag"})
end
init()
