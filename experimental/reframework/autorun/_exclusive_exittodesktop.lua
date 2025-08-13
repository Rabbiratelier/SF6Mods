local setup_hook = require("func/setup_hook")

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

local names = {}
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


setup_hook("app.training.UIFlowTrainingMenu.Param", "InitSecondaryList", function(args)
    local param = sdk.get_managed_singleton("app.training.TrainingManager")._UITrainingMenu._ParamData
    local index = param:get_PrimaryListIndex()
    if index == 0 then
        local dataList = param._ViewDataList
        table.insert(names, "InitSecondaryList: " .. dataList:get_Count())
        dataList:get_Item(dataList:get_Count()-1).Data.IsEnabled = false
    end
end)

re.on_frame(function()
    if #names > 40 then
        names = {table.unpack(names, #names - 39, #names)}
    end
    for k,v in pairs(names) do
        imgui.text(v)
    end
end)