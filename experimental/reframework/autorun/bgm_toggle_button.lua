local sdk = sdk
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
my.current_bgm_volume = sdk.find_type_definition("app.Option"):get_method("GetOptionValue(app.Option.ValueType)"):call(nil, my.TYPE_BGM_VOLUME)
my.set_volume_method = sdk.find_type_definition("app.Option"):get_method("UpdatedOptionValueEvent(app.Option.ValueType, System.Int32, System.Boolean)")

re.on_frame(function()
    imgui.begin_window(my.mod.NAME, nil, 0x101E1)
    local is_down = imgui.button("BUTTON")
    imgui.end_window()
    if not my.was_button_down and is_down then
        my.current_bgm_volume = my.current_bgm_volume > 0 and 0 or 10
        my.set_volume_method:call(nil, my.TYPE_BGM_VOLUME, my.current_bgm_volume, false)
    end
    my.was_button_down = is_down
end)