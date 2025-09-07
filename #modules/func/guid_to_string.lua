function guid_to_string(guid)
    return string.format("%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X",
        guid.mData1, guid.mData2, guid.mData3,
        guid.mData4_0, guid.mData4_1,
        guid.mData4_2, guid.mData4_3, guid.mData4_4, guid.mData4_5, guid.mData4_6, guid.mData4_7)
end

return guid_to_string