local re = re
local sdk = sdk
local draw = draw

local setup_hook = require("func/setup_hook")
local show_custom_ticker = require("func/show_custom_ticker")
local was_key_down = require("func/was_key_down")


local x_start = 16
local y_start = 16
local width = 200
local height = 0
local height_increment = 3
local height_max = 81
local font = imgui.load_font(nil, 24)
local vsync_status_str = "unknown"



setup_hook("app.GraphicsSettingsManager", "doStart()", nil,function()
    local _man = sdk.get_managed_singleton("app.GraphicsSettingsManager")
    vsync_status_str = _man:get_VSync() and "on" or "off"
    _man:set_VSync(false)
end)
re.on_frame(function()
    if true then -- was_key_down(0x7B) then -- F12
        if height < height_max then
            height = height + height_increment
        end
        draw.filled_rect(x_start, y_start, width, height, 0xC0000000)
        draw.outline_rect(x_start, y_start, width, height, 0xFFFFFFFF)
        if height >= height_max then
            imgui.push_font(font)
            draw.text("VSync: " .. vsync_status_str, x_start + 8, y_start + 8, 0xFFFFFFFF)
            imgui.pop_font()
        end
        -- show_custom_ticker("VSync is")
    end
end)
re.on_draw_ui(function()
    if imgui.button("Toggle VSync") then
        local _man = sdk.get_managed_singleton("app.GraphicsSettingsManager")
        local new_vsync = not _man:get_VSync()
        _man:set_VSync(new_vsync)
        show_custom_ticker("VSync is " .. (new_vsync and "on" or "off"))
        vsync_status_str = new_vsync and "on" or "off"
    end
end)