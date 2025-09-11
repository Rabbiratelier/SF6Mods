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

my._parent_list = nil

local debug = {}
debug.address = nil

local test_settings_list = {
    {
        {
            name = "Test Toggle",
            type = "toggle",
            description = "A test toggle option.",
        },
        {
            name = "Test Slider",
            type = "slider",
            min = 0,
            max = 100,
            step = 5,
            description = "A test slider option.",
        },
        {
            name = "Test Dropdown",
            type = "dropdown",
            options = {"Option 1", "Option 2", "Option 3"},
            description = "A test dropdown option.",
        },
        mod_name = "Test Mod",
    },
}

function my.init()
    local _man = sdk.get_managed_singleton("app.OptionManager")
    local _option_setting = sdk.create_instance("app.Option.OptionSettingUnit")
    local type_id = my.new_type_id()

    _option_setting.TypeId = type_id
    _option_setting.TitleMessage = create_message_guid("Mod Options")
    _option_setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
    _option_setting.EventType = load_enum("app.Option.DecideEventType").OpenSubMenu

    my._parent_list = _man.UnitLists:get_Item(load_enum("app.Option.TabType").General)
    my.root = _option_setting:MakeUnitData()
    my.root["<ChildUnits>k__BackingField"]:Add(my.init_child())
    _option_setting.DescriptionMessage = create_message_guid("Options for various mods.")
    my._parent_list:Add(my.root)
    my.known_ids[type_id] = true
    debug.address = my._parent_list:get_address()
end
function my.init_child()
    local _option_setting = sdk.create_instance("app.Option.OptionSettingUnit")
    local _value_setting = sdk.create_instance("app.Option.OptionValueSetting")
    local type_id = my.new_type_id() + 1
    _option_setting.TypeId = type_id
    _option_setting.TitleMessage = create_message_guid("Random Toggle")
    _option_setting._DataType = load_enum("app.Option.SettingDataType").Value
    _option_setting.InputType = load_enum("app.Option.UnitInputType").SpinText
    local _item = _option_setting:MakeUnitData()

    _option_setting.ValueMessageList:Clear()
    _option_setting.ValueMessageList:Add(create_message_guid("Option 1"))
    _option_setting.ValueMessageList:Add(create_message_guid("Option 2"))
    _option_setting.ValueMessageList:Add(create_message_guid("Option 3"))
    _value_setting.TypeId = type_id
    _value_setting.MaxValue = 2
    _value_setting.MinValue = 0
    _value_setting.InitValue = 0
    _item:set_ValueSetting(_value_setting)
    _item.ValueData = _value_setting:MakeValueData()
    my.known_ids[type_id] = true
    -- _option_setting.DescriptionMessage = create_message_guid("Toggle BGM On/Off")
    return _item
end
function my.new_type_id()
    if my.max_id ~= 0 then
        my.max_id = my.max_id + 1
        return my.max_id
    end
    for _, i in ipairs(sdk.find_type_definition("app.Option.ValueType"):get_fields()) do
        local value = i:is_static() and i:get_data(nil) or 0
        if value > my.max_id then
            my.max_id = value
        end
    end
    my.max_id = my.max_id + 1
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
        my._parent_list:Remove(my.root)
    end
end)