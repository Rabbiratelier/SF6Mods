local sdk = sdk

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local load_enum = require("func/load_enum")

local this = {}
this.mod = {
    NAME = "optionmanip",
}
this.mod.active = true

local debug = {}
debug.address = nil

function this.init()
    local _man = sdk.get_managed_singleton("app.OptionManager")
    local _item = sdk.create_instance("app.Option.OptionGroupUnit")
    local _item_setting = sdk.create_instance("app.Option.OptionSettingUnit")
    -- _item_setting.TitleMessage = guid_of_somewhat
    -- System.Guid TitleMessage
    -- .pak time?

    _item:call(".ctor")
    _item_setting:call(".ctor")
    _item_setting._TypeId = 101
    _item:Setup(_item_setting)
    local _list = _man.UnitLists:get_Item(load_enum("app.Option.TabType").General)
    _list:Add(_item)
    debug.address = _list:get_address()
end



if not (current_scene_id() > load_enum("app.constant.scn.Index").eBoot) then -- not pretty much reliable in the future
    this.mod.active = false
    setup_hook("bBootFlow", "UpdatePhaseTransition", nil, function(retval)
        this.mod.active = true
        this.init()
        return retval
    end)
else

    this.init()
end

re.on_frame(function()
    if debug and debug.address then
        object_explorer:handle_address(debug.address)
    end
end)