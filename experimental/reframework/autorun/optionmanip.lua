-- Under Construction
local sdk = sdk

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local load_enum = require("func/load_enum")
local create_message_guid = require("func/create_message_guid")

local my = {}
my.mod = {
    NAME = "optionmanip",
}
my.mod.active = true
my.items = {}

my._parent_list = nil

local debug = {}
debug.address = nil

function my.init()
    local _man = sdk.get_managed_singleton("app.OptionManager")
    local _item = sdk.create_instance("app.Option.OptionGroupUnit")
    local _item_setting = sdk.create_instance("app.Option.OptionSettingUnit")

    -- _item_setting.TypeId = 101
    _item_setting.TitleMessage = create_message_guid("Mod Options")
    _item_setting.DescriptionMessage = create_message_guid("Options for various mods.")
    -- _item_setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
    -- _item_setting.EventType = load_enum("app.Option.DecideEventType").OpenSubMenu
    _item:Setup(_item_setting)
    my._parent_list = _man.UnitLists:get_Item(load_enum("app.Option.TabType").General)
    my._parent_list:Add(_item)
    table.insert(my.items, _item)
    debug.address = my._parent_list:get_address()
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

re.on_frame(function()
    if debug and debug.address then
        object_explorer:handle_address(debug.address)
    end
end)

re.on_script_reset(function()
    if next(my.items) then
        for _, item in ipairs(my.items) do
            my._parent_list:Remove(item)
        end
    end
end)