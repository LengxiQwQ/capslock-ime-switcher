#Requires AutoHotkey v2.0 
; 脚本要求使用 AutoHotkey v2.0 版本。

#SingleInstance Force
; 确保脚本只运行一个实例。如果脚本已经运行，新的实例会强制替换掉旧的实例。

; =================================================================
; 1. 自动以管理员身份运行 (必须)
; =================================================================
if not A_IsAdmin
; 检查当前脚本是否以管理员身份运行。A_IsAdmin 是一个内置变量。
{
    try
    ; 尝试执行以下代码块。
    {
        ; 重新运行脚本，并请求提升权限 (RunAs)。
        ; *RunAs 标志告诉操作系统请求 UAC 权限。
        ; A_ScriptFullPath 是当前脚本的完整路径。
        Run "*RunAs `"" A_ScriptFullPath "`""
    }
    catch
    ; 如果尝试失败（如权限被拒绝），则执行此代码块。
    {
        ; 弹出消息框提示用户手动操作。
        MsgBox "无法提升权限，请手动以管理员身份运行脚本。"
    }
    ExitApp
    ; 退出当前未以管理员身份运行的脚本实例。
}

; =================================================================
; 2. 全局配置
; =================================================================
holdTime   := 200     ; 长按判断阈值（毫秒）：如果按键时间超过 200ms，则视为“长按”。
tipLife    := 1000    ; 提示显示时长（毫秒）：切换输入法或大写后，提示信息（ToolTip）显示 1000ms。
checkDelay := 100     ; 兜底方案切换后的等待检测时间（毫秒）：当 API 切换失败，使用 Win+Space 兜底后，等待 100ms 再检测输入法状态。

; 预加载输入法布局 HKL (用于 API 调用)
; HKL (Handle to Keyboard Layout) 是键盘布局的句柄，用于 Windows API 调用。
CHS_HKL := DllCall("LoadKeyboardLayoutW", "WStr", "00000804", "UInt", 1, "Ptr") ; 简体中文 (0804 是语言 ID)
ENG_HKL := DllCall("LoadKeyboardLayoutW", "WStr", "00000409", "UInt", 1, "Ptr") ; 英文（美式）(0409 是语言 ID)

; =================================================================
; 3. CapsLock 主逻辑：长按 = 大写；短按 = 切换输入法（含兜底）
; =================================================================
CapsLock::
; 定义 CapsLock 键的自定义行为（热键）。
{
    global holdTime, tipLife, checkDelay, CHS_HKL, ENG_HKL
    ; 声明使用在全局配置中定义的变量。

    start := A_TickCount
    ; 记录按键按下的起始时间点（毫秒）。A_TickCount 是一个内置变量。
    longTriggered := false
    ; 标记长按功能是否已被触发，初始设置为否。

    ; 长按检测定时器（长按显示 A / 当前语言）
    timerFunc := () => (
    ; 定义一个匿名函数作为定时器的回调函数。
        ; 逻辑：如果长按功能未触发 且 按下时间 >= 长按阈值 且 满足以下条件：
        !longTriggered && (A_TickCount - start >= holdTime) && (
            longTriggered := true,
            ; 触发长按后，将标记设置为 true。
            newState := !GetKeyState("CapsLock", "T"),
            ; 获取当前 CapsLock 的状态（T - Toggle State），并取反得到新的目标状态。
            SetCapsLockState(newState ? "On" : "Off"),
            ; 设置实际的 CapsLock 状态（打开或关闭大写锁定）。
            hwnd := DllCall("GetForegroundWindow", "Ptr"),
            ; 调用 Windows API 获取当前活动窗口的句柄 (HWND)。
            ShowTipAtMouse(newState ? "A" : GetSystemLangText(hwnd), tipLife)
            ; 显示提示：如果打开大写锁定显示 "A"，否则显示当前系统语言（通过辅助函数获取）。
        )
    )
    SetTimer(timerFunc, 20)
    ; 启动定时器，每 20 毫秒执行一次 timerFunc 函数来检测是否满足长按条件。

    KeyWait "CapsLock"
    ; 等待 CapsLock 键松开。脚本执行会在此处暂停，直到按键释放。
    SetTimer(timerFunc, 0)
    ; 一旦按键松开，立即关闭长按检测定时器 (将重复间隔设为 0)。

    if (longTriggered)
        return
    ; 如果长按功能已经被触发，则直接退出，不执行下面的短按逻辑。

    ; --- 短按：切换输入法 ---
    hwnd := DllCall("GetForegroundWindow", "Ptr")
    ; 再次获取当前活动窗口句柄。
    if !hwnd
        return
    ; 如果没有活动窗口（例如在桌面），则退出脚本。

    threadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
    ; 调用 API 获取窗口所属线程的 ID (用于后续获取输入法)。
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    ; 调用 API 获取当前线程使用的键盘布局句柄 (HKL)。
    currentLangID := currentHKL & 0xFFFF
    ; HKL 的低 16 位是语言 ID (Language ID)，用于判断当前语言。

    ; 决定目标：如果当前是中文（语言ID 0x0804）就切英文，否则切中文（以便在多输入法场景下也能工作）
    targetHKL := (currentLangID == 0x0804) ? ENG_HKL : CHS_HKL
    ; 三元表达式：如果当前语言是中文 (0x0804)，目标是英文 HKL；否则目标是中文 HKL。

    ; 方法一：API 切换
    DllCall("ActivateKeyboardLayout", "Ptr", targetHKL, "UInt", 0)
    ; 调用 API 直接激活目标键盘布局 (HKL)，这是最直接的方式。
    Sleep(20)
    ; 暂停 20 毫秒，给系统时间来完成输入法切换。

    ; 验证 API 是否生效（按 pointer 比较）
    newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    ; 再次获取切换后的 HKL。
    switched := (newHKL = targetHKL)
    ; 检查新的 HKL 是否等于我们想要的目标 HKL。

    ; 兜底：如果 API 失败（如 WhatsApp），发送 Win+Space 再检测
    if (!switched)
    ; 如果 API 切换失败（!switched 为 true）。
    {
        Send("{LWin Down}{Space}{LWin Up}")
        ; 模拟按下并释放 Win+Space 组合键，这是 Windows 默认的输入法切换快捷键（兜底方案）。
        Sleep(checkDelay)
        ; 等待 checkDelay (100ms) 以确保 Win+Space 切换完成。
        newHKL := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
        ; 再次获取 HKL 进行验证。
        switched := (newHKL = targetHKL)
        ; 再次检查是否切换成功。
    }

    ; 显示逻辑：
    ; - 如果最终 switched == false（API + Win+Space 都没有将系统切到目标），直接显示 "未知"
    ; - 如果 switched == true，则根据系统当前的 Language ID 显示 "中"/"EN"/"未知"（支持多输入法）
    if (!switched)
    {
        tip := "未知"
        ; 两次尝试都失败，显示“未知”。
    }
    else
    {
        finalLangID := newHKL & 0xFFFF
        ; 提取最终 HKL 的语言 ID。
        if (finalLangID == 0x0804)
            tip := "中"
        else if (finalLangID == 0x0409)
            tip := "EN"
        else
            tip := "未知"
        ; 根据语言 ID 设置提示文本。
    }

    ShowTipAtMouse(tip, tipLife)
    ; 调用辅助函数在鼠标位置显示最终的提示。

    ; 短按不保持物理 CapsLock 灯
    SetCapsLockState("Off")
    ; 确保 CapsLock 键的物理灯光（大写锁定状态）保持关闭，因为短按是用于切换输入法，而不是大写锁定。
}
return
; 结束 CapsLock 热键的定义。

; =================================================================
; 4. 辅助函数
; =================================================================

; 获取指定窗口当前的语言文本（hwnd 必传或传 0 返回 EN 作为兜底）
GetSystemLangText(hwnd) {
    ; 函数定义：用于获取当前窗口的输入法状态，并返回 'EN' / '中' / '未知'。
    if !hwnd
        return "EN"
    ; 如果没有窗口句柄，返回默认的 'EN'。
    threadID := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", 0)
    ; 获取窗口线程 ID。
    lang := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")
    ; 获取键盘布局 HKL。
    low := lang & 0xFFFF
    ; 提取语言 ID。
    if (low == 0x0409)
        return "EN"
    else if (low == 0x0804)
        return "中"
    else
        return "未知"
    ; 根据语言 ID 返回对应的提示文本。
}

; 在鼠标位置显示 ToolTip
ShowTipAtMouse(text, life := 400) {
    ; 函数定义：在鼠标位置显示一个短暂的提示。life 默认为 400ms。
    MouseGetPos &mx, &my
    ; 获取当前鼠标指针的 X 和 Y 坐标，并存储到变量 mx 和 my 中。
    ToolTip text, mx - 20, my - 20
    ; 在鼠标坐标 (mx, my) 左上角 (偏移 -20, -20) 显示 ToolTip 文本。
    SetTimer(() => ToolTip(""), -life)
    ; 启动一个一次性定时器（负数表示只运行一次），在 life 毫秒后执行清空 ToolTip 的操作。
}