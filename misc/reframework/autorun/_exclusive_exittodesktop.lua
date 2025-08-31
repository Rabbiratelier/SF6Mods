-- Add option to exit to desktop in training mode
-- Choose destination first, then press decide key on the spin
-- Will not work in online training modes. Exclusion to be implemented.
-- TODO: Add localization support

local sdk = sdk
local thread = thread

local setup_hook =  require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")

local this = {}
this.is_in_training = false
this.guid_override = {}
this._training_manager = nil
this.target_index = nil
this.spin_children = {}
this._msg_handle = nil

function this.set_is_in_training(value)
    if value ~= nil and this.is_in_training ~= value then
        this.is_in_training = value
        if this.is_in_training then
            this._training_manager = sdk.get_managed_singleton("app.training.TrainingManager")
            local _ui_data = this._training_manager._UIData._MenuData
            this.target_index = #_ui_data[0]._ChildData-1
            local _target = _ui_data[0]._ChildData[this.target_index]
            local messages = {"Return To", "Main Menu", "Desktop"}

            _target._Type = 1
            _target._FuncType = 0
            _target._MessageID = _target._MessageID:NewGuid()
            this.guid_override[_target._MessageID] = table.remove(messages, 1)
            _target._ChildData = _ui_data[6]._ChildData[0]._ChildData
            for _, child in pairs(_target._ChildData) do
                child._FuncType = 0
                child._MessageID = child._MessageID:NewGuid()
                table.insert(this.spin_children, messages[1])
                this.guid_override[child._MessageID] = table.remove(messages, 1)
            end
        else
            this.guid_override = {}
            this.spin_children = {}
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

-- When Decide Button Pressed (on the Spin)
setup_hook("app.UIPartsGroupItem", "get_CanDecide()", function(args)
    if this.is_in_training then
        local _target = this._training_manager._UITrainingMenu._ParamData._SecondaryList._Children[this.target_index]:GetFocusChild()
        if sdk.to_managed_object(args[2]):Equals(_target) then
            thread.get_hook_storage()["this"] = this.spin_children[_target:get_Num()+1]
        end
    end
end, function(retval)
    local str = thread.get_hook_storage()["this"]
    if str then
        this._msg_handle = sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("Start"):call(nil, "Are you sure want to return to " .. str .. "?", nil, 0, 1, 4, 1, 1)
        this._training_manager:Save(nil, nil)
    end
    return retval
end)

-- Message Box Close
-- Terminate Application or Return to Main Menu when "Yes" is Selected
setup_hook("app.UIFlowDialog.MessageBoxMain", "OnExit", function()
    if this._msg_handle then
        if sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("GetSelectValue"):call(nil,this._msg_handle) == 0 then
            if this._training_manager._UITrainingMenu._ParamData._SecondaryList._Children[this.target_index]:GetFocusChild():get_Num() == 0 then
                sdk.find_type_definition("app.helper.flow"):get_method("requestTransitionHomeScene"):call(nil)
            else
                sdk.call_native_func(sdk.get_native_singleton("via.havok.System"), sdk.find_type_definition("via.havok.System"), "terminate")
                this.is_in_training = false
            end
        end
        this._msg_handle = nil
    end
end)

-- Message Override
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