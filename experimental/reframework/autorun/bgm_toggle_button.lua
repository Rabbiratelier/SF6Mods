local re = re
local imgui = imgui

local load_enum = require("func/load_enum")

local my = {}
my.mod = {
    NAME = "bgm_toggle_button",
}
my.mod.active = true
my.was_button_down = false

my.TYPE_BGM_VOLUME = load_enum("app.Option.ValueType").SoundBGMVolume

re.on_frame(function()
    local is_down = imgui.button("Butt")
    if not my.was_button_down and is_down then
        local bgm_volume = sdk.find_type_definition("app.Option"):get_method("GetOptionValue(app.Option.ValueType)"):call(nil, my.TYPE_BGM_VOLUME) > 0 and 0 or 10
        sdk.find_type_definition("app.Option"):get_method("UpdatedOptionValueEvent(app.Option.ValueType, System.Int32, System.Boolean)"):call(nil, my.TYPE_BGM_VOLUME, bgm_volume, false)
    end
    my.was_button_down = is_down
end)