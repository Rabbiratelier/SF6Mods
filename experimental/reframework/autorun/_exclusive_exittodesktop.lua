local sdk = sdk
local thread = thread

local setup_hook =  quire("func/setup_hook")
local current_scene_id = require("func/current_scene_id")

local this = {}
this.is_in_training = false
this.guid_override = {}
this._training_manager = nil
this.target_index = nil
this._msg_handle = nil

function this.set_is_in_training(value)
    if value ~= nil and this.is_in_training ~= value then
        this.is_in_training = value
        if this.is_in_training then
            this._training_manager = sdk.get_managed_singleton("app.training.TrainingManager")
            local _ui_data = this._training_manager._UIData._MenuData
            this.target_index = #_ui_data[0]._ChildData-1
            local _target = _ui_data[0]._ChildData[this.target_index]
            -- TODO: Localization
            local messages = {"Return To", "Main Menu", "Desktop"}

            _target._Type = 1
            _target._FuncType = 0
            _target._MessageID = _target._MessageID:NewGuid()
            this.guid_override[_target._MessageID] = table.remove(messages, 1)
            _target._ChildData = _ui_data[6]._ChildData[0]._ChildData
            for _, child in pairs(_target._ChildData) do
                child._FuncType = 0
                child._MessageID = child._MessageID:NewGuid()
                this.guid_override[child._MessageID] = table.remove(messages, 1)
            end
        else
            this.guid_override = {}
        end
    end
end



-- Manage Training State Using Hooks
-- Initialize
setup_hook("app.training.TrainingManager", "BattleStart", nil,function(retval)
    this.set_is_in_training(true)
    return retval
end)
setup_hook("app.training.TrainingManager", "Release", nil, function(retval)
    this.set_is_in_training(false)
    return retval
end)
if current_scene_id() == sdk.find_type_definition("app.constant.scn.Index"):create_instance():get_field("eBattleMain") then
    local currentMap = sdk.get_managed_singleton("app.bFlowManager"):get_Map():get_type_definition()
    if currentMap == sdk.find_type_definition("app.battle.TrainingFlowMap") then
        this.set_is_in_training(true)
    end
end

setup_hook("app.UIPartsGroupItem", "get_CanDecide()", function(args)
    if this.is_in_training then
        local _target = this._training_manager._UITrainingMenu._ParamData._SecondaryList._Children[this.target_index]:GetFocusChild()
        if sdk.to_managed_object(args[2]):Equals(_target) then
            thread.get_hook_storage()["this"] = "BIGNATURALS"
        end
    end
end, function(retval)
    local str = thread.get_hook_storage()["this"]
    if str then
        this._msg_handle = sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("Start"):call(nil, "Are you sure want to return to " .. str .. "?", "Confirmation", 0, 1, 4, -1, 1)
    end
    return retval
end)

setup_hook("app.helper.hMsg", "GetMessage(System.Guid)", function(args)
    if this.is_in_training then
        local source = sdk.to_valuetype(args[2], "System.Guid")
        for guid, message in pairs(this.guid_override) do
            if source:Equals(guid) then
                thread.get_hook_storage()["this"] = sdk.to_ptr(sdk.create_managed_string(message))
            end
        end
    end
end, function(retval)
    if thread.get_hook_storage()["this"] then
        return thread.get_hook_storage()["this"]
    end
    return retval
end)
setup_hook("app.UIFlowDialog.MessageBoxMain", "OnExit", function()
    if this._msg_handle then
        if sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("GetSelectValue"):call(nil,this._msg_handle) == 0 then
            sdk.call_native_func(sdk.get_native_singleton("via.Application"), sdk.find_type_definition("via.Application"), "exit", 0)
        end
        this._msg_handle = nil
    end
end)