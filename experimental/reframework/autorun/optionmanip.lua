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
    local _setting = sdk.create_instance("app.Option.OptionSettingUnit")
    -- local _child_units = sdk.create_instance("System.Collections.Generic.List`1<app.Option.OptionUnitBase>"):add_ref()

    -- _setting.TypeId = 101
    _setting.TitleMessage = create_message_guid("Mod Options")
    _setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
    _setting.EventType = load_enum("app.Option.DecideEventType").OpenSubMenu
    _item:Setup(_setting)
    _setting.DescriptionMessage = create_message_guid("Options for various mods.")

    re.msg(_item:get_field("<ChildUnits>k__BackingField"):get_type():get_name())
    -- _child_units:Add(my.init_child())
    
    -- _item:set_ChildUnits(_child_units)
    my._parent_list = _man.UnitLists:get_Item(load_enum("app.Option.TabType").General)
    my._parent_list:Add(_item)
    table.insert(my.items, _item)
    debug.address = my._parent_list:get_address()
end
function my.init_child()
    local _item = sdk.create_instance("app.Option.OptionValueUnit")
    local _setting = sdk.create_instance("app.Option.OptionSettingUnit")
   
    -- _setting.TypeId = 102
    _setting.TitleMessage = create_message_guid("BGM Toggle")
    _setting._DataType = load_enum("app.Option.SettingDataType").Value
    _setting.InputType = load_enum("app.Option.UnitInputType").SpinText
    _setting.ValueMessageList:Add(create_message_guid("On"))
    _setting.ValueMessageList:Add(create_message_guid("Off"))
    _item:Setup(_setting)
    _setting.DescriptionMessage = create_message_guid("Toggle BGM On/Off")
    -- table.insert(my.items, _item)
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