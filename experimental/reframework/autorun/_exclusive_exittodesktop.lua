-- local setup_hook = require("func/setup_hook")

--UIPartsGroupScroll SecondaryList
-- 0  UIPartsGroup
-- 1  UIPartsGroup
-- 2  UIPartsGroup
-- 3  UIPartsGroup
-- 4  UIPartsGroup
-- 5  UIPartsGroup
-- 6  UIPartsGroup
-- 7  UIPartsGroup
-- 8  UIPartsGroup
-- 9  UIPartsGroup
-- 10 UIPartsGroup
-- 11 UIPartsGroup
-- 12 UIPartsGroup
-- ↑それぞれの要素にその子をSetFocusIndexでロードする。（孫オブジェクトが実体になる）
--UIPartsScrollText => ButtonGuide
--UIPartsGroup->(12までコントロール、それ以降ほかの何か)

--app.UIPartsGroup.SetFocusIndex => 親グループ(20,20) フォーカス変更のたび呼ばれる。 20要素のUIPartsGroupを含む
--                                  子グループ(20) タブ変更時など、タブの初期化のとき呼ばれる。 タブ内の要素数だけ呼ばれ、初期化前のグループをロードする（各要素はUIPartsGroupItemが初期値）。postで初期化済み。



--!todo need to find a list(?) which defines a SecondaryTab

-- local names = {}
-- setup_hook("app.training.UIFlowTrainingMenu.Param", "Start", function(args)
--     local obj = sdk.to_managed_object(args[2])
--     for i = 0, 6 do
--         obj._SecondaryList:GetChild(i*2):SetFocusIndex(4)
--     end
-- end)
-- setup_hook("app.training.UIFlowTrainingMenu.Param", "SetMsgItem(app.UIPartsItem, System.String, System.String, System.Object[])", function(args)
--     if sdk.to_managed_object(args[3]):Equals(sdk.to_managed_object(args[2])._SecondaryList:GetChild(2):GetFocusChild()) then
--         table.insert(names, "THIS👇")
--     end
--     table.insert(names, sdk.to_managed_object(args[4]):ToString() .. ": " .. sdk.to_managed_object(args[5]):ToString())
-- end)
-- setup_hook("app.UIPartsGroup", "SetFocusIndex", function(args)
--     thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2])
-- end,function(retval)
--     local obj = thread.get_hook_storage()["this"]
--     table.insert(names, obj:get_type_definition():get_name())
--     if obj:GetFocusChild() then
--         if obj:GetFocusChild():get_type_definition() == sdk.find_type_definition("app.UIPartsGroup") then
--             table.insert(names, obj:GetFocusIndex() .. ": " .. obj:GetFocusChild():GetFocusChild():get_type_definition():get_name() .. " " .. obj:GetFocusChild():GetFocusIndex())
--             -- table.insert(names, obj:GetFocusChild():GetFocusChild():get_Layout())
--             -- table.insert(names, obj:GetChild(12):GetFocusChild():get_Layout())
--         else
--             table.insert(names, "  " .. obj:GetFocusChild():get_type_definition():get_name() .. " " .. obj:GetFocusIndex())
--         end
--     end

--     if #names > 20 then
--         names = {table.unpack(names, #names - 19, #names)}
--     end
-- end)

--name of control
-- setup_hook("app.training.UIFlowTrainingMenu.Param", "SetMsgItem(app.UIPartsItem, System.String, System.String, System.Object[])", function(args)
--     if sdk.to_managed_object(args[3]):Equals(sdk.to_managed_object(args[2])._SecondaryList:GetFocusChild():GetFocusChild()) then
--         table.insert(names, sdk.to_managed_object(args[5]):ToString())
--         args[5] = sdk.to_ptr(sdk.create_managed_string("a"))
--     end
-- end)

--app.training.TrainingMenuData COULD BE A THING
--app.training.TrainingMenuData COULD BE A THING
--app.training.TrainingMenuData COULD BE A THING
--app.training.TrainingMenuData COULD BE A THING
--app.training.TrainingMenuData COULD BE A THING

--sdk.get_managed_singleton("app.training.TrainingManager")._UITrainingMenu._ParamData
--it is spotted at param._ViewDataList:get_Item(any).Data

--function -> app.training.TrainingMenuFunc.Function()

--just tick isreqrefresh if you need restart

-- setup_hook("app.UIPartsTrainingSecondaryTab", "Construct(System.Collections.Generic.List`1<System.String>)", function(args)
--     -- local options = sdk.to_managed_object(args[3]):ToArray()
--     local obj = sdk.to_managed_object(args[2])
--     thread.get_hook_storage()["this"] = obj
-- end,function(retval)
--     local obj = thread.get_hook_storage()["this"]    
--     table.insert(names, obj.TabItemNum)
--     return retval
-- end)


-- local param -- will be initialized later
-- local index -- will be initialized later
-- local dataList -- will be initialized later
-- setup_hook("app.training.UIFlowTrainingMenu.Param", "InitSecondaryList", function()
--     param = sdk.get_managed_singleton("app.training.TrainingManager")._UITrainingMenu._ParamData
--     index = param:get_PrimaryListIndex()
--     dataList = param._ViewDataList
-- end, function()
--     -- table.insert(names, "InitSecondaryList: " .. #dataList:ToArray())
--     if index == 0 then
--         -- dataList:get_Item(dataList:get_Count()-1).Data.IsEnabled = false
--         dataList:Clear()
--     end
-- end)

-- re.on_frame(function()
--     if #names > 40 then
--         names = {table.unpack(names, #names - 39, #names)}
--     end
--     for k,v in pairs(names) do
--         imgui.text(v)
--     end
-- end)



-- NEW CODE BELOW
local sdk = sdk

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")

local this = {}
this.is_in_training = false

function this.set_is_in_training(value)
    if value ~= nil and this.is_in_training ~= value then
        this.is_in_training = value
        if this.is_in_training then
            local _man = sdk.get_managed_singleton("app.training.TrainingManager")
            local _ui_data = _man._UIData._MenuData
            _ui_data[0]._ChildData[#_ui_data[0]._ChildData-1]._Type = 1
            _ui_data[0]._ChildData[#_ui_data[0]._ChildData-1]._ChildData = _ui_data[6]._ChildData[0]._ChildData
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

setup_hook("app.UIPartsGroupItem", "get_CanDecide()", nil, function()
return sdk.to_ptr(true)
end)

re.on_frame(function()
    imgui.text(this.is_in_training and "true" or "false")
    if imgui.button("Exit to Desktop") then
        sdk.find_type_definition("app.UIFlowDialog.MessageBox"):get_method("Start"):call(nil, "", "", 0, 1, 4, -1, 1)
    end
end)