# yong-macos 快速参考

## 项目快速开始

### 克隆和构建
```bash
git clone https://github.com/loved3d/yong-macos.git
cd yong-macos
open yong-macos.xcodeproj
# 在 Xcode 中按 ⌘B 构建
```

### 使用脚本
```bash
# 构建
./scripts/build.sh

# 安装（需要 sudo）
sudo ./scripts/install.sh

# 卸载
sudo ./scripts/uninstall.sh
```

## 核心文件

| 文件 | 说明 |
|------|------|
| `README.md` | 项目概述和使用说明 |
| `DESIGN.md` | 架构设计文档 |
| `INTEGRATION_GUIDE.md` | yong 引擎集成指南 |
| `CONTRIBUTING.md` | 贡献指南 |
| `TODO.md` | 待办事项列表 |

## 源代码结构

```
yong-macos/
├── Sources/
│   ├── YongAppDelegate.swift          # 应用入口
│   ├── YongInputController.swift      # IMK 控制器
│   └── yong-macos-Bridging-Header.h  # C/Swift 桥接
├── Engine/
│   ├── yong_engine.h                  # C 引擎接口
│   └── yong_engine.c                  # C 引擎实现
└── Resources/
    ├── Info.plist                     # 应用配置
    └── MainMenu.xib                   # 菜单界面
```

## 关键类和函数

### Swift 层

**YongAppDelegate**
```swift
class YongAppDelegate: NSObject, NSApplicationDelegate
- applicationDidFinishLaunching()  // 初始化 IMKServer
```

**YongInputController**
```swift
class YongInputController: IMKInputController
- handle(_:client:)          // 处理键盘事件
- candidates(_:)             // 返回候选词
- getCandidates(for:)        // 调用引擎获取候选词
```

### C 层

**yong_engine.h/c**
```c
int yong_engine_init(void);
int yong_engine_get_candidates(const char *input, char **candidates, int max_count);
void yong_engine_free_candidates(char **candidates, int count);
void yong_engine_cleanup(void);
```

## 当前功能

✅ **已实现**
- IMK 框架集成
- 基本键盘事件处理
- 候选词窗口显示
- Mock 拼音引擎（40+ 词条）
- 数字键选词
- 基本编辑功能（退格、ESC、回车）

⏳ **待实现**
- 集成真实 yong 引擎
- 五笔输入支持
- 用户词库管理
- 配置界面
- 更多输入法特性

## Mock 引擎支持的拼音

当前 mock 引擎支持以下拼音：

**问候语**: ni, hao, nihao, xiexie, zaijian, duibuqi, meiguanxi

**常用词**: wo, shi, de, ta, men, zhe, ge, ma, you

**数字**: yi, er, san, si, wu, liu, qi, ba, jiu

**动词**: zuo, lai, qu, shuo, kan, ting, zou, pao, chi, he

## 开发工作流

1. **分支策略**
   - `main`: 稳定版本
   - `develop`: 开发分支
   - `feature/*`: 功能分支
   - `fix/*`: 修复分支

2. **提交代码**
   ```bash
   git checkout -b feature/your-feature
   # 编写代码
   git commit -m "feat: 描述"
   git push origin feature/your-feature
   # 创建 Pull Request
   ```

3. **代码规范**
   - Swift: 4 空格，驼峰命名
   - C: 4 空格，下划线命名
   - 添加必要注释

## 测试和调试

### 查看日志
```bash
log stream --predicate 'process == "yong-macos"' --level debug
```

### 重启输入法
```bash
pkill -9 "yong-macos"
# 然后切换输入法
```

### 在 Xcode 中调试
1. Build (⌘B)
2. Product > Run (⌘R)
3. 设置断点调试

## 常用命令

```bash
# 查找输入法进程
ps aux | grep yong-macos

# 检查安装位置
ls -la "/Library/Input Methods/"

# 查看系统输入法列表
defaults read com.apple.HIToolbox AppleEnabledInputSources
```

## 性能指标

| 指标 | 目标值 |
|------|--------|
| 响应时间 | < 100ms |
| 内存占用 | < 50MB |
| CPU 使用率 | < 5% |
| 启动时间 | < 2s |

## 下一步计划

1. **Phase 2**: 集成 yong 引擎
2. **Phase 3**: 功能增强
3. **Phase 4**: 用户体验优化
4. **Phase 5**: 发布 v1.0

详见 [TODO.md](TODO.md)

## 获取帮助

- 📖 阅读文档：DESIGN.md, INTEGRATION_GUIDE.md
- 🐛 报告问题：GitHub Issues
- 💬 参与讨论：GitHub Discussions
- 📧 联系我们：（待添加）

## 相关链接

- [Fire 项目](https://github.com/qwertyyb/Fire)
- [yong 输入法](https://github.com/dgod/yong)
- [Apple IMK 文档](https://developer.apple.com/documentation/inputmethodkit)

---

最后更新：2025-12-19
版本：v0.1.0-alpha
