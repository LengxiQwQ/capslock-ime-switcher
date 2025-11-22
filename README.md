## 🎉 CapsLock Input Method Switcher (Multi-Version)

## 一个大写键改成输入法切换的工具（保留大写功能）

[![Author](https://img.shields.io/badge/author-LengxiQwQ-green)](https://github.com/LengxiQwQ)
[![GitHub Repo](https://img.shields.io/badge/repo-CapsLock%20InputSwitcher-blue)](https://github.com/LengxiQwQ/Capslock-IME-Switcher)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-blue?logo=autohotkey)
![Platform](https://img.shields.io/badge/Platform-Windows%2010|11-lightgrey?logo=windows)
![Release](https://img.shields.io/github/v/release/lengxiQwQ/Capslock-IME-Switcher?label=Latest%20Release&color=orange)

**AutoHotkey v2 输入法切换增强脚本 - 作者：LengxiQwQ**

欢迎来到这个 **超级实用、可自由选择版本** 的输入法切换脚本合集！
 脚本基于 **AutoHotkey v2** 编写，专注于让你更丝滑地切换输入法，尤其适合我们这种需要**频繁切换中英文**的程序猿宝宝们😋

灵感来源于苹果的妙控键盘，**大写键就是中英文切换**，但是苹果那一套好像又不能大写了，我这个属于两者结合

 #### 😎 脚本仅占用仅1MB内存！非常轻便

 ![内存占用](./images/PixPin_2025-11-22_02-11-15.png)

不同版本侧重点不同：有的最稳，有的最全，有的极简，有的更适合调试

![演示1](./images/PixPin_2025-11-22_01-26-19.png)


------

## ⭐ 具体功能

- 将不常用的 **CapsLock** 改成 **输入法切换键**，点击**大写键**即可切换输入法

- 长按 0.2s 正常**切换大写**，再次长按或短按切回

- 目前只支持 **中文输入法** 与**英文输入法**

- 兼容 WhatsApp、Chrome、VSCode 等多种软件

- 多版本选择，让你挑到最适合自己的脚本

  ------

- ## 🧠 实现逻辑（原理）

  本项目基于 **AutoHotkey v2**，通过 **CapsLock 劫持 + 输入法识别（HKL/IME）+ 兜底切换机制**，实现稳定、可控且跨应用的中英文切换

  ------

  ### 1. 🔄 CapsLock 作为输入法切换键

  脚本重定义 **CapsLock**：

  - **短按** → 中/英切换
  - **长按** → 大小写切换

  短/长按由定时器区分，所有版本通用

  ------

  ### 2. 🧩 获取当前输入法（HKL）

  通过 Windows API：

  - **`GetForegroundWindow`**
  - **`GetKeyboardLayout`**
  - **`GetKeyboardLayoutList`**

  读取当前窗口使用的 **HKL（16 进制键盘布局值）** 来判断当前语言

  ------

  ### 3. 📟 输入法识别机制（版本差异核心）

  不同版本对输入法状态的判断方式不同：

  ------

  #### **A. 稳定识别（推荐版）**

  - 使用 HKL 主值判断“中文 / 英文”
  - 在 WhatsApp 等特殊窗口可能无法获取完整状态 → 显示 **`未知`**

  **特点：**
   最不容易出错， 但不区分多中文输入法

  ------

  #### **B. 精准识别（多输入法检测版）**

  - 用 **`GetKeyboardLayoutList`** 区分多个中文输入法
  - 中文 HKL 下使用 IME（Imm32）进一步判断中英模式

  **特点：**
  能分辨“多个中文输入法 + 中英模式”，但某些应用（WhatsApp）会返回不完整状态 → 有显示错误风险

  ------

  ### 4. 💬 输入法提示显示

  提示内容依版本变化：

  **`中`  `EN`  `A`  `未知`**  还有无提示版本

  提示跟随光标布局，不挡输入区域

  ------

  ### 5. 🧷 多版本适配（不同需求对应不同脚本）

  - ⭐ 稳定版（推荐）
  - 🧪 多输入法检测版
  - 🌙 无光标显示版
  - ⌨ Win + Space 原生切换版
  - 🔍 HKL 调试版

  ------

  ### 6. 🛡 兜底输入法切换机制

  如果主切换失败，则使用：`Send "{Blind}{LWin down}{Space}{LWin up}"`

  实现 **Win + Space 强制切换**

  

## 📥 下载方式（EXE + 脚本源代码）

本项目同时提供两种下载方式，让你按需选择：

### 🚀 **1. 免安装 EXE 版本（.exe）**

- 不需要安装 AutoHotkey

- 双击即可运行，放哪都能用

- 适合普通用户、办公电脑

- Release 页面中可直接下载


 #### 💡 EXE 与 AHK 源码功能完全一致，只是方便使用的打包版本



### 🧩 **2. 源代码版本（.ahk）**

- 适合会修改脚本、喜欢自定义的人

- 需要已安装 AutoHotkey v2，如果还没有：[官方下载](https://autohotkey.com/)

- 可自由编辑代码、学习、扩展功能

- 各版本的 `.ahk` 脚本都在仓库中可直接查看

------


## 📦 所有版本一览

| 版本                                                | 特点概述                              | 输入法【中英】名称显示             | 多输入法支持       | WhatsApp 等非标准 Win32 窗口光标显示 | 适合人群             |
| --------------------------------------------------- | ------------------------------------- | ---------------------------------- | ------------------ | ------------------------------------ | -------------------- |
| ⭐ **Recommend CapsLock Input Method Switcher**      | 最稳定的推荐版本，应用光标显示正常    | ⚠ 多个中文输入法有些会显示【未知】 | ⚠ 支持性不佳       | ✔ 完全兼容                           | 日常使用、偏稳定     |
| 🌈 **Multi IME CapsLock Input Method Switcher**      | 多中文输入法识别最完整                | ✔ 完整准确                         | ✔ 完整支持         | ⚠ 可能显示错误                       | 多输入法同时使用     |
| 🔕 **Non Cursor CapsLock Input Method Switcher**     | 极简版，没有光标提示                  | ❌ 不显示                           | ✔ 多输入法轮流切换 | ✔ 最稳定                             | 需要纯切换、极简主义 |
| ⌨️ **Win+Space only CapsLock Input Method Switcher** | 使用 Windows 原生切换方式，兼容性最强 | ❌ 显示不稳定                       | ⚠ 和第一种一样     | ✔ 最佳兼容                           | 想保持原生行为的用户 |

> 💡 所有对应的 `.exe` 都是与 `.ahk` 版本一一对应打包而成

------

## 📝 安装方法

推荐下载 `Recommend CapsLock Input Method Switcher` 仅保留单个中文输入法和 EN-US

把使用 `Shift` 临时切换中英文关掉（体验最好）

源代码版依赖 `AutoHotkey v2`，`.exe` 版免安装，双击运行即可

脚本程序需要**管理员权限**，不然无法在**有管理员权限的窗口**中切换输入法

### 设置开机启动，不然每次开机都要手动开启，方法如下：

按 `Win + R` 输入 `shell:startup` 打开启动文件夹，把 `.ahk`或`.exe`文件直接放进去即可

或者直接打开这个路径：`C:\Users\[输入你的用户名]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

------


## 💬 使用须知 & 小提示

- 本脚本依赖 **AutoHotkey v2**（仅源代码版需要）

- 多输入法显示依赖 Windows 的 HKL 机制，不同软件查询能力不同

- WhatsApp 等**非标准 Win32 窗口**限制多，因此不同版本显示效果可能不同（表格已注明）

------

## ❤️ 感谢使用！ 
