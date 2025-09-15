-- Under Construction
local sdk = sdk

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local load_enum = require("func/load_enum")
local create_message_guid = require("func/create_message_guid")

local test_settings_list = {
    {
        {
            mod_name = "testmod",
            desc_msg = "A dummy mod with a test toggle option.",
        },
        test1 = {
            title_msg = "Test Toggle",
            desc_msg = "A test toggle option.",
            type = "SpinText",
            options = {"Off", "On"},
            max = 1,
            min = 0,
            default = 0,
            update = function(key, value) re.msg(value) end,
            reset = nil,
        },
    },
}

local my = {}
my.mod = {
    NAME = "optionmanip",
}
my.mod.active = true
my.root = nil
my.known_ids = {}
my.max_id = 0
my.children_data = {table.unpack(test_settings_list)}

my._parent_unit = nil

local debug = {}
debug.address = nil

function my.init()
    my._parent_unit = sdk.get_managed_singleton("app.OptionManager").UnitLists:get_Item(load_enum("app.Option.TabType").General)

    local _setting = my.new_setting_unit()
    _setting.TitleMessage = create_message_guid("Mod Options")
    _setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
    _setting.EventType = load_enum("app.Option.DecideEventType").OpenSubMenu

    my.root = _setting:MakeUnitData()
    my._parent_unit:Add(my.root)
    my.init_children(my.root["<ChildUnits>k__BackingField"], my.children_data)
    _setting.DescriptionMessage = create_message_guid("Options for various mods.")
    debug.address = my._parent_unit:get_address()
end
function my.init_children(parent, children_data)
    for k, data in pairs(children_data) do
        if type(data) == "table" then
            local _setting = my.new_setting_unit(children_data, k)
            if data[1] then
                _setting.TitleMessage = create_message_guid(data[1].title_msg or data[1].mod_name)
                _setting.InputType = load_enum("app.Option.UnitInputType").Button_Type1
                _setting.EventType = load_enum("app.Option.DecideEventType").OpenPrivacySetting
                local _item = _setting:MakeUnitData()
                parent:Add(_item)
                _setting.DescriptionMessage = create_message_guid(data[1].desc_msg or "")
                my.init_children(_item["<ChildUnits>k__BackingField"], data)
            else
                _setting.TitleMessage = create_message_guid(data.title_msg)
                _setting._DataType = load_enum("app.Option.SettingDataType").Value
                _setting.InputType = load_enum("app.Option.UnitInputType")[data.type or "SpinText"]
                local _item = _setting:MakeUnitData()
                parent:Add(_item)
                for _, msg in ipairs(data.options or {}) do
                    _setting.ValueMessageList:Add(create_message_guid(msg))
                end
                local _value = sdk.create_instance("app.Option.OptionValueSetting")
                _value.TypeId = _setting.TypeId
                _value.MaxValue = data.max or (#(data.options or {}) - 1)
                _value.MinValue = data.min or 0
                _value.InitValue = data.default or 0
                _item:set_PrevValue(_value.InitValue)
                _item:set_ValueSetting(_value)
                _item.ValueData = _value:MakeValueData()
            end
        end
    end
end
function my.new_setting_unit(data, key)
    local _unit = sdk.create_instance("app.Option.OptionSettingUnit")
    local type_id = my.new_type_id()
    _unit.TypeId = type_id
    if data then
        data.key = key
        my.known_ids[type_id] = data
    else
        my.known_ids[type_id] = true
    end
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
setup_hook("app.UIPartsOptionUnit", "UpdateValueEvent(System.Int32)", function(args)
    local type_id = sdk.to_int64(args[2]):get_ValueType()
    if my.known_ids[type_id] then
        local value = sdk.to_int64(args[3])
        if my.known_ids[type_id].update then
            my.known_ids[type_id].update(my.known_ids[type_id].key, value)
        end
        re.msg(value)
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