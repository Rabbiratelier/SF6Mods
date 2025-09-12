local re = re
local sdk = sdk
local draw = draw

local show_custom_ticker = require("func/show_custom_ticker")
local was_key_down = require("func/was_key_down")


local x_start = 16
local y_start = 16
local width = 200
local height = 0
local height_increment = 3
local height_max = 81
local font = imgui.load_font(nil, 24)
re.on_frame(function()
    if true then -- was_key_down(0x7B) then -- F12
        if height < height_max then
            height = height + height_increment
        end
        draw.filled_rect(x_start, y_start, width, height, 0xC0000000)
        draw.outline_rect(x_start, y_start, width, height, 0xFFFFFFFF)
        if height >= height_max then
            imgui.push_font(font)
            draw.text("VSync is", x_start + 8, y_start + 8, 0xFFFFFFFF)
            draw.text("enabled in", x_start + 8, y_start + 32, 0xFFFFFFFF)
            draw.text("exclusive mode", x_start + 8, y_start + 56, 0xFFFFFFFF)
            imgui.pop_font()
        end
        -- show_custom_ticker("VSync is")
    end
end)