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
tipLife  := 2000    ; 提示显示时长（毫秒，为了看清 HKL 值，时间加长）

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
            ; 长按时显示 A，并显示当前的 HKL 值
            ShowTipAtMouse("A + HKL: " GetInputMethodID(), tipLife) 
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

    ; ---------- 短按：执行切换并诊断 HKL 值 ----------
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    if !hwnd
        return

    threadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    targetHKL := (currentHKL = CHS_HKL) ? ENG_HKL : CHS_HKL

    ; 1. 优先使用 API 切换
    DllCall("ActivateKeyboardLayout", "Ptr", targetHKL, "UInt", 0)
    Sleep(20)

    ; 初次检测 (您的原脚本逻辑)
    newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    switched := (newHKL = targetHKL)

    ; 2. 兜底检测（发送 Win+Space）
    if (!switched)
    {
        Send("{LWin Down}{Space}{LWin Up}")
        Sleep(checkDelay)
        ; 再次检测 HKL
        newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
        switched := (newHKL = targetHKL)
    }

    ; ---------- 显示切换后的 HKL 值 ----------
    tip := GetInputMethodID() 
    
    ; 增加一个标签，判断是否通过 HKL 切换成功
    tipLabel := switched ? "HKL 切换成功 | ID: " : "HKL 切换失败 | ID: "
    
    ShowTipAtMouse(tipLabel . tip, tipLife)
    SetCapsLockState("Off")
}
return

; ========== HKL 诊断函数：返回当前活动窗口的 HKL 十六进制值 ==========
GetInputMethodID() {
    try {
        hwnd := DllCall("GetForegroundWindow", "Ptr")
        if !hwnd
            return "N/A" 

        ; 获取前景窗口的线程 ID
        threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0)
        
        ; 调用 GetKeyboardLayout 获取 HKL 指针值
        hklPtr := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
        
        ; HKL 是一个 Ptr (指针/句柄)。格式化为十六进制字符串。
        return Format("{:X}", hklPtr)
    } catch {
        return "ERROR"
    }
}

; ========== 在鼠标上方显示提示 ==========
ShowTipAtMouse(text, life := 400) {
    MouseGetPos &mx, &my
    ToolTip text, mx - 55, my - 55
    SetTimer(() => ToolTip(""), -life)
}