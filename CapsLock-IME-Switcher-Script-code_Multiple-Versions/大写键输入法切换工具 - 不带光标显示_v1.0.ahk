#Requires AutoHotkey v2.0
#SingleInstance Force

; =================================================================
; 1. 自动以管理员身份运行
; =================================================================
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

; =================================================================
; 2. 全局配置
; =================================================================
holdTime   := 200    ; 长按判断阈值（毫秒）
checkDelay := 20    ; 兜底方案等待时间（毫秒） - 保留此项以确保 WhatsApp 兜底生效

; 预加载输入法布局 HKL
CHS_HKL := DllCall("LoadKeyboardLayoutW", "WStr", "00000804", "UInt", 1, "Ptr") 
ENG_HKL := DllCall("LoadKeyboardLayoutW", "WStr", "00000409", "UInt", 1, "Ptr") 

; =================================================================
; 3. CapsLock 主逻辑 (纯净版)
; =================================================================
CapsLock::
{
    global holdTime, checkDelay, CHS_HKL, ENG_HKL

    start := A_TickCount
    longTriggered := false

    ; --- 长按检测 (无显示) ---
    timerFunc := () => (
        !longTriggered && (A_TickCount - start >= holdTime) && (
            longTriggered := true,
            newState := !GetKeyState("CapsLock", "T"),
            SetCapsLockState(newState ? "On" : "Off")
        )
    )
    SetTimer(timerFunc, 20)

    KeyWait "CapsLock"
    SetTimer(timerFunc, 0)

    if (longTriggered)
        return

    ; --- 短按切换 (保留兜底，无显示) ---
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    if !hwnd
        return

    threadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    
    ; 决定目标
    targetHKL := (currentHKL = CHS_HKL) ? ENG_HKL : CHS_HKL

    ; 方法一：API 切换
    DllCall("ActivateKeyboardLayout", "Ptr", targetHKL, "UInt", 0)
    Sleep(20)

    ; 验证切换结果
    newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    switched := (newHKL = targetHKL)

    ; 兜底方案：如果 API 失败（switched 为 false），执行 Win+Space
    if (!switched)
    {
        Send("{LWin Down}{Space}{LWin Up}")
        Sleep(checkDelay) ; 保留等待，确保切换生效
    }

    ; 确保短按不开启大写灯
    SetCapsLockState("Off")
}
return
