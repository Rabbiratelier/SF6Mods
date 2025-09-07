-- exit_to_desktop beta4 b20250903
-- Adds an option to exit to desktop in training mode.
-- This mod is an example of how to edit the training mode menu.
-- TODO: Button Guide Override

local sdk = sdk
local thread = thread

local setup_hook =  require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local load_enum = require("func/load_enum")

local my = {}
my.mod = {
    NAME = "exit_to_desktop",
}
my.mod.LANG_PATH = "lang/" .. my.mod.NAME .. "_lang"
my.mod.active = false
my.lang = require(my.mod.LANG_PATH)
my.enum = {}
my.enum.scn = load_enum("app.constant.scn.Index")

my.TARGET_TAB = 0

my.guid_override = {}
my.spin_children = {}
my.target_index = nil

my._ui_parts_target = nil
my._training_manager = nil
my._msg_handle = nil


function my.training_state_change(value)
    if value ~= nil and my.mod.active ~= value then
        if value then
            my.mod.active = true
            my._training_manager = sdk.get_managed_singleton("app.training.TrainingManager")
            if my._training_manager._ReturnScene ~= my.enum.scn.eESportsMainMenu then
                my.mod.active = false
                return
            end
            local _ui_data = my._training_manager._UIData._MenuData
            my.target_index = #_ui_data[my.TARGET_TAB]._ChildData-1
            local _target = _ui_data[my.TARGET_TAB]._ChildData[my.target_index]
            local messages = {my.lang.return_to, my.lang.main_menu, my.lang.desktop}
            local enum = {}
            enum.item_type = load_enum("app.training.ItemType")
            enum.item_func_type = load_enum("app.training.TrainingFuncType")

            _target._Type = enum.item_type.SPIN
            _target._FuncType = enum.item_func_type.NONE
            _target._MessageID = _target._MessageID:NewGuid()
            my.guid_override[_target._MessageID.mData4L] = table.remove(messages, 1)
            _target._ChildData = sdk.create_managed_array("app.training.TrainingMenuData", 2)
            for i=0, #_target._ChildData-1 do
                local child = sdk.create_instance("app.training.TrainingMenuData")
                child._Type = enum.item_type.SPIN_ITEM
                child._FuncType = enum.item_func_type.NONE
                child.IsEnabled = true
                child._MessageID = child._MessageID:NewGuid()
                table.insert(my.spin_children, messages[1])
                my.guid_override[child._MessageID.mData4L] = table.remove(messages, 1)
                _target._ChildData[i] = child
            end
        else
            my.mod.active = false
            my.guid_override = {}
            my.spin_children = {}
        end
    end
end
function my.create_message_confirmation()
    return sdk.find_type_definition("app.helper.hMsg"):get_method("GetMessage(System.String, System.UInt32)"):call(nil, "CommonMessage", 782)
end



-- Manage Training State Using Hooks
-- Initialize
setup_hook("app.training.TrainingManager", "BattleStart", nil,function(retval)
    my.training_state_change(true)
    return retval
end)
setup_hook("app.training.TrainingManager", "Release", nil, function(retval)
    my.training_state_change(false)
    return retval
end)
if current_scene_id() == my.enum.scn.eBattleMain then
    local currentMap = sdk.get_managed_singleton("app.bFlowManager"):get_Map():get_type_definition()
    if currentMap == sdk.find_type_definition("app.battle.TrainingFlowMap") then
        my.training_state_change(true)
    end
end

-- When Decide Button Pressed (on the Spin)
setup_hook("app.UIPartsGroupItem", "get_CanDecide()", function(args)
    local obj = sdk.to_managed_object(args[2])
    if my.mod.active and obj:get_type_definition():is_a("app.UIPartsSpin")then
        local _primary_tab = my._training_manager._UITrainingMenu._ParamData._PrimaryTab
        local _secondary_list = my._training_manager._UITrainingMenu._ParamData._SecondaryList
        if _primary_tab and _primary_tab:get_PageIndex() == my.TARGET_TAB and _secondary_list and _secondary_list:GetFocusIndex() == my.target_index then
            my._ui_parts_target = _secondary_list:GetFocusItem()
            thread.get_hook_storage()["this"] = my.spin_children[my._ui_parts_target:get_Num()+1]
        end
    end
end, function(retval)
    local str = thread.get_hook_storage()["this"]
    if str then
        my._msg_handle = sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("Start"):call(nil, string.format(my.lang.confirmation_message, str), my.create_message_confirmation(), 0, 1, 4, -1, 1)
        my._training_manager:Save(nil, nil)
    end
    return retval
end)

-- Message Box Close
-- Terminate Application or Return to Main Menu when "Yes" is Selected
setup_hook("app.UIFlowDialog.MessageBoxMain", "OnExit", function()
    if my._msg_handle and my._ui_parts_target then
        if sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("GetSelectValue"):call(nil,my._msg_handle) == 0 then
            if my._ui_parts_target:get_Num() == 0 then
                sdk.find_type_definition("app.helper.flow"):get_method("requestTransitionHomeScene"):call(nil)
            else
                sdk.call_native_func(sdk.get_native_singleton("via.havok.System"), sdk.find_type_definition("via.havok.System"), "terminate")
                my.mod.active = false
            end
        end
    end
    my._msg_handle = nil
end)

-- Message Override
setup_hook("app.helper.hMsg", "GetMessage(System.Guid)", function(args)
    if my.mod.active then
        local message = my.guid_override[sdk.to_valuetype(args[2], "System.Guid").mData4L]
        if message then
            thread.get_hook_storage()[1] = message
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end
end, function(retval)
    if my.mod.active and thread.get_hook_storage()[1] then
        return sdk.to_ptr(sdk.create_managed_string(thread.get_hook_storage()[1]))
    end
    return retval
end)