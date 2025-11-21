# 🎉 CapsLock Input Method Switcher (Multi-Version)
# 一个大写键改成输入法切换的工具（保留大写功能）

[![Author](https://img.shields.io/badge/author-LengxiQwQ-green)](https://github.com/LengxiQwQ)
[![GitHub Repo](https://img.shields.io/badge/repo-CapsLock%20InputSwitcher-blue)](https://github.com/LengxiQwQ/CapsLock-InputSwitcher)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-blue?logo=autohotkey)
![Platform](https://img.shields.io/badge/Platform-Windows%2010|11-lightgrey?logo=windows)
![Release](https://img.shields.io/github/v/release/lengxiQwQ/Capslock-IME-Switcher?label=Latest%20Release&color=orange)

**AutoHotkey v2 输入法切换增强脚本 - 作者：LengxiQwQ**

欢迎来到这个 **超级实用、可自由选择版本** 的输入法切换脚本合集！
 脚本基于 **AutoHotkey v2** 编写，专注于让你更丝滑地切换输入法，尤其适合 Windows 上多中文输入法 + 英文输入法的用户。

不同版本侧重点不同：
 有的最稳，有的最全，有的极简，有的更适合调试，一定有一个版本合你口味 💖

------

# ⭐ 具体功能

- 将不常用的 **CapsLock** 改成 **输入法切换键**，点击即可切换输入法。
- 长按 0.2s 正常**切换大写**，再次长按或短按切回。
- 目前只支持 **中文输入法** 与**英文输入法**
- 兼容 WhatsApp、Chrome、VSCode 等多种软件
- 多版本选择，让你挑到最适合自己的脚本

------

# 📥 下载方式（源代码 + EXE）

本项目同时提供两种下载方式，让你按需选择：

### 🚀 **1. 免安装 EXE 版本（.exe）**

- 不需要安装 AutoHotkey

- 双击即可运行，放哪都能用

- 适合普通用户、办公电脑

- Release 页面中可直接下载


 #### 💡 EXE 与 AHK 源码功能完全一致，只是方便使用的打包版本



### 🧩 **2. 源代码版本（.ahk）**

- 适合会修改脚本、喜欢自定义的人
- 需要已安装 AutoHotkey v2。如果还没有？[官方下载](https://autohotkey.com/)
- 可自由编辑代码、学习、扩展功能
- 各版本的 `.ahk` 脚本都在仓库中可直接查看

------


# 📦 所有版本一览

| 版本                                              | 特点概述                                   | 输入法【中英】名称显示             | 多输入法支持 | WhatsApp 等非标准 Win32 窗口 | 适合人群             |
| ------------------------------------------------- | ------------------------------------------ | ---------------------------------- | ------------ | ---------------------------- | -------------------- |
| ⭐ **多输入法会显示未知**.ahk                      | 最稳定的推荐版本，应用兼容正常（光标显示） | ⚠ 多个中文输入法有些会显示【未知】 | ✔ 支持       | ✔ 完全兼容                   | 日常使用、偏稳定     |
| 🌈 **支持多输入法检测版本**.ahk                    | 功能最全，输入法中英文识别最完整           | ✔ 完整准确                         | ✔ 完整支持   | ⚠ 可能显示错误               | 多输入法同时使用     |
| 🔕 **不带光标显示**.ahk                            | 极简版，没有光标提示                       | ❌ 不显示                           | ✔ 支持       | ✔ 最稳定                     | 需要纯切换、极简主义 |
| 🧪 **检测输入法 HKL 值**.ahk                       | 输入法调试工具，用来查看 HKL 值            | ✔ 显示 HKL 16进制值                | ✔ 支持       | ✔                            | 开发者、AHK 学习     |
| ⌨️ 大写键输入法切换工具－ **只用 Win + Space**.ahk | 使用 Windows 原生切换方式，兼容性最强      | ❌ 显示不稳定                       | ✔ 系统级支持 | ✔ 最佳兼容                   | 想保持原生行为的用户 |

> 💡 所有对应的 `.exe` 都是与 `.ahk` 版本一一对应打包而成。

------

# 📝 安装方法

源代码版依赖 `AutoHotkey v2` `.exe` 版免安装，双击运行即可。

### 设置开机启动，不然每次开机都要手动开启，方法如下：

按 `Win + R` 输入 `shell:startup` 打开启动文件夹，把 `脚本`或`.exe`文件直接放进去即可

或者直接打开这个路径：`C:\Users\[输入你的用户名]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

------


# 💬 使用须知 & 小提示

- 本脚本依赖 **AutoHotkey v2**（仅源代码版需要）
- 多输入法显示依赖 Windows 的 HKL 机制，不同软件查询能力不同
- WhatsApp 等非标准 Win32 窗口限制多，因此不同版本显示效果可能不同（表格已注明）

------

# ❤️ 感谢使用！ 
