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
    -- local _item = sdk.create_instance("app.Option.OptionGroupUnit")
    local _setting = sdk.create_instance("app.Option.OptionSettingUnit")
    -- local _child_units = _item:get_field("<ChildUnits>k__BackingField")

    -- _setting.TypeId = 101
    _setting.TitleMessage = create_message_guid("Mod Options")
    _setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
    _setting.EventType = load_enum("app.Option.DecideEventType").OpenSubMenu
    -- _item:Setup(_setting)

    -- _child_units:Add(my.init_child())
    -- _item:set_field("<ChildUnits>k__BackingField", _child_units)

    my._parent_list = _man.UnitLists:get_Item(load_enum("app.Option.TabType").General)
    local _item = _setting:MakeUnitData()
    _item:get_field("<ChildUnits>k__BackingField"):Add(my.init_child())
    _setting.DescriptionMessage = create_message_guid("Options for various mods.")
    my._parent_list:Add(_item)
    table.insert(my.items, _item)
    debug.address = my._parent_list:get_address()
end
function my.init_child()
    local _setting = sdk.create_instance("app.Option.OptionSettingUnit")
    _setting.TitleMessage = create_message_guid("BGM Toggle")
    _setting._DataType = load_enum("app.Option.SettingDataType").Value
    _setting.InputType = load_enum("app.Option.UnitInputType").SpinText
    local _item = _setting:MakeUnitData()
    _setting.ValueMessageList:Clear()
    _setting.ValueMessageList:Add(create_message_guid("On"))
    _setting.ValueMessageList:Add(create_message_guid("Off"))
    -- _setting.DescriptionMessage = create_message_guid("Toggle BGM On/Off")
    return _item
end



if not sdk.get_managed_singleton("app.OptionManager") then
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