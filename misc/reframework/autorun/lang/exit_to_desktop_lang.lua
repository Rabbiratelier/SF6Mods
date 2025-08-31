-- We want better translations! If you can help, please contact me on Nexus Mods.
local sdk = sdk

local __en = {
    return_to = "Return to",
    main_menu = "main menu",
    desktop = "desktop",
    confirmation_message = "Are you sure you want to return to %s?"
}

local __ja = {
    return_to = "戻る",
    main_menu = "メインメニュー",
    desktop = "デスクトップ",
    confirmation_message = "%sに戻ってもよろしいですか？"
}

local __fr = {
    return_to = "Retour à",
    main_menu = "menu principal",
    desktop = "bureau",
    confirmation_message = "Êtes-vous sûr de vouloir revenir à %s ?"
}

local __de = {
    return_to = "Zurück zu",
    main_menu = "Hauptmenü",
    desktop = "Desktop",
    confirmation_message = "Möchtest du wirklich zu %s zurückkehren?"
}

local __it = {
    return_to = "Torna a",
    main_menu = "menu principale",
    desktop = "desktop",
    confirmation_message = "Sei sicuro di voler tornare a %s?"
}

local __es = {
    return_to = "Volver a",
    main_menu = "menú principal",
    desktop = "escritorio",
    confirmation_message = "¿Seguro que quieres volver a %s?"
}

local __ru = {
    return_to = "Вернуться к",
    main_menu = "главному меню",
    desktop = "рабочему столу",
    confirmation_message = "Вы уверены, что хотите вернуться к %s?"
}

local __pl = {
    return_to = "Powrót do",
    main_menu = "menu główne",
    desktop = "pulpit",
    confirmation_message = "Czy na pewno chcesz wrócić do %s?"
}

local __pt_br = {
    return_to = "Voltar para",
    main_menu = "menu principal",
    desktop = "área de trabalho",
    confirmation_message = "Tem certeza de que deseja voltar para %s?"
}

local __kr = {
    return_to = "돌아가기",
    main_menu = "메인 메뉴",
    desktop = "데스크탑",
    confirmation_message = "%s로 돌아가시겠습니까?"
}

local __zh_cn = {
    return_to = "返回",
    main_menu = "主菜单",
    desktop = "桌面",
    confirmation_message = "确定要返回到%s吗？"
}

local __zh_tw = {
    return_to = "返回",
    main_menu = "主選單",
    desktop = "桌面",
    confirmation_message = "確定要返回到%s嗎？"
}

local __ar = {
    return_to = "العودة إلى",
    main_menu = "القائمة الرئيسية",
    desktop = "سطح المكتب",
    confirmation_message = "هل أنت متأكد أنك تريد العودة إلى %s؟"
}

local __es_latam = {
    return_to = "Volver a",
    main_menu = "menú principal",
    desktop = "escritorio",
    confirmation_message = "¿Seguro que quieres volver a %s?"
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