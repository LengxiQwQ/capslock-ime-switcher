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
; ====================================================

; ========== 配置参数 ==========
holdTime := 200     ; 大写长按阈值（毫秒）
tipLife  := 1000    ; 输入法提示显示时长（毫秒）

; ========== 主逻辑 ==========
CapsLock::
{
    global holdTime, tipLife

    start := A_TickCount
    longTriggered := false

    ; --- 长按检测定时器 ---
    ; 如果按下 CapsLock 超过 holdTime，判定为开启大写
    timerFunc := () => (
        !longTriggered && (A_TickCount - start >= holdTime) && (
            longTriggered := true,
            newState := !GetKeyState("CapsLock", "T"),
            SetCapsLockState(newState ? "On" : "Off"),
            ShowTipAtMouse(newState ? "A" : GetActiveWindowLang(), tipLife)
        )
    )
    SetTimer(timerFunc, 20)

    ; --- 等待松开按键 ---
    KeyWait "CapsLock"

    ; --- 停止定时器 ---
    SetTimer(timerFunc, 0)

    ; 如果已经触发了长按功能（大写锁定），则结束，不切换输入法
    if (longTriggered)
        return

    ; ========== 短按：发送 Win + Space ==========
    ; 模拟按下 Win + Space
    Send("{LWin Down}{Space}{LWin Up}")
    
    ; 稍微等待一下，让系统完成切换。
    ; 如果发现经常切过去了但提示还是旧的，可以将 50 改成 100
    Sleep(50) 

    ; 获取当前窗口的语言状态并显示
    currentLang := GetActiveWindowLang()
    ShowTipAtMouse(currentLang, tipLife)
    
    ; 确保物理的大写锁定状态是关闭的
    SetCapsLockState("Off")
}
return

; ========== 获取当前窗口的输入法语言 ==========
GetActiveWindowLang() {
    try {
        ; 获取当前激活窗口的句柄
        hwnd := DllCall("GetForegroundWindow", "Ptr")
        if !hwnd
            return "未知"
            
        ; 获取该窗口线程的 ID
        threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
        
        ; 获取键盘布局句柄 (HKL)
        hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
        
        ; 获取低位字（语言标识符）
        langId := hkl & 0xFFFF

        if (langId == 0x0804) ; 中文 (中国)
            return "中"
        else if (langId == 0x0409) ; 英文 (美国)
            return "EN"
        else
            return "Else" ; 其他语言默认归类为 EN
    } catch {
        return "未知"
    }
}

; ========== 在鼠标上方显示提示 ==========
ShowTipAtMouse(text, life := 400) {
    MouseGetPos &mx, &my
    ToolTip text, mx - 55, my - 55
    SetTimer(() => ToolTip(""), -life)
}