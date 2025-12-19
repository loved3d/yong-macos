# yong-macos

macOS 输入法项目，将 [@qwertyyb/Fire](https://github.com/qwertyyb/Fire) 的 IMK 接口实现与 [@dgod/yong](https://github.com/dgod/yong) 的核心引擎结合。

## 项目概述

yong-macos 是一个 macOS 输入法，通过结合两个优秀的开源项目：
- **Fire**: 提供 macOS InputMethodKit (IMK) 框架的实现
- **yong**: 提供强大的中文输入法引擎

## 项目结构

```
yong-macos/
├── yong-macos/
│   ├── Sources/              # Swift 源代码
│   │   ├── YongAppDelegate.swift           # 应用主入口
│   │   ├── YongInputController.swift       # IMK 输入控制器
│   │   └── yong-macos-Bridging-Header.h   # C/Swift 桥接头文件
│   ├── Resources/            # 资源文件
│   │   ├── Info.plist                      # 应用配置
│   │   └── MainMenu.xib                    # 主菜单
│   └── Engine/               # yong 引擎接口
│       ├── yong_engine.h                   # C 头文件
│       └── yong_engine.c                   # C 实现（mock）
└── yong-macos.xcodeproj/     # Xcode 项目
```

## 功能特性

### 已实现功能
- ✅ 基于 IMK 框架的输入法架构
- ✅ 拼音输入基础支持
- ✅ 候选词显示
- ✅ 数字键选词
- ✅ C/Swift 混合编程桥接

### 当前状态
- 包含 mock 拼音引擎实现
- 支持基本的拼音输入：ni, hao, nihao, ma, wo, shi, de 等
- 支持数字键（1-9）选择候选词
- 支持退格键编辑输入
- 支持 ESC 取消输入
- 支持空格选择第一个候选词

### 待完成功能
- ⏳ 集成完整的 yong 引擎
- ⏳ 支持五笔输入
- ⏳ 用户词库管理
- ⏳ 配置界面
- ⏳ 更多输入方案

## 构建说明

### 前置要求
- macOS 11.0+
- Xcode 14.0+
- Swift 5.0+

### 构建步骤

1. 克隆仓库
```bash
git clone https://github.com/loved3d/yong-macos.git
cd yong-macos
```

2. 使用 Xcode 打开项目
```bash
open yong-macos.xcodeproj
```

3. 在 Xcode 中构建
- 选择 yong-macos scheme
- 点击 Product > Build (⌘B)

### 安装

构建成功后，输入法 app 位于：
```
DerivedData/yong-macos/Build/Products/Debug/yong-macos.app
```

将其复制到输入法目录：
```bash
sudo cp -r DerivedData/yong-macos/Build/Products/Debug/yong-macos.app \
  "/Library/Input Methods/"
```

然后：
1. 打开"系统设置" > "键盘" > "输入法"
2. 点击 "+" 添加输入法
3. 选择"中文"，找到并添加"Yong"
4. 重启系统或注销后重新登录

## 开发说明

### IMK 框架架构

项目使用 Apple 的 InputMethodKit (IMK) 框架：

- **YongAppDelegate**: 应用入口，初始化 IMKServer
- **YongInputController**: 继承自 IMKInputController，处理输入事件
- **IMKCandidates**: 候选词窗口管理

### C/Swift 桥接

使用 Bridging Header 实现 Swift 调用 C 代码：
- `yong_engine.h`: C 引擎接口定义
- `yong_engine.c`: 引擎实现
- `yong-macos-Bridging-Header.h`: 桥接头文件

### 集成 yong 引擎

当前使用 mock 实现，要集成真实的 yong 引擎：

1. 下载 yong 源代码
2. 将核心引擎文件添加到 Engine/ 目录
3. 在 `yong_engine.c` 中调用 yong 的 API
4. 更新 Xcode 项目配置

## 技术参考

### 相关项目
- [qwertyyb/Fire](https://github.com/qwertyyb/Fire) - macOS 五笔输入法
- [dgod/yong](https://github.com/dgod/yong) - yong 输入法引擎
- [Apple InputMethodKit](https://developer.apple.com/documentation/inputmethodkit)

### 文档
- [InputMethodKit 官方文档](https://developer.apple.com/documentation/inputmethodkit)
- [IMKInputController 文档](https://developer.apple.com/documentation/inputmethodkit/imkinputcontroller)

## 许可证

本项目代码采用开源许可证发布。注意：
- 集成的 yong 引擎遵循其原始许可证
- IMK 接口实现参考了 Fire 项目的架构

## 贡献

欢迎提交 Issue 和 Pull Request！

## 联系方式

- 项目主页: https://github.com/loved3d/yong-macos
- 问题反馈: https://github.com/loved3d/yong-macos/issues