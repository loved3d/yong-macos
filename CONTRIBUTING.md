# 贡献指南 / Contributing Guide

感谢你对 yong-macos 项目的关注！我们欢迎各种形式的贡献。

## 如何贡献

### 报告问题 (Bug Reports)

如果你发现了 bug，请：

1. 在 [Issues](https://github.com/loved3d/yong-macos/issues) 中搜索是否已有相同问题
2. 如果没有，创建新 Issue，包含以下信息：
   - 问题描述
   - 重现步骤
   - 期望行为
   - 实际行为
   - macOS 版本
   - yong-macos 版本
   - 相关截图或日志

### 功能建议 (Feature Requests)

如果你有新功能建议：

1. 检查 [TODO.md](TODO.md) 查看是否已在计划中
2. 在 Issues 中创建 Feature Request
3. 详细描述：
   - 功能需求
   - 使用场景
   - 预期效果
   - 可能的实现方案

### 提交代码 (Pull Requests)

#### 开发流程

1. **Fork 项目**
   ```bash
   # 在 GitHub 上 fork 项目
   git clone https://github.com/YOUR_USERNAME/yong-macos.git
   cd yong-macos
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **开发和测试**
   - 编写代码
   - 添加测试（如适用）
   - 确保所有测试通过
   - 遵循代码规范

4. **提交更改**
   ```bash
   git add .
   git commit -m "描述你的更改"
   ```

5. **推送分支**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 填写 PR 模板
   - 等待 code review

#### Commit 规范

使用清晰的 commit message：

```
类型(范围): 简短描述

详细说明（可选）

相关 Issue（可选）
```

**类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例：**
```
feat(engine): 添加五笔输入支持

- 实现五笔编码解析
- 添加五笔候选词生成
- 更新文档

Closes #123
```

#### 代码规范

**Swift 代码**
- 使用 4 空格缩进
- 遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- 类和结构体使用大写驼峰命名
- 函数和变量使用小写驼峰命名
- 添加必要的注释

**C 代码**
- 使用 4 空格缩进
- 遵循 K&R 风格
- 函数名使用下划线分隔
- 添加函数头注释

**示例：**

```swift
// Swift
class YongInputController: IMKInputController {
    private var composingBuffer: String = ""
    
    /// 处理键盘事件
    /// - Parameters:
    ///   - event: 键盘事件
    ///   - sender: 客户端对象
    /// - Returns: 事件是否被处理
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        // 实现
    }
}
```

```c
// C
/**
 * 获取候选词
 * 
 * @param input 输入字符串
 * @param candidates 候选词数组
 * @param max_count 最大候选词数量
 * @return 实际返回的候选词数量
 */
int yong_engine_get_candidates(const char *input, char **candidates, int max_count) {
    // 实现
}
```

## 开发环境设置

### 必需软件

- macOS 11.0+
- Xcode 14.0+
- Git

### 构建项目

```bash
# 克隆仓库
git clone https://github.com/loved3d/yong-macos.git
cd yong-macos

# 打开 Xcode 项目
open yong-macos.xcodeproj

# 或使用脚本构建
./scripts/build.sh
```

### 运行测试

```bash
# 在 Xcode 中
# Product > Test (⌘U)

# 或使用命令行
xcodebuild test -project yong-macos.xcodeproj -scheme yong-macos
```

## 项目结构

```
yong-macos/
├── yong-macos/
│   ├── Sources/         # Swift 源代码
│   ├── Engine/          # C 引擎代码
│   └── Resources/       # 资源文件
├── scripts/             # 构建和安装脚本
├── DESIGN.md            # 设计文档
├── INTEGRATION_GUIDE.md # 引擎集成指南
└── TODO.md              # 任务清单
```

## 需要帮助的领域

我们特别欢迎以下方面的贡献：

### 高优先级
- [ ] yong 引擎集成
- [ ] 性能优化
- [ ] 测试覆盖
- [ ] 文档完善

### 欢迎贡献
- [ ] 词库扩展
- [ ] UI/UX 改进
- [ ] 多语言支持
- [ ] Bug 修复

## Code Review 流程

1. 提交 PR 后，维护者会进行 code review
2. 根据反馈修改代码
3. 所有讨论解决后，PR 会被合并
4. 感谢你的贡献！

## 行为准则

- 尊重所有贡献者
- 欢迎建设性的讨论
- 保持友好和专业
- 帮助新手入门

## 许可证

贡献的代码将采用与项目相同的许可证。

## 联系方式

- GitHub Issues: [yong-macos/issues](https://github.com/loved3d/yong-macos/issues)
- 邮件: （待添加）

## 鸣谢

感谢所有贡献者的付出！

特别感谢：
- [@qwertyyb](https://github.com/qwertyyb) - Fire 项目
- [@dgod](https://github.com/dgod) - yong 输入法引擎

---

再次感谢你的贡献！让我们一起打造优秀的 macOS 中文输入法！
