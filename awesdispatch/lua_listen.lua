#!/usr/bin/lua
require("os");
require("io");
local fh=io.popen("adb shell '/sd-ext/sensors.sh'")
fh:close();
