#Requires AutoHotkey v2.0
#SingleInstance Force

; ========== 1. 自动以管理员身份运行 ==========
if not A_IsAdmin
{
    try
    {
        Run "*RunAs `"" A_ScriptFullPath "`""
    }
    catch
    {
        MsgBox "无法提升权限，请手动以管理员身份运行脚本。"
    }
    ExitApp
}

; ========== 2. 全局配置与状态追踪 ==========
holdTime := 200     ; 大写长按阈值（毫秒）
tipLife  := 1000    ; 输入法提示显示时长（毫秒）
checkDelay := 100   ; 切换后的延迟检测时间（毫秒）

; 核心：内部状态追踪变量，false=EN, true=中
global LastKnownStateIsChinese := false 

; 用于 API 切换的 HKL 加载 (保留，因为 ActivateKeyboardLayout 需要 HKL)
CHS_HKL_LOADED := DllCall("LoadKeyboardLayoutW", "WStr", "00000804", "UInt", 1, "Ptr") ; 中文
ENG_HKL_LOADED := DllCall("LoadKeyboardLayoutW", "WStr", "00000409", "UInt", 1, "Ptr") ; 英文

; 定义 Language ID 常量 (用于判断，避免使用 HKL 指针)
CHS_LANG_ID := 0x0804 ; 简体中文 Language ID
ENG_LANG_ID := 0x0409 ; 英文 Language ID

; =================================================================
; 3. 核心功能：CapsLock热键
; =================================================================
CapsLock::
{
    global holdTime, tipLife, checkDelay, CHS_HKL_LOADED, ENG_HKL_LOADED, LastKnownStateIsChinese, CHS_LANG_ID, ENG_LANG_ID

    start := A_TickCount
    longTriggered := false

    ; --- 长按检测定时器 ---
    timerFunc := () => (
        !longTriggered && (A_TickCount - start >= holdTime) && (
            longTriggered := true,
            newState := !GetKeyState("CapsLock", "T"),
            SetCapsLockState(newState ? "On" : "Off"),
            tip := newState ? "A" : (LastKnownStateIsChinese ? "中" : "EN"),
            ShowTipAtMouse(tip, tipLife)
        )
    )
    SetTimer(timerFunc, 20)

    KeyWait "CapsLock"
    SetTimer(timerFunc, 0)

    if (longTriggered)
        return

    ; ---------- 短按：切换中英文 & 状态同步 ----------
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    if !hwnd
        return

    threadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    currentLangID := currentHKL & 0xFFFF ; 提取 Language ID

    ; 确定目标 HKL：根据 Language ID 确定切换目标 HKL (使用 loaded HKL for API call)
    targetHKL := (currentLangID == CHS_LANG_ID) ? ENG_HKL_LOADED : CHS_HKL_LOADED

    ; 1. API 优先切换
    DllCall("ActivateKeyboardLayout", "Ptr", targetHKL, "UInt", 0)
    Sleep(20)

    ; 2. 兜底按键切换 (总是执行，确保 Win+Space 触发系统切换)
    Send("{LWin Down}{Space}{LWin Up}")
    Sleep(checkDelay)

    ; 获取最终 HKL 和 Language ID
    newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    newLangID := newHKL & 0xFFFF

    tip := "" ; 最终显示的提示文本

    ; --- 3. 状态判断逻辑：混合追踪 (使用 Language ID 进行可靠判断) ---
    
    ; A) HKL 报告清晰状态 (可靠窗口)
    if (newLangID == CHS_LANG_ID || newLangID == ENG_LANG_ID)
    {
        if (newLangID == CHS_LANG_ID) {
             ; 窗口可靠，检查中文输入法内部的 中/EN 模式 (Imm32 API)
             isChineseMode := CheckIMEConversionStatus(hwnd)
             tip := isChineseMode ? "中" : "EN"
             LastKnownStateIsChinese := isChineseMode ; 状态同步到系统实际值
        } else {
             tip := "EN" ; 纯英文布局
             LastKnownStateIsChinese := false ; 状态同步到系统实际值
        }
    }
    ; B) HKL 报告不清晰状态 (不可靠窗口，如 WhatsApp)
    else 
    {
        ; 窗口不可靠，执行状态切换
        LastKnownStateIsChinese := !LastKnownStateIsChinese ; 切换内部追踪状态
        tip := LastKnownStateIsChinese ? "中" : "EN" ; 显示追踪状态
    }

    ShowTipAtMouse(tip, tipLife)
    SetCapsLockState("Off")
}
return

; =================================================================
; 4. 辅助函数
; =================================================================

; 检测中文输入法的中/EN模式 (通过 Imm32 API)
CheckIMEConversionStatus(hwnd) {
    ; ... 逻辑不变
    try {
        hIME := DllCall("Imm32.dll\ImmGetDefaultIMEWnd", "Ptr", hwnd, "Ptr")
        if (hIME) {
            res := SendMessage(0x283, 0x0005, 0, , "ahk_id " hIME)
            return (res != 0) ? 1 : 0
        }
    } catch {
        return 1
    }
    return 0
}

; 在鼠标上方显示提示
ShowTipAtMouse(text, life := 400) {
    MouseGetPos &mx, &my
    ToolTip text, mx + 20, my + 20 
    SetTimer(() => ToolTip(""), -life)
}