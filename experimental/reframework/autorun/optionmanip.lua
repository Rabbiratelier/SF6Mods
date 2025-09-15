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
my.root = nil
my.known_ids = {}
my.max_id = 0

my._parent_unit = nil

local debug = {}
debug.address = nil

local test_settings_list = {
    {
        {
            mod_name = "test1",
            desc_msg = "A test toggle option.",
        },
        test1 = {
            name = "Test Toggle",
            type = "SpinText",
            default = 0,
            options = {},
            max = 1,
            min = 0,
            update = function(name, value) end,
            reset = nil,
        },
    },
}

function my.init()
    my._parent_unit = sdk.get_managed_singleton("app.OptionManager").UnitLists:get_Item(load_enum("app.Option.TabType").General)

    local _setting = my.new_setting_unit()
    _setting.TitleMessage = create_message_guid("Mod Options")
    _setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
    _setting.EventType = load_enum("app.Option.DecideEventType").OpenSubMenu

    my.root = _setting:MakeUnitData()
    my._parent_unit:Add(my.root)

    my.root["<ChildUnits>k__BackingField"]:Add(my.init_child())
    my.root["<ChildUnits>k__BackingField"]:Add(my.init_child())
    _setting.DescriptionMessage = create_message_guid("Options for various mods.")
    debug.address = my._parent_unit:get_address()
end
function my.init_child()
    local _option_setting = my.new_setting_unit()
    local _value_setting = sdk.create_instance("app.Option.OptionValueSetting")
    _option_setting.TitleMessage = create_message_guid("Random Toggle")
    -- _option_setting._DataType = load_enum("app.Option.SettingDataType").Value
    _option_setting.InputType = load_enum("app.Option.UnitInputType").Button_Type0
    _option_setting.EventType = load_enum("app.Option.DecideEventType").OpenPrivacySetting
    local _item = _option_setting:MakeUnitData()

    _option_setting.ValueMessageList:Clear()
    local test_messages = {"Off", "Low", "High", "Ultra", "Extreme"}
    for _, name in ipairs(test_messages) do
        _option_setting.ValueMessageList:Add(create_message_guid(name))
    end
    _value_setting.TypeId = _option_setting.TypeId
    _value_setting.MaxValue = 2
    _value_setting.MinValue = 0
    _value_setting.InitValue = 0
    -- _item:set_ValueSetting(_value_setting)
    -- _item.ValueData = _value_setting:MakeValueData()
    -- _option_setting.DescriptionMessage = create_message_guid("Toggle BGM On/Off")
    return _item
end
function my.new_setting_unit()
    local _unit = sdk.create_instance("app.Option.OptionSettingUnit")
    local type_id = my.new_type_id()
    _unit.TypeId = type_id
    my.known_ids[type_id] = true
    return _unit
end
function my.new_type_id()
    if my.max_id ~= 0 then
        my.max_id = my.max_id + 1
        return my.max_id
    end
    for _, i in ipairs(sdk.find_type_definition("app.Option.ValueType"):get_fields()) do
        local value = i:is_static() and i:get_data(nil) < 2100000000 and i:get_data(nil) or 0
        if value > my.max_id then
            my.max_id = value
        end
    end
    my.max_id = my.max_id > 100000 and math.ceil((my.max_id + 1)/10)*10 + 100000 or 100000
    return my.max_id
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

setup_hook("app.Option.OptionValueUnit", "LoadValueEvent", function(args)
    local type_id = sdk.to_managed_object(args[2]):get_Setting().TypeId
    if my.known_ids[type_id] then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end)
setup_hook("app.Option.OptionValueUnit", "ResetEvent", function(args)
    local type_id = sdk.to_managed_object(args[2]):get_Setting().TypeId
    if my.known_ids[type_id] then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end)
setup_hook("app.UIPartsOptionUnit", "UpdateValueEvent", function(args)
    local type_id = sdk.to_managed_object(args[2]).UnitData:get_Setting().TypeId
    if my.known_ids[type_id] then
        local value = sdk.to_int64(args[3])
        -- re.msg(value)
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end)


re.on_frame(function()
    if debug and debug.address then
        object_explorer:handle_address(debug.address)
    end
end)

re.on_script_reset(function()
    if my.root then
        my._parent_unit:Remove(my.root)
    end
end)