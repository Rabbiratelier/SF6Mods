local sdk = sdk

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local load_enum = require("func/load_enum")

local this = {}
this.mod = {
    NAME = "optionmanip",
}
this.mod.active = true

function this.init()
    local _man = sdk.get_managed_singleton("app.OptionManager")
    local _item = sdk.find_type_definition("app.Option.OptionGroupUnit"):create_instance()
    -- _item.TitleMessage = guid_of_somewhat
    -- System.Guid TitleMessage
    -- .pak time?

    _item:call(".ctor")
    _man.UnitLists:get_Item(load_enum("app.Option.TabType").General):Add(_item)
end



if current_scene_id() > load_enum("app.constant.scn.Index").eBoot then -- not pretty much reliable in the future
    this.mod.active = false
    setup_hook("bBootFlow", "UpdatePhaseTransition", nil, function(retval)
        this.mod.active = true
        this.init()
        return retval
    end)
else
    this.init()
end