local sdk = sdk
local imgui = imgui
local re = re
local thread = thread
local json = json
local Vector2f = Vector2f
local reframework = reframework

local CONFIG_PATH = "replaylabs_sf6.config.json"
local MOD_NAME = "ReplayLabs"
local FLAG_TRANSPARENT = 0x81

local KEY_CTRL = 0x11
local KEY_U = 0x55
local KEY_I = 0x49

local MESSAGE = {
    PREVENT_KO_SKIP = "Prevent K.O. Skip",
    NEVER_SHOW = "Never Show Again",
    CTRL_U_DESC = "to toggle window",   
    CTRL_I_DESC = "to toggle transparent background",
    SHOW_HINT = "Show Hint"
}

local this = {}
this.config = json.load_file(CONFIG_PATH) or {}
this.config.window_show = this.config.window_show or true
this.config.window_altflags_on = this.config.window_altflags_on or false
this.config.prevent_skip = this.config.prevent_skip or false
this.config.never_show_hint = this.config.never_show_hint or false

this.window_pos = this.config.window_pos_x and this.config.window_pos_y and 
    Vector2f.new(this.config.window_pos_x, this.config.window_pos_y) or 
    imgui.get_display_size() * 0.25

this.is_replay = false
this.is_opened = false
this.needs_dismiss = false
this.window_size_y = Vector2f.new(0, 0)
this.key_ready = true
this.additional_flag = 0
this.hint_show = true

local function setup_hook(type_name, method_name, pre_func, post_func)
    local type_def = sdk.find_type_definition(type_name)
    if type_def then
        local method = type_def:get_method(method_name)
        if method then
            sdk.hook(method, pre_func, post_func)
        end
    end
end

setup_hook("app.battle.bBattleFlow", "endReplay", nil, function()
    this.is_replay = false
    this.needs_dismiss = this.is_opened
end)

setup_hook("app.battle.bBattleFlow", "updateReplayRoundResult", nil, function(retval)
    return this.is_replay and sdk.to_ptr(2) or retval
end)

setup_hook("app.battle.bBattleFlow", "updateReplayKO", nil, function(retval)
    return (this.is_replay and not this.config.prevent_skip) and sdk.to_ptr(2) or retval
end)

setup_hook("nBattle.sPlayer", "IsDemoCancel", nil, function(retval)
    return this.is_replay and sdk.to_ptr(true) or retval
end)

setup_hook("app.esports.bBattleFighterEmoteFlow", "setup", function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2])
end, function(retval)
    local obj = thread.get_hook_storage()["this"]
    if obj and obj.mInputType == 3 and not this.is_replay then
        this.is_replay = true
        if this.config.window_show then
            this.showWindow()
        end
        obj.mWaitTime = 0.0016
    end
    return this.is_replay and sdk.to_ptr(2) or retval
end)

setup_hook("app.esports.bBattleFighterEmoteFlow", "playTimeline", nil, function(retval)
    return this.is_replay and sdk.to_ptr(2) or retval
end)

setup_hook("app.esports.bBattleFighterEmoteFlow", "fadeOut", nil, function(retval)
    return this.is_replay and sdk.to_ptr(2) or retval
end)

setup_hook("app.esports.bBattleFighterEmoteFlow", "releaseWait", nil, function(retval)
    return this.is_replay and sdk.to_ptr(2) or retval
end)

re.on_draw_ui(function()
    if imgui.tree_node(MOD_NAME) then
        if this.is_opened and imgui.button(MESSAGE.SHOW_HINT) then
            this.hint_show = true
        end
        imgui.tree_pop()
    end
end)

re.on_frame(function()
    local changed = false

    if not this.key_ready and not reframework:is_key_down(KEY_U) and not reframework:is_key_down(KEY_I) then
        this.key_ready = true
    end

    if this.is_opened then
        if this.key_ready then
            if reframework:is_key_down(KEY_CTRL) and reframework:is_key_down(KEY_I) then
                this.config.window_altflags_on = not this.config.window_altflags_on
                this.additional_flag = this.config.window_altflags_on and FLAG_TRANSPARENT or 0
                changed = true
                this.key_ready = false
            end
            if reframework:is_key_down(KEY_CTRL) and reframework:is_key_down(KEY_U) then
                this.config.window_show = false
                this.needs_dismiss = true
                changed = true
                this.key_ready = false
            end
        end



        imgui.set_next_window_pos(this.window_pos, 1 << 3, 0)
        imgui.begin_window(MOD_NAME, nil, 0x10160 | this.additional_flag)

        if this.needs_dismiss then
            this.window_pos = imgui.get_window_pos()
            this.config.window_pos_x = this.window_pos.x
            this.config.window_pos_y = this.window_pos.y
            this.is_opened = false
            this.needs_dismiss = false
            changed = true
        end

        local clicked, value = imgui.checkbox(MESSAGE.PREVENT_KO_SKIP, this.config.prevent_skip)
        if clicked then
            this.config.prevent_skip = value
            changed = true
        end

        this.window_size_y = this.window_size_y.y > 0 and this.window_size_y or Vector2f.new(0, imgui.get_window_size().y + 16)
        imgui.end_window()

        if this.hint_show then
            local hint_return = this.renderHintWindow(this.window_pos + this.window_size_y)
            if hint_return[1] then
                this.config.never_show_hint = hint_return[2]
                changed = true
            end
            if hint_return[3] then
                this.hint_show = false
            end
        end
    elseif this.is_replay and this.key_ready and reframework:is_key_down(KEY_CTRL) and reframework:is_key_down(KEY_U) then
        this.config.window_show = true
        this.is_opened = true
        this.key_ready = false
        changed = true
    end

    if changed then
        json.dump_file(CONFIG_PATH, this.config)
    end
end)

function this.showWindow()
    this.hint_show = not this.config.never_show_hint
    this.is_opened = true
    this.additional_flag = this.config.window_altflags_on and FLAG_TRANSPARENT or 0
end

function this.renderHintWindow(pos)
    local retval = {}
    imgui.set_next_window_pos(pos, 1 << 3, 0)
    imgui.begin_window(MOD_NAME .. "dummy", nil, 0x10161 | this.additional_flag)

    if imgui.tree_node("Hint") then
        imgui.new_line()
        imgui.text("Ctrl + U")
        imgui.text(MESSAGE.CTRL_U_DESC)
        imgui.text("Ctrl + I")
        imgui.text(MESSAGE.CTRL_I_DESC)
        retval[1], retval[2] = imgui.checkbox(MESSAGE.NEVER_SHOW, this.config.never_show_hint)
        imgui.same_line()
        retval[3] = imgui.button("dismiss")
        imgui.tree_pop()
    end

    imgui.end_window()
    return retval
end
