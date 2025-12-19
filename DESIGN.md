# yong-macos 设计文档

## 项目目标

将 @qwertyyb/Fire 的 IMK 接口实现与 @dgod/yong 的核心引擎结合，快速实现 yong macOS 输入法。

## 架构设计

### 三层架构

```
┌─────────────────────────────────────┐
│     macOS InputMethodKit (IMK)      │
│         系统框架层                    │
└─────────────────────────────────────┘
                 ▲
                 │ IMK APIs
                 ▼
┌─────────────────────────────────────┐
│      Swift IMK 接口实现层            │
│  - YongAppDelegate                  │
│  - YongInputController              │
│  - 事件处理和候选词显示               │
└─────────────────────────────────────┘
                 ▲
                 │ C/Swift Bridge
                 ▼
┌─────────────────────────────────────┐
│       C 引擎接口层                   │
│  - yong_engine.h/.c                 │
│  - 拼音/五笔编码转换                  │
│  - 候选词生成                        │
└─────────────────────────────────────┘
                 ▲
                 │ Engine API
                 ▼
┌─────────────────────────────────────┐
│      yong 核心引擎                   │
│  - 输入法核心逻辑                     │
│  - 词库管理                          │
│  - 智能预测                          │
└─────────────────────────────────────┘
```

### 组件说明

#### 1. Swift IMK 接口实现层

**YongAppDelegate.swift**
- 应用程序入口
- 初始化 IMKServer
- 管理输入法生命周期

**YongInputController.swift**
- 继承 IMKInputController
- 处理键盘事件
- 管理候选词窗口
- 调用引擎接口

**核心方法：**
```swift
func handle(_ event: NSEvent!, client sender: Any!) -> Bool
- 处理所有键盘输入事件
- 返回 true 表示事件已处理

func candidates(_ sender: Any!) -> [Any]!
- 返回当前候选词列表

func updateComposition()
- 更新输入组合状态
- 调用引擎获取候选词
```

#### 2. C 引擎接口层

**yong_engine.h**
```c
// 初始化引擎
int yong_engine_init(void);

// 获取候选词
int yong_engine_get_candidates(
    const char *input,      // 输入的拼音或编码
    char **candidates,      // 输出候选词数组
    int max_count          // 最大候选词数量
);

// 清理资源
void yong_engine_cleanup(void);
```

**设计原则：**
- 提供简洁的 C 接口
- 支持 Swift 通过 Bridging Header 调用
- 内部可调用 yong 引擎的 C/C++ API

#### 3. yong 核心引擎集成

**当前状态：**
- 使用 mock 实现提供基础功能
- 预定义了常用拼音词组

**完整集成步骤：**
1. 下载 yong 源代码
2. 编译 yong 核心库为静态库
3. 在 yong_engine.c 中调用 yong API
4. 链接 yong 库到 Xcode 项目

## 技术实现细节

### IMK 事件处理流程

```
用户按键
   ↓
系统捕获事件
   ↓
IMK 框架转发给 YongInputController
   ↓
handle(_:client:) 方法处理
   ↓
判断键位类型：
   - 字母/数字 → 添加到输入缓冲区
   - 退格键 → 删除最后一个字符
   - 空格键 → 选择首选候选词
   - 数字键 → 选择对应候选词
   - ESC → 取消输入
   - 回车 → 提交当前输入
   ↓
调用 getCandidates() 获取候选词
   ↓
通过 C 接口调用 yong 引擎
   ↓
更新候选词窗口显示
   ↓
等待下一个事件
```

### C/Swift 桥接机制

**Bridging Header**
```objc
#import "yong_engine.h"
```

**Swift 调用示例**
```swift
private func getCandidates(for input: String) -> [String] {
    var candidatePointers = [UnsafeMutablePointer<CChar>?](
        repeating: nil, 
        count: Int(MAX_CANDIDATES)
    )
    
    let count = input.withCString { inputPtr in
        candidatePointers.withUnsafeMutableBufferPointer { buffer in
            yong_engine_get_candidates(inputPtr, buffer.baseAddress, Int32(MAX_CANDIDATES))
        }
    }
    
    var results: [String] = []
    for i in 0..<Int(count) {
        if let ptr = candidatePointers[i] {
            results.append(String(cString: ptr))
        }
    }
    
    return results
}
```

### Info.plist 配置

关键配置项：
```xml
<key>LSUIElement</key>
<true/>  <!-- 隐藏 Dock 图标 -->

<key>InputMethodConnectionName</key>
<string>Yong_Connection</string>

<key>InputMethodServerControllerClass</key>
<string>$(PRODUCT_MODULE_NAME).YongInputController</string>

<key>tsInputMethodCharacterRepertoireKey</key>
<array>
    <string>Hans</string>  <!-- 简体中文 -->
    <string>Hant</string>  <!-- 繁体中文 -->
</array>
```

## 开发路线图

### Phase 1: 基础框架 ✅
- [x] 创建 Xcode 项目结构
- [x] 实现 IMK 接口层
- [x] 创建 C 引擎接口
- [x] Mock 拼音引擎实现
- [x] 基本输入功能
- [x] 候选词显示

### Phase 2: yong 引擎集成 ⏳
- [ ] 集成 yong 源代码
- [ ] 适配 yong API 到接口层
- [ ] 支持拼音输入
- [ ] 支持五笔输入
- [ ] 词库加载和管理

### Phase 3: 功能增强 ⏳
- [ ] 用户自定义词库
- [ ] 输入历史记录
- [ ] 智能预测和联想
- [ ] 中英文混合输入
- [ ] 符号输入面板

### Phase 4: 用户体验 ⏳
- [ ] 配置界面
- [ ] 皮肤主题支持
- [ ] 快捷键设置
- [ ] 候选词窗口美化
- [ ] 状态栏菜单

### Phase 5: 优化和发布 ⏳
- [ ] 性能优化
- [ ] 内存优化
- [ ] 代码签名
- [ ] 自动更新
- [ ] 发布到 GitHub Releases

## 参考资料

### Fire 项目学习要点
1. **IMKInputController 的使用**
   - 事件处理机制
   - 候选词管理
   - 输入状态维护

2. **候选词窗口**
   - IMKCandidates 的创建和显示
   - 自定义候选词样式

3. **应用生命周期**
   - 输入法的启动和退出
   - 多客户端管理

### yong 引擎学习要点
1. **核心 API**
   - 初始化和配置
   - 输入处理
   - 候选词生成

2. **词库格式**
   - 拼音词库结构
   - 五笔编码表
   - 用户词库

3. **性能优化**
   - 快速查询算法
   - 缓存机制
   - 内存管理

## 代码规范

### Swift 代码
- 使用 Swift 5.0+
- 遵循 Swift API 设计指南
- 使用 Swift 命名约定

### C 代码
- 使用 C11 标准
- 遵循 Linux 内核代码风格
- 清晰的函数和变量命名

### 注释
- 公共接口必须有文档注释
- 复杂逻辑需要解释性注释
- 使用中文或英文，保持一致

## 调试技巧

### 查看输入法日志
```bash
log stream --predicate 'process == "yong-macos"' --level debug
```

### 重启输入法
```bash
# 杀死当前运行的输入法
pkill -9 "yong-macos"

# 切换到其他输入法再切回来
```

### 清理缓存
```bash
# 清理输入法缓存
rm -rf ~/Library/Caches/com.yong.yong-macos
```

## 常见问题

### Q: 输入法不显示在输入源列表中？
A: 确保：
1. Info.plist 配置正确
2. 安装位置为 `/Library/Input Methods/`
3. 重启系统或注销后重新登录

### Q: 无法输入中文？
A: 检查：
1. 引擎是否正确初始化
2. getCandidates 是否返回结果
3. 查看系统日志排查错误

### Q: 如何更新拼音词库？
A: 当前使用 mock 实现，集成真实 yong 引擎后，可通过 yong 的词库管理功能更新。

## 贡献指南

欢迎贡献代码！请遵循：
1. Fork 项目
2. 创建功能分支
3. 提交有意义的 commit
4. 创建 Pull Request
5. 等待 code review

## 许可证

本项目使用开源许可证。具体许可条款待定，需考虑：
- yong 引擎的许可证
- Fire 项目的许可证
- 自有代码的许可证选择
