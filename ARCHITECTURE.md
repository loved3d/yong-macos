# yong-macos 架构图

## 系统架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        macOS 操作系统                             │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │              InputMethodKit Framework                      │  │
│  │  (IMKServer, IMKInputController, IMKCandidates)           │  │
│  └────────────────────────────────────────────────────────────┘  │
│                             ▲                                     │
│                             │                                     │
└─────────────────────────────┼─────────────────────────────────────┘
                              │
                              │ IMK APIs
                              │
┌─────────────────────────────┼─────────────────────────────────────┐
│                             ▼                                     │
│                  yong-macos Application                           │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                   Swift IMK Layer                          │  │
│  │                                                            │  │
│  │  YongAppDelegate.swift                                    │  │
│  │  ├─ applicationDidFinishLaunching()                       │  │
│  │  └─ Initialize IMKServer                                  │  │
│  │                                                            │  │
│  │  YongInputController.swift                                │  │
│  │  ├─ handle(_:client:)         # 键盘事件处理              │  │
│  │  ├─ updateComposition()       # 更新输入组合              │  │
│  │  ├─ candidates(_:)            # 返回候选词                │  │
│  │  └─ getCandidates(for:)       # 获取候选词                │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                             ▲                                     │
│                             │ Swift/C Bridge                      │
│                             ▼                                     │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │              yong-macos-Bridging-Header.h                 │  │
│  │                 (C/Swift 桥接层)                           │  │
│  └────────────────────────────────────────────────────────────┘  │
│                             ▲                                     │
│                             │                                     │
│                             ▼                                     │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                    C Engine Layer                          │  │
│  │                                                            │  │
│  │  yong_engine.h / yong_engine.c                            │  │
│  │  ├─ yong_engine_init()                                    │  │
│  │  ├─ yong_engine_get_candidates()                          │  │
│  │  ├─ yong_engine_free_candidates()                         │  │
│  │  └─ yong_engine_cleanup()                                 │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                             ▲                                     │
│                             │ Engine API (待集成)                 │
│                             ▼                                     │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │              yong 核心引擎 (待集成)                         │  │
│  │                                                            │  │
│  │  - 拼音输入引擎                                            │  │
│  │  - 五笔输入引擎                                            │  │
│  │  - 词库管理                                                │  │
│  │  - 智能预测                                                │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
```

## 数据流程

### 输入流程

```
用户按键
   │
   ▼
macOS 系统捕获
   │
   ▼
IMK Framework
   │
   ▼
YongInputController.handle(_:client:)
   │
   ├─── 字母/数字 ──► 添加到 composingBuffer
   │
   ├─── 退格键 ────► 删除最后字符
   │
   ├─── 空格键 ────► 选择首选候选词
   │
   ├─── 数字键 ────► 选择对应候选词
   │
   ├─── ESC ───────► 取消输入
   │
   └─── 回车 ──────► 提交当前输入
   │
   ▼
updateComposition()
   │
   ▼
getCandidates(for: composingBuffer)
   │
   ▼
yong_engine_get_candidates(input, candidates, max_count)
   │
   ▼
[当前: Mock 拼音表查询]
[未来: yong 引擎处理]
   │
   ▼
返回候选词数组
   │
   ▼
显示候选词窗口 (IMKCandidates)
   │
   ▼
用户选择候选词
   │
   ▼
插入选中文本到应用
```

## 模块依赖关系

```
┌─────────────────┐
│  Application    │
│     Layer       │
│                 │
│ - Info.plist    │
│ - MainMenu.xib  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   IMK Layer     │
│                 │
│ - AppDelegate   │
│ - InputCtrl     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│  Bridge Layer   │◄─────┤   Resources  │
│                 │      │              │
│ - Bridging-H    │      │ - 词库文件   │
└────────┬────────┘      │ - 配置文件   │
         │               └──────────────┘
         ▼
┌─────────────────┐
│  Engine Layer   │
│                 │
│ - yong_engine.h │
│ - yong_engine.c │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  yong Engine    │
│   (待集成)       │
│                 │
│ - Core Engine   │
│ - Dictionary    │
└─────────────────┘
```

## 文件组织

```
yong-macos/
│
├── yong-macos.xcodeproj/        # Xcode 项目配置
│   └── project.pbxproj
│
├── yong-macos/                  # 源代码
│   │
│   ├── Sources/                 # Swift 代码
│   │   ├── YongAppDelegate.swift
│   │   ├── YongInputController.swift
│   │   └── yong-macos-Bridging-Header.h
│   │
│   ├── Engine/                  # C 引擎代码
│   │   ├── yong_engine.h
│   │   └── yong_engine.c
│   │
│   └── Resources/               # 资源文件
│       ├── Info.plist
│       └── MainMenu.xib
│
├── scripts/                     # 构建脚本
│   ├── build.sh
│   ├── install.sh
│   └── uninstall.sh
│
└── docs/                        # 文档
    ├── README.md
    ├── DESIGN.md
    ├── INTEGRATION_GUIDE.md
    ├── CONTRIBUTING.md
    ├── QUICKREF.md
    └── TODO.md
```

## 技术栈

```
┌─────────────────────────────────────┐
│          开发语言                    │
├─────────────────────────────────────┤
│  Swift 5.0+      │  用户界面和 IMK  │
│  C               │  引擎接口和实现  │
│  Objective-C     │  系统框架桥接    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│          框架和工具                  │
├─────────────────────────────────────┤
│  InputMethodKit  │  输入法框架      │
│  Cocoa           │  macOS UI        │
│  Xcode           │  IDE 和构建工具  │
│  Git             │  版本控制        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│          第三方组件                  │
├─────────────────────────────────────┤
│  yong engine     │  输入法引擎      │
│  (待集成)        │                  │
└─────────────────────────────────────┘
```

## 部署架构

```
开发环境
   │
   ├─ 编写代码 (Xcode)
   ├─ 本地测试
   └─ Git 提交
   │
   ▼
构建流程
   │
   ├─ xcodebuild (scripts/build.sh)
   ├─ 编译 Swift + C
   └─ 生成 .app bundle
   │
   ▼
安装
   │
   ├─ 复制到 /Library/Input Methods/
   ├─ 设置权限
   └─ 系统设置中添加输入法
   │
   ▼
运行时
   │
   ├─ 系统启动时加载
   ├─ 响应用户输入
   └─ 提供候选词
```

## 未来扩展点

```
┌─────────────────┐
│  当前架构       │
└────────┬────────┘
         │
         ├─► 词库模块
         │    - 本地词库
         │    - 云同步
         │    - 用户词库
         │
         ├─► 配置系统
         │    - Preferences UI
         │    - 快捷键管理
         │    - 主题系统
         │
         ├─► 智能功能
         │    - 联想输入
         │    - 学习功能
         │    - 云拼音
         │
         └─► 多语言支持
              - 繁体中文
              - 其他语言
```

---

**图例说明：**
- `▲ ▼`: 数据流向
- `├─ └─`: 层次结构
- `◄─`: 依赖关系
- `[当前]`: 已实现
- `[未来]`: 待实现
