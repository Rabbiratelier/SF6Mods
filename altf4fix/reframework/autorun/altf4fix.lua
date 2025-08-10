local done = false
re.on_application_entry("UpdateHID",function()
    if not done and reframework:is_key_down(0x73) and reframework:is_key_down(0x12) then
        sdk.call_native_func(sdk.get_native_singleton("via.Application"), sdk.find_type_definition("via.Application"), "exit", 0)
        done = true
    end
end)