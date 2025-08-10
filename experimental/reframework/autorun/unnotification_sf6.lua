local sdk = sdk
local imgui = imgui
local thread = thread

local current_scene_id = require("func/current_scene_id")
local setup_hook = require("func/setup_hook")

local this = {}
this.data = ""
this.ignoreList = require("config/TickerData")
this.scnIndex = ValueType.new(sdk.find_type_definition("app.constant.scn.Index"))

local function check_ignore (type)
    for k,v in pairs(this.ignoreList) do
        if type == v then
            return true
        end
    end
    return false
end

setup_hook("app.TickerRequestData","Init",function(args)
    this.data = sdk.to_int64(args[3]) --app.AppDefine.TickerData
    if check_ignore(this.data) then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2])
    end
end, function()
    local obj = thread.get_hook_storage()["this"]
    if obj then
        obj.DisplaySecond = 1.0/60
    end
end)

re.on_draw_ui(function()
    imgui.text(this.data)
    if check_ignore(this.data) then
        imgui.text("true")
    else
        imgui.text("false")
    end
end)