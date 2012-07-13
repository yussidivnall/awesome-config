local setmetatable=setmetatable

local naughty=require("naughty")
local awful=require("awful")
local wibox=require("wibox")
local z=z
module("z.button")
local button={}

local mbuttons={} --Keeps the awful.buttons
local mwidget={} --keeps a widget (i guess awesome.widget or awful.widget

--[[[
    @TODO Finish, temporarily opted for "quick button"
    creates a new z.button
    use b=z.button({text="TEXT1",f=function()...end})
        or z.button({somewidget,awful.util.table.join(...)          
    args
    @text   constracts a textbox widget from given text and set as mwidget
    @widget set an existing widget (awful.widget,widget)
    @f      a function to execute on single click OR
    @       awful.buttons
]]---

function button.new(args)
    if(args==nil) then return nil end
    print("Complex button")    
    ret={}
    if(args.widget ~= nil and args.buttons ~= nil)then
        ret.mbuttons=args.buttons
        ret.mwidget=args.widget
        return ret 
        end
    if(args.text) then --Constructs a text widget
        msg("single button")
        mwidget=wibox.widget.textbox()
        mwidget:set_markup(args.text)
        end
    
    mbuttons=args.buttons
    mwidgets=args.widget or mwidget
    return ret;
end

--[[[
    A quick button, constructs a button from text,function
    @txt    
    @fn
]]--
function button.new(txt,fn)
    msg("New quick button")
    local ret={}
    local mwdidget=wibox.widget.textbox()
    mwidget:set_markup(txt)
    local mbuttons=awful.util.table.join(awful.button({ }, 1,fn))
    ret.mwidget=mwidget
    ret.mbuttons=mbuttons
    return ret
end
function msg(m)
    naughty.notify({text=m})
end

--setmetatable(_M, { __call=function(_, ...) return button.new(...) end })
setmetatable(_M, { __call=function(_, ...) return button.new(...,...) or button.new(...)  end })

