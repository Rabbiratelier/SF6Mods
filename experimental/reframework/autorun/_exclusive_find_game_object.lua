local sdk = sdk

local setup_hook = require("func/setup_hook")

local names = {}

setup_hook("via.GameObject", "findComponents(System.Type)", function(args)
    local obj = sdk.to_managed_object(args[2])
    local name = obj:get_Name()
    local type = sdk.to_managed_object(args[3]):ToString()
    name = name .. " " .. type
    for _, v in pairs(names) do
        if v == name then
            return sdk.PreHookResult.CALL_ORIGINAL
        end
    end
    table.insert(names, name)
end)

setup_hook("via.GameObject", "findComponents")

re.on_frame(function()
    for _, v in pairs(names) do
        imgui.text(v)
    end
end)