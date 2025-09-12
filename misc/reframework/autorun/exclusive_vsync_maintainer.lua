local re = re
local sdk = sdk
local draw = draw

local show_custom_ticker = require("func/show_custom_ticker")
local was_key_down = require("func/was_key_down")


local x_start = 16
local y_start = 16
local width = 200
local height = 75
re.on_frame(function()
    if true then -- was_key_down(0x7B) then -- F12
        draw.filled_rect(x_start, y_start, width, height, 0xC0000000)
        draw.outline_rect(x_start, y_start, width, height, 0xFFFFFFFF)
        -- show_custom_ticker("VSync is")
    end
end)