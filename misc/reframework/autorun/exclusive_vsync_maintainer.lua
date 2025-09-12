local re = re
local sdk = sdk
local imgui = imgui
local draw = draw

local setup_hook = require("func/setup_hook")
local show_custom_ticker = require("func/show_custom_ticker")
local was_key_down = require("func/was_key_down")
local load_enum = require("func/load_enum")


local x_start = 16
local y_start = 16
local width = 200
local height = 0
local height_increment = 3
local height_max = 81
local font = imgui.load_font(nil, 24)
local vsync_status_str = sdk.find_type_definition("app.Option"):get_method("GetOptionValue"):call(nil, load_enum("app.Option.ValueType").Vsync) == 0 and "ON" or "OFF"
local save = json.load_file("vsync_maintainer_save.json") or {}
local show_window = save[1] or false
local que_toggle = false

local function toggle_vsync()
    local _op_man = sdk.get_managed_singleton("app.OptionManager")
    local target_value_type = load_enum("app.Option.ValueType").Vsync
    local new_vsync = not _op_man:GetOptionValueOnOff(target_value_type)
    local _unit = _op_man:GetOptionValueUnit(target_value_type)
    _unit.ValueData.Value = new_vsync and 0 or 1
    -- local _save = sdk.create_instance("app.Option.OptionSaveData")
    -- _save.ValueDataList = _op_man.ValueDataList
    -- _op_man:call("SaveValueData(app.Option.OptionSaveData, System.Boolean)", _save, true)
    sdk.find_type_definition("app.Option"):get_method("GraphicOptionValueSetEvent"):call(nil, target_value_type, new_vsync and 0 or 1)
    show_custom_ticker("VSync is now... " .. (new_vsync and "ON!" or "OFF!"), 0.1)
    vsync_status_str = new_vsync and "ON" or "OFF"
end

setup_hook("app.Option", "GraphicOptionValueSetEvent(app.Option.ValueType, System.Int32)", function(args)
    local value_type = sdk.to_int64(args[2])
    if value_type == load_enum("app.Option.ValueType").Vsync then
        local value = sdk.to_int64(args[3])
        if value == 0 then -- ON
            que_toggle = true
            return
        end
        vsync_status_str = value == 0 and "ON" or "OFF"
    end
end)
re.on_frame(function()
    if que_toggle then
        que_toggle = false
        toggle_vsync()
    end
    if was_key_down(0x7B) then -- F12
        show_window = not show_window
        json.dump_file("vsync_maintainer_save.json")
    end
    if show_window then
        if height < height_max then
            height = height + height_increment
        end
        draw.filled_rect(x_start, y_start, width, height, 0xC0000000)
        draw.outline_rect(x_start, y_start, width, height, 0xFFFFFFFF)
        if height >= height_max then
            imgui.push_font(font)
            draw.text("VSync: " .. vsync_status_str, x_start + 8, y_start + 8, 0xFFFFFFFF)
            imgui.pop_font()
            draw.text("F12 to Toggle window", x_start + 8, y_start + 52, 0xFFFFFFFF)
        end
        -- show_custom_ticker("VSync is")
    end
end)
re.on_draw_ui(function()
    if imgui.button("Toggle VSync") then
        toggle_vsync()
    end
end)