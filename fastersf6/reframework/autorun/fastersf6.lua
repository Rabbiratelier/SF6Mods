-- You can play around with something at conf/fastersf6_conf.lua.
local sdk = sdk
local re = re
local json = json

local setup_hook = require("func/setup_hook")
local current_scene_id = require("func/current_scene_id")
local show_custom_ticker = require("func/show_custom_ticker")
local was_key_down = require("func/was_key_down")
local load_enum = require("func/load_enum")

local my = {}
my.conf = require("conf/fastersf6_conf")
my.lang = require("lang/fastersf6_lang")
my.mod = {}
my.mod.SAVE_FILE = (my.conf.SAVE_PER_USER and sdk.call_native_func(sdk.get_native_singleton("via.Steam"), sdk.find_type_definition("via.Steam"), "get_AccountId") .. "." or "") .. "fastersf6.save.json"
my.mod.active = (function()
    local scn = load_enum("app.constant.scn.Index")
    local boot_scn = {
        [scn.eNone] = true,
        [scn.eBoot] = true,
        [scn.eBootSetup] = true,
        [scn.eTitle] = true,
        [scn.eLogin] = true,
        [-1] = true,
    }
    return boot_scn[current_scene_id()] or false
end)()

my.END_PHASE = sdk.to_ptr(load_enum("app.FlowPhase.eState").NEXT)

my.destination = my.mod.active and my.conf.FIRST_DESTINATION or 0
my.save = json.load_file(my.mod.SAVE_FILE) or {}
my.save.fighter_id = my.save.fighter_id or -1
my.save.theme_id = my.save.theme_id or -1
my.save.comment_id = my.save.comment_id or -1
my.save.comment_option = my.save.comment_option or -1
my.save.pose_id = my.save.pose_id or -1
my.save.title_id = my.save.title_id or -1
my.save.input_type = my.save.input_type or -1
my.save.dlc = my.save.dlc ~= nil and my.save.dlc or {}

my._fighter_data = nil

function my.hook_interrupt_phase()
    return my.END_PHASE
end
function my.hook_skip_phase()
    return sdk.PreHookResult.SKIP_ORIGINAL
end
function my.hook_destroy(args)
    local obj = sdk.to_managed_object(args[2])
    obj.mIsEndState = true
    obj.mIsSkipEnable = true
    obj:SetState(2)
    obj:ReqSkipState()
    obj:set_Enabled(false)
end

function my.create_message_main_menu()
    return string.format(my.lang.booting, my.lang.main_menu)
end
function my.create_message_main_menu_with_guide()
    return my.destination == 1 and string.format(my.lang.booting .. "\n" .. my.lang.switch_prompt, my.lang.main_menu) or my.create_message_main_menu()
end
function my.create_message_training_mode()
    return string.format(my.lang.booting, my.lang.training_mode)
end
function my.create_message_training_mode_with_guide()
    return my.destination == 2 and string.format(my.lang.booting .. "\n" .. my.lang.switch_prompt, my.lang.training_mode) or my.create_message_training_mode()
end
function my.create_message_first_boot()
    return my.lang.first_boot
end
function my.create_message_dlc_change()
    return my.lang.dlc_detected
end
function my.show_destination_ticker()
    local messenger = {[1] = my.create_message_main_menu, [2] = my.create_message_training_mode}
    show_custom_ticker(messenger[my.destination], my.conf.TICKER_TIME)
end
function my.show_destination_ticker_with_guide()
    local messenger = {[1] = my.create_message_main_menu_with_guide, [2] = my.create_message_training_mode_with_guide}
    show_custom_ticker(messenger[my.destination], my.conf.TICKER_TIME)
end
function my.update_fighter_settings()
    local _temp_man = sdk.get_managed_singleton("app.TemporarilyDataManager").Data
    my.save.fighter_id = _temp_man._MatchingFighterId
    my.save.theme_id = _temp_man.ThemeId
    my.save.comment_id = _temp_man.CommentId
    my.save.comment_option = _temp_man.CommentOption
    my.save.pose_id = _temp_man.AvatarPose
    local miscData = _temp_man.MatchingFighterSetting:ToArray()
    for _, v in pairs(miscData) do
        if v.FighterId == my.save.fighter_id then
            my.save.title_id = v.TitleId
            my.save.input_type = v.MatchingFighterInputStyle
        end
    end
    json.dump_file(my.mod.SAVE_FILE, my.save)
end
function my.is_valid_fighter_id(id)
    return id >= 1
end
function my.apply_fighter_settings()
    if not my._fighter_data then
        local _temp_man = sdk.get_managed_singleton("app.TemporarilyDataManager")
        if not (_temp_man and _temp_man.Data) then
            return
        end
        my._fighter_data = _temp_man.Data
    end
    if my.is_valid_fighter_id(my.save.fighter_id) then
        my._fighter_data._MatchingFighterId = my.save.fighter_id
        my._fighter_data.ThemeId = my.save.theme_id
        my._fighter_data.CommentId = my.save.comment_id
        my._fighter_data.CommentOption = my.save.comment_option
        my._fighter_data.AvatarPose = my.save.pose_id
    end
end
function my.check_for_new_dlc()
    if my.destination > 0 then
        local _dlc_manager = sdk.get_managed_singleton("app.DlcManager")
        if _dlc_manager then
            local dlc_list = {}
            local dlc_name_enum_def = sdk.find_type_definition("app.AppDefine.DlcData")
            for _,v in pairs(dlc_name_enum_def:get_fields()) do
                if v:get_type() == dlc_name_enum_def then
                    re.msg(v .. ": ".. _dlc_manager:GetProductId(v))
                    local id = math.tointeger(_dlc_manager:GetProductId(v))
                    if id then
                        local steam_def = sdk.find_type_definition("via.Steam")
                        local steam_obj = sdk.get_native_singleton("via.Steam")
                        dlc_list[tostring(id)] = sdk.call_native_func(steam_obj, steam_def, "isInstalledDlc(System.UInt64)", id)
                    end
                end
            end

            local dlc_changed = false
            for k, v in pairs(dlc_list) do
                if my.save.dlc[k] ~= v then
                    dlc_changed = true
                    break
                end
            end
            for k, v in pairs(my.save.dlc) do
                if dlc_list[k] ~= v then
                    dlc_changed = true
                    break
                end
            end
            if dlc_changed then
                my.destination = -2
                show_custom_ticker(my.create_message_dlc_change)
            end
            my.save.dlc = {}
            for k, v in pairs(dlc_list) do
                my.save.dlc[k] = v
            end
            json.dump_file(my.mod.SAVE_FILE, my.save)
        else
            setup_hook("app.DlcManager", "doStart", nil, my.check_for_new_dlc)
        end
    end
end



--Initialize (choosing destination)
my.destination = my.is_valid_fighter_id(my.save.fighter_id) and my.destination or -1
if my.destination > 0 then
    my.check_for_new_dlc()
end

--Only When the Game is Booting
if my.mod.active then
    --Logo Skips
    setup_hook("app.bBootFlow", "UpdatePhaseIllegalCopy", nil, my.hook_interrupt_phase)
    setup_hook("app.bBootFlow", "UpdatePhasePhotosensitive", nil, my.hook_interrupt_phase)
    setup_hook("app.bBootFlow", "UpdatePhaseLogo", nil, my.hook_interrupt_phase)
    setup_hook("app.bBootFlow", "UpdatePhaseNoticeCore", nil, my.hook_interrupt_phase)
    setup_hook("app.bBootFlow", "StartPhaseIllegalCopy", my.hook_skip_phase)
    setup_hook("app.bBootFlow", "StartPhasePhotosensitive", my.hook_skip_phase)
    setup_hook("app.bBootFlow", "StartPhaseLogo", my.hook_skip_phase)

    --Removing Logo Ghost
    setup_hook("app.UIFlowNotice", "lateUpdate", my.hook_destroy)
    setup_hook("app.UIFlowLogo", "lateUpdate", my.hook_destroy)

    --Called Immediately after Entering the Main Menu
    --Call Training Mode if Demand
    setup_hook("app.menu.ModeSelectMain", "updateWait", function(args)
        if my.destination == -1 then
            my.update_fighter_settings()
        end
        if my.destination < 0 then
            my.destination = my.conf.FIRST_DESTINATION
        end
        if my.destination == 2 then
            sdk.to_managed_object(args[2]):call("updateTransitionToTrainingWithMatching(app.FlowPhase.dUpdatePhase, System.Single)", args[3], 0)
        end
        my.apply_fighter_settings()
        my.destination = 0
        my.mod.active = false
    end)
    setup_hook("app.UIFlowMatchingSetting.Param", "BeforeShowObject", function(args)
        my.apply_fighter_settings()
    end)

    --When First Boot or Else
    if my.destination == -1 then
        --Show First Boot Initial Notification
        show_custom_ticker(my.create_message_first_boot)
    elseif my.destination > 0 then
        --Manually Load Character Preferences in case when Login Asyncronously
        --Also Show General Initial Notification
        setup_hook("app.TemporarilyDataManager", "GetFighterSettingData", function(args)
            my.apply_fighter_settings()
        end,function(retval)
            local obj = sdk.to_managed_object(retval)
            if obj and obj.FighterId == my.save.fighter_id and #sdk.get_managed_singleton("app.TemporarilyDataManager").Data.MatchingFighterSetting:ToArray() == 0 then
                obj.TitleId = my.save.title_id
                obj.MatchingFighterInputStyle = my.save.input_type
                if my._fighter_data then
                    my._fighter_data.MatchingFighterSetting:Add(obj)
                end
            end
            return sdk.to_ptr(obj)
        end)
        setup_hook("app.TemporarilyDataManager.TemporarilyData", ".ctor", function(args)
            my._fighter_data = sdk.to_managed_object(args[2])
            my.apply_fighter_settings()
        end)
        if my.conf.SHOW_FIRST_TICKER then
            my.show_destination_ticker_with_guide()
        end
    end
end

--Title Skip
setup_hook("app.BootSetupFlow", "UpdatePhaseTransition", nil, function()
    sdk.find_type_definition("app.helper.flow"):get_method("requestTransitionLoginScene"):call(nil, 1)
    return my.END_PHASE
end)

--Make Login Process Done Asynchronous
setup_hook("app.bLoginFlow", "updateLogin", nil, function(retval)
    if my.destination > 0 and not my.conf.SAFE_MODE then
        return my.END_PHASE
    end
    return retval
end)

--Update Character Preferences as well when Matching Settings Get Updated
setup_hook("app.UIFlowMatchingSetting.Param", "OnEnd", nil, function(retval)
    my.update_fighter_settings()
    return retval
end)

--Handle Player Input to Switch the Destination
re.on_frame(function()
    if my.destination > 0 and was_key_down(my.conf.SWITCHER_KEY_CODE) then
        my.destination = my.destination == 1 and 2 or 1
        my.show_destination_ticker()
    end
end)