-- Actually a stinky hack just hooks hMsg.GetMessage and use guid overrides
-- Returns a new guid for a given message string
local sdk = sdk
local thread = thread

local my = {}
my.guid_overrides = {}

function my.format_guid(guid)
    return string.format("%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X",
        guid.mData1, guid.mData2, guid.mData3,
        guid.mData4_0, guid.mData4_1,
        guid.mData4_2, guid.mData4_3, guid.mData4_4, guid.mData4_5, guid.mData4_6, guid.mData4_7)
end

function my.create_message_guid(str)
    local newGuid = sdk.find_type_definition("System.Guid"):get_field("Empty"):get_data(nil):NewGuid()
    my.guid_overrides[my.format_guid(newGuid)] = str
    return newGuid
end

sdk.hook(sdk.find_type_definition("app.helper.hMsg"):get_method("GetMessage(System.Guid)"), function(args)
    local message = my.guid_overrides[my.format_guid(sdk.to_valuetype(args[2], "System.Guid"))]
    if message then
        thread.get_hook_storage()[1] = message
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end, function(retval)
    if thread.get_hook_storage()[1] then
        return sdk.to_ptr(sdk.create_managed_string(thread.get_hook_storage()[1]))
    end
    return retval
end)

return my.create_message_guid