local sdk = sdk

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local load_enum = require("func/load_enum")
local guid_to_string = require("func/guid_to_string")

local my = {}
my.mod = {
    NAME = "optionmanip",
}
my.mod.active = true
my.items = {}
my.guid_overrides = {}

local debug = {}
debug.address = nil

function my.init()
    local _man = sdk.get_managed_singleton("app.OptionManager")
    local _item = sdk.create_instance("app.Option.OptionGroupUnit")
    local _item_setting = sdk.create_instance("app.Option.OptionSettingUnit")

    -- _item_setting.TypeId = 101
    _item_setting.TitleMessage = _item_setting.TitleMessage:NewGuid()
    my.guid_overrides[guid_to_string(_item_setting.TitleMessage)] = "Mod Options"
    _item:Setup(_item_setting)
    local _list = _man.UnitLists:get_Item(load_enum("app.Option.TabType").General)
    _list:Add(_item)
    debug.address = _list:get_address()
end



if not sdk.get_managed_singleton("app.OptionManager") then -- not pretty much reliable in the future
    my.mod.active = false
    setup_hook("app.OptionManager", "doStart",nil, function(retval)
        if not my.mod.active then
            my.mod.active = true
            my.init()
        end
        return retval
    end)
else
    my.init()
end

setup_hook("app.helper.hMsg", "GetMessage(System.Guid)", function(args)
    if my.mod.active then
        local message = my.guid_overrides[guid_to_string(sdk.to_valuetype(args[2], "System.Guid"))]
        if message then
            thread.get_hook_storage()[1] = message
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end, function(retval)
    if my.mod.active and thread.get_hook_storage()[1] then
        return sdk.to_ptr(sdk.create_managed_string(thread.get_hook_storage()[1]))
    end
    return retval
end)

re.on_frame(function()
    if debug and debug.address then
        object_explorer:handle_address(debug.address)
    end
end)