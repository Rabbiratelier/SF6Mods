local initing_hub = false

sdk.hook(sdk.find_type_definition("app.worldtour.bBattleHubMainFlow"):get_method(".ctor"), nil, function()
    initing_hub = true
end)

sdk.hook(sdk.find_type_definition("app.ChatManager"):get_method("AddLog"), function(args)
    if sdk.to_managed_object(args[2]).MessageType == 4 then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end)

re.on_pre_gui_draw_element(function(element, context)
    if initing_hub then
        local game_object = element:call("get_GameObject")
        if game_object and game_object:get_Name() == "Hud_BattleHubChat" then
            element:set_Enabled(false)
            initing_hub = false
        end
    end
end)