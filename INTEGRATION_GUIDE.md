# yong 引擎集成指南

本文档详细说明如何将真实的 yong 输入法引擎集成到 yong-macos 项目中。

## 前提条件

- 熟悉 C/C++ 编程
- 了解 macOS 开发和 Xcode
- 掌握 Swift/Objective-C 混合编程

## 集成步骤

### 1. 获取 yong 源代码

```bash
# 克隆 yong 仓库
git clone https://github.com/dgod/yong.git
cd yong

# 查看源代码结构
ls -la
```

### 2. 分析 yong 引擎 API

需要了解的关键部分：

**核心头文件**
```c
// 可能的 API 函数（根据实际源代码确定）
int y_im_init(const char *config_path);
int y_im_process_key(int keyval, int keycode, int state);
char **y_im_get_candidates(const char *input, int *count);
void y_im_cleanup(void);
```

**任务清单：**
- [ ] 找到 yong 的主头文件
- [ ] 识别初始化函数
- [ ] 识别输入处理函数
- [ ] 识别候选词获取函数
- [ ] 识别清理函数

### 3. 编译 yong 为静态库

#### 3.1 分析 yong 构建系统

```bash
# 查看构建配置
cat Makefile  # 或 CMakeLists.txt
```

#### 3.2 修改构建配置（如需要）

创建 macOS 特定的构建配置：

```makefile
# Makefile.macos
CC = clang
CFLAGS = -arch x86_64 -arch arm64 -mmacosx-version-min=11.0
LDFLAGS = -framework Foundation

# 编译为静态库
libyong.a: $(OBJS)
	ar rcs $@ $^
```

#### 3.3 构建静态库

```bash
# 编译 yong 源代码
make -f Makefile.macos

# 验证生成的库
file libyong.a
# 应该显示: libyong.a: Mach-O universal binary with 2 architectures
```

### 4. 集成 yong 库到 Xcode 项目

#### 4.1 复制库文件和头文件

```bash
# 在 yong-macos 项目中创建 vendor 目录
cd /path/to/yong-macos
mkdir -p vendor/yong/{lib,include}

# 复制编译好的库
cp /path/to/yong/libyong.a vendor/yong/lib/

# 复制头文件
cp /path/to/yong/*.h vendor/yong/include/
```

#### 4.2 更新 Xcode 项目配置

在 Xcode 中：

1. **添加 Library Search Paths**
   - 选择项目 > Build Settings
   - 搜索 "Library Search Paths"
   - 添加：`$(PROJECT_DIR)/vendor/yong/lib`

2. **添加 Header Search Paths**
   - 搜索 "Header Search Paths"
   - 添加：`$(PROJECT_DIR)/vendor/yong/include`

3. **链接库文件**
   - 选择项目 > Build Phases
   - 展开 "Link Binary With Libraries"
   - 点击 "+" 添加 `libyong.a`

4. **更新 Other Linker Flags**
   - 添加必要的链接选项，如：`-lyong`

### 5. 修改 yong_engine.c 调用真实 API

#### 5.1 包含 yong 头文件

```c
// yong_engine.c
#include "yong_engine.h"
#include "yong.h"  // yong 主头文件（根据实际情况）
```

#### 5.2 实现初始化函数

```c
int yong_engine_init(void) {
    if (engine_initialized) {
        return 0;
    }
    
    // 调用 yong 初始化
    // 根据 yong 实际 API 调整
    int ret = y_im_init("/path/to/yong/config");
    if (ret != 0) {
        return -1;
    }
    
    engine_initialized = 1;
    return 0;
}
```

#### 5.3 实现候选词获取

```c
int yong_engine_get_candidates(const char *input, char **candidates, int max_count) {
    if (!engine_initialized || input == NULL) {
        return 0;
    }
    
    // 调用 yong API 获取候选词
    int count = 0;
    char **yong_candidates = y_im_get_candidates(input, &count);
    
    if (yong_candidates == NULL) {
        return 0;
    }
    
    // 复制结果到输出数组
    int result_count = (count < max_count) ? count : max_count;
    for (int i = 0; i < result_count; i++) {
        candidates[i] = strdup(yong_candidates[i]);
    }
    
    // 释放 yong 返回的内存（如需要）
    // y_im_free_candidates(yong_candidates, count);
    
    return result_count;
}
```

#### 5.4 实现清理函数

```c
void yong_engine_cleanup(void) {
    if (!engine_initialized) {
        return;
    }
    
    // 调用 yong 清理
    y_im_cleanup();
    
    engine_initialized = 0;
}
```

### 6. 配置资源文件

#### 6.1 复制 yong 词库和配置

```bash
# 创建资源目录
mkdir -p yong-macos/Resources/yong

# 复制词库文件
cp -r /path/to/yong/mb yong-macos/Resources/yong/

# 复制配置文件
cp /path/to/yong/yong.ini yong-macos/Resources/yong/
```

#### 6.2 在 Xcode 中添加资源

1. 在 Xcode 中将 `Resources/yong` 目录添加到项目
2. 确保这些文件在 "Copy Bundle Resources" 中

#### 6.3 在代码中获取资源路径

```swift
// YongInputController.swift
static func getYongResourcePath() -> String? {
    guard let resourcePath = Bundle.main.resourcePath else {
        return nil
    }
    return resourcePath + "/yong"
}
```

```c
// yong_engine.c
static const char *get_resource_path(void) {
    // 从 Swift 传递资源路径
    // 或者使用 CoreFoundation 获取 Bundle 路径
    CFBundleRef bundle = CFBundleGetMainBundle();
    CFURLRef resourceURL = CFBundleCopyResourcesDirectoryURL(bundle);
    // ... 转换为 C 字符串
}
```

### 7. 测试集成

#### 7.1 编写测试代码

```c
// test_yong_engine.c
#include "yong_engine.h"
#include <stdio.h>

int main() {
    printf("Testing yong engine integration...\n");
    
    // 初始化
    if (yong_engine_init() != 0) {
        printf("Failed to initialize engine\n");
        return 1;
    }
    printf("Engine initialized successfully\n");
    
    // 测试获取候选词
    char *candidates[MAX_CANDIDATES];
    int count = yong_engine_get_candidates("ni", candidates, MAX_CANDIDATES);
    
    printf("Found %d candidates for 'ni':\n", count);
    for (int i = 0; i < count; i++) {
        printf("  %d: %s\n", i + 1, candidates[i]);
    }
    
    // 释放候选词
    yong_engine_free_candidates(candidates, count);
    
    // 清理
    yong_engine_cleanup();
    printf("Engine cleanup completed\n");
    
    return 0;
}
```

#### 7.2 编译和运行测试

```bash
# 编译测试程序
clang test_yong_engine.c yong_engine.c -I vendor/yong/include \
    -L vendor/yong/lib -lyong -o test_engine

# 运行测试
./test_engine
```

### 8. 调试和优化

#### 8.1 启用调试日志

在 `yong_engine.c` 中添加日志：

```c
#ifdef DEBUG
#define LOG_DEBUG(fmt, ...) \
    fprintf(stderr, "[yong_engine] " fmt "\n", ##__VA_ARGS__)
#else
#define LOG_DEBUG(fmt, ...)
#endif

int yong_engine_init(void) {
    LOG_DEBUG("Initializing engine...");
    // ...
}
```

#### 8.2 内存泄漏检测

```bash
# 使用 Instruments 检测内存泄漏
# 在 Xcode 中：Product > Profile > Leaks
```

#### 8.3 性能分析

```bash
# 使用 Time Profiler
# 在 Xcode 中：Product > Profile > Time Profiler
```

### 9. 常见问题和解决方案

#### Q1: 编译错误：找不到 yong 头文件
```
Solution:
1. 检查 Header Search Paths 设置
2. 确认头文件已正确复制
3. 在 .h 文件中使用正确的 #include 路径
```

#### Q2: 链接错误：undefined symbols
```
Solution:
1. 检查 Library Search Paths
2. 确认 libyong.a 已添加到项目
3. 检查符号是否使用 extern "C" 声明
```

#### Q3: 运行时找不到资源文件
```
Solution:
1. 检查资源文件是否在 Bundle 中
2. 使用 Bundle.main.resourcePath 获取正确路径
3. 验证文件权限
```

#### Q4: 候选词显示乱码
```
Solution:
1. 检查字符编码（应该使用 UTF-8）
2. 确认 yong 引擎输出编码
3. 在 Swift 中正确转换 C 字符串
```

## 验证清单

完成集成后，验证以下功能：

- [ ] 引擎成功初始化
- [ ] 可以获取拼音候选词
- [ ] 候选词显示正确的中文字符
- [ ] 可以正常选择候选词
- [ ] 内存管理正确（无泄漏）
- [ ] 性能满足要求（响应时间 < 100ms）
- [ ] 支持五笔输入（如果 yong 支持）
- [ ] 自定义词库可用

## 下一步

完成基本集成后，可以：

1. **优化性能**
   - 实现候选词缓存
   - 使用异步查询
   - 预加载常用词库

2. **增强功能**
   - 支持云词库同步
   - 添加用户词学习
   - 实现模糊音设置

3. **改善用户体验**
   - 自定义候选词窗口样式
   - 添加配置界面
   - 实现状态栏菜单

## 参考资源

- [yong 输入法官网](https://github.com/dgod/yong)
- [Apple InputMethodKit 文档](https://developer.apple.com/documentation/inputmethodkit)
- [Fire 项目参考](https://github.com/qwertyyb/Fire)

## 获取帮助

如遇到问题：

1. 查看 yong 项目文档和源代码
2. 在 GitHub Issues 中搜索类似问题
3. 提交新的 Issue 描述问题
4. 参考 DESIGN.md 中的架构说明
