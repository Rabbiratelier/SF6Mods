-- void show_custom_ticker(String message, Single time, Int32 category)
-- or
-- void show_custom_ticker(Function message, Single time, Int32 category)
--     Function message <= Function that returns String value (useful to handle localization thing)
-- Just shows a ticker with some message.
-- time is how long the ticker will be displayed in seconds.
-- category is enum (app.AppDefine.TickerCategory).

local sdk = sdk

local my = {}
my._req = nil
my.guid_override = {}
my.queue = {}

function my.isGameReady()
    local bFlowManager = sdk.get_managed_singleton("app.bFlowManager")
    return bFlowManager and bFlowManager:get_MainFlowID() ~= 1
end
function my.initReq()
    if my._req then return sdk.PreHookResult.CALL_ORIGINAL end
    my._req = sdk.create_instance("app.TickerRequestData", true)
    my._req:Init(112,nil)
    my._req.TickerId = 1
end
function my.guid_to_string(guid)
    return string.format("%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X",
        guid.mData1, guid.mData2, guid.mData3,
        guid.mData4_0, guid.mData4_1,
        guid.mData4_2, guid.mData4_3, guid.mData4_4, guid.mData4_5, guid.mData4_6, guid.mData4_7)
end
function my.show_custom_ticker(message, time, category)
    if category == nil then category = 6 end
    if time == nil or time <= 0 then time = 3.5 end
    if not my.isGameReady() then
        table.insert(my.queue,{message, time, category})
        return
    end
    sdk.find_type_definition("app.TickerUtil"):get_method(".cctor"):call(nil)
    if my._req then
        -- my._req.RequestId = my._req.RequestId:NewGuid()
        my.guid_override[my.guid_to_string(my._req.RequestId)] = message
        my._req.Category = category
        my._req.DisplaySecond = time
        local manager = sdk.find_type_definition("app.helper.hTicker"):get_method("get_Manager"):call(nil)
        if manager then
            manager:call("RequestShowTicker(app.TickerRequestData)", my._req)
        end
        my._req = nil
    end
end



sdk.hook(sdk.find_type_definition("app.TickerUtil"):get_method(".cctor"), my.initReq) 
sdk.hook(sdk.find_type_definition("app.TickerRequestData"):get_method("GetMessage"), function(args)
    local message = my.guid_override[my.guid_to_string(sdk.to_managed_object(args[2]).RequestId)]
    if message then
        if type(message) == "function" then
            thread.get_hook_storage()[1] = message()
        else
            thread.get_hook_storage()[1] = message
        end
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end,function(retval)
    if thread.get_hook_storage()[1] then
        return sdk.to_ptr(sdk.create_managed_string(thread.get_hook_storage()[1]))
    end
    return retval
end)
sdk.hook(sdk.find_type_definition("app.bBootFlow"):get_method("UpdatePhaseTransition"), function()
    if #my.queue > 0 then
        for k,v in ipairs(my.queue) do
            my.show_custom_ticker(table.unpack(v))
        end
        my.queue = {}
    end
end)

return my.show_custom_ticker