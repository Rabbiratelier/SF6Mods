local re = re
local sdk = sdk
local draw = draw

local show_custom_ticker = require("func/show_custom_ticker")
local was_key_down = require("func/was_key_down")


local x_start = 0
local y_start = 0
re.on_frame(function()
    if true then -- was_key_down(0x7B) then -- F12
        draw.filled_rect(x_start, y_start, 200, 90, 0xC0000000)
        draw.outline_rect(x_start, y_start, 200, 90, 0xFFFFFFFF)
        -- show_custom_ticker("VSync is")
    end
end)