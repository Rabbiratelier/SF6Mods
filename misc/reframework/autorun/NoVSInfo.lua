local re = re

local enabled = true

re.on_pre_gui_draw_element(function(element, context)
    local game_object = element:call("get_GameObject")
    if not enabled or game_object == nil then return true end

    local name = game_object:call("get_Name")
    if name == "VSInfoOffline" then
        return false
    end

    return true
end)

re.on_draw_ui(function()
    local changed, value = imgui.checkbox("NoVSInfo", enabled)
    if changed then
        enabled = value
    end
end)