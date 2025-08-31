-- We want better translations! If you can help, please contact me on Nexus Mods.
local sdk = sdk

local __ja = {
}

local __en = {
}

local __fr = {
}

local __de = {
}

local __it = {
}

local __es = {
}

local __ru = {
}

local __pl = {
}

local __pt_br = {
}

local __kr = {
}

local __zh_cn = {
}

local __zh_tw = {
}

local __ar = {
}

local __es_latam = {
}

local this = {}
this.DEFAULT_LANGUAGE = 1
this.text_prefererences = {
    [0] = __ja,
    [1] = __en,
    [2] = __fr,
    [4] = __de,
    [3] = __it,
    [5] = __es,
    [6] = __ru,
    [7] = __pl,
    [10] = __pt_br,
    [11] = __kr,
    [12] = __zh_tw,
    [13] = __zh_cn,
    [21] = __ar,
    [32] = __es_latam
}
function this.copy_table(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end
function this.get_init_lang_table()
    local mGUI = sdk.get_native_singleton("via.gui.GUISystem")
    if not mGUI then return this.DEFAULT_LANGUAGE end
    return this.text_prefererences[sdk.call_native_func(mGUI, sdk.find_type_definition("via.gui.GUISystem"), "get_MessageLanguage") or this.DEFAULT_LANGUAGE]
end
this.retval = this.copy_table(this.get_init_lang_table())



sdk.hook(sdk.find_type_definition("via.gui.GUISystem"):get_method("set_MessageLanguage(via.Language)"), function(args)
    local code = sdk.to_int64(args[2])
    local lang_table = this.text_prefererences[code] or this.text_prefererences[1]
    for k, _ in pairs(this.retval) do
        this.retval[k] = lang_table[k]
    end
end)

return this.retval