#Requires AutoHotkey v2.0
#SingleInstance Force
; ========== 自动以管理员身份运行 ==========
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

; ========== 配置参数 ==========
holdTime := 200     ; 大写长按阈值（毫秒）
tipLife  := 1000    ; 输入法提示显示时长（毫秒）
checkDelay := 20   ; 切换失败延迟检测时间（毫秒）

; 预加载输入法布局（HKL）
CHS_HKL := DllCall("LoadKeyboardLayoutW", "WStr", "00000804", "UInt", 1, "Ptr") ; 中文（简体拼音）
ENG_HKL := DllCall("LoadKeyboardLayoutW", "WStr", "00000409", "UInt", 1, "Ptr") ; 英文（美式）

; ========== 主逻辑 ==========
CapsLock::
{
    global holdTime, tipLife, checkDelay, CHS_HKL, ENG_HKL

    start := A_TickCount
    longTriggered := false

    ; 新增定时检测是否长按
    timerFunc := () => (
        !longTriggered && (A_TickCount - start >= holdTime) && (
            longTriggered := true,
            newState := !GetKeyState("CapsLock", "T"),
            SetCapsLockState(newState ? "On" : "Off"),
            ShowTipAtMouse(newState ? "A" : GetSystemLangText(), tipLife)
        )
    )
    SetTimer(timerFunc, 20)

    ; 等待松开
    KeyWait "CapsLock"

    ; 停止检测
    SetTimer(timerFunc, 0)

    ; 如果已经触发过长按功能，就不再切换输入法
    if (longTriggered)
        return

    ; ---------- 短按：切换中英文 ----------
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    if !hwnd
        return

    threadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    targetHKL := (currentHKL = CHS_HKL) ? ENG_HKL : CHS_HKL

    ; 优先使用 API 切换
    DllCall("ActivateKeyboardLayout", "Ptr", targetHKL, "UInt", 0)
    Sleep(20)

    ; 初次检测
    newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    switched := (newHKL = targetHKL)

    ; 兜底检测（针对 WhatsApp）
    if (!switched)
    {
        Send("{LWin Down}{Space}{LWin Up}")
        Sleep(checkDelay)
        newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
        switched := (newHKL = targetHKL)
    }

    ; ---------- 显示切换结果 ----------
    if (switched)
        tip := GetSystemLangText()
    else
        tip := "未知"

    if (tip = "")
        tip := (targetHKL = ENG_HKL) ? "EN" : "中"

    ShowTipAtMouse(tip, tipLife)
    SetCapsLockState("Off")
}
return

; ========== 获取系统级输入法文字 ==========
GetSystemLangText() {
    lang := DllCall("GetKeyboardLayout", "UInt", DllCall("GetCurrentThreadId"), "Ptr")
    low := lang & 0xFFFF
    if (low = 0x0409)
        return "EN"
    else if (low = 0x0804)
        return "中"
    else
        return "未知"
}

; ========== 在鼠标上方显示提示 ==========
ShowTipAtMouse(text, life := 400) {
    MouseGetPos &mx, &my
    ToolTip text, mx - 55, my - 55
    SetTimer(() => ToolTip(""), -life)
}
