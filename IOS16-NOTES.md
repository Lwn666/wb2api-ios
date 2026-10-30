# iOS 16 适配说明（基于上游 f29f9a6，部署目标 26.0 → 16.0）

本分支只降部署目标、不改功能逻辑（网络、模型、任务执行、Keychain 均未动）。
沙箱是 Linux、无 Xcode，无法跑 `xcodebuild`，以下改动均为静态源码适配，
请在 Mac 上跑一次 `xcodegen generate` + `xcodebuild test` 做最终验证，首个编译报错请直接发回修。

## 构建（Mac）
```
brew install xcodegen
xcodegen generate
open WB2API.xcodeproj   # 或 xcodebuild test -project WB2API.xcodeproj -scheme WB2API -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```
要求：Xcode 16+（Swift 6），真机/模拟器 iOS 16+ 即可安装，不再要求 iOS 26 SDK。

## 核心改动：Observation → ObservableObject（iOS 17+ → iOS 16）
- 8 个 `@Observable` 类全部改为 `ObservableObject` + `@Published`：
  `Loader`、`SessionStore`、`AccountDetailModel`、`AccountsModel`、`ConfigEditor`、
  `ModelSpeedRunner`、`OverviewModel`、`TaskRunController`；删 `import Observation`。
- 嵌套 Loader 转发：`AccountsModel` / `AccountDetailModel` / `OverviewModel` 内部的
  `Loader` 变化用 Combine `objectWillChange.sink` 手动转发，否则父对象变化时页面不刷新。
  （@Observable 时嵌套追踪是自动的，ObservableObject 下不是，这是最容易漏的坑。）
- 调用点：`@State` → `@StateObject`（22 处，值类型数组除外）；
  `@Environment(SessionStore.self)` → `@EnvironmentObject`；
  `.environment(...)` → `.environmentObject(...)`；
  `@Bindable` 4 处删除（ObservableObject 的 `$model.xxx` / `$session.xxx` 本来就可绑定）；
  纯参数 `let model: AccountsModel` / `let editor: ConfigEditor`（3 处）改为 `@ObservedObject`，
  否则子视图收不到刷新。

## 其他 iOS 17+/18/26 API 平替
- 部署目标：`project.yml` iOS 26.0 → 16.0；README / CI 文案同步，CI 不再写“需要 iOS 26 SDK”。
- Tab：iOS 18 的 `Tab("…", systemImage:, value:)` + `.tabBarMinimizeBehavior` 删掉，
  改回 iOS 16 的 `TabView + .tabItem + .tag`（`MainTabsView.swift`）。
- Liquid Glass（iOS 26）：`glassCard` / `glassInteractive` 统一入口改为
  `.ultraThinMaterial + 细边框`；直接 `.glassEffect` 的 8 处改为 Material 或 tint 底色；
  `.glass` → `.bordered`、`.glassProminent` → `.borderedProminent`（24 处）。
  外观会变（无玻璃折射），布局、圆角、tint 语义保留。
- 空态：`ContentUnavailableView`（iOS 17+）全部改名 `EmptyStateView`，
  新文件 `WB2API/Components/EmptyStateView.swift`，覆盖仓库实际用到的 3 种写法：
  构造器 `{ Label } description: { Text } [actions:]`、`("标题", systemImage:, description:)`、
  `.search` / `.search(text:)`。
- 删掉的纯视觉动效（功能不受影响）：`.symbolEffect`（10 处）、`.sensoryFeedback`（3 处，震动没了）、
  `.contentTransition(.numericText())`（21 处）、`.scrollTransition`（2 处）。
- `.onChange` 两参 `{ _, new in }`（17 处）改为 iOS 16 单参 `{ new in }` / `{ _ in }`。
- 动画：`.snappy` / `.bouncy` / `.smooth`（iOS 17+）改为 `.spring` / `easeInOut`，
  `Motion.swift` 的 `spring/emphasized/numeric` 已同步改写。
- 形状字面量：`.rect(cornerRadius:)` → `RoundedRectangle(cornerRadius:)`，
  `in: .capsule` → `in: Capsule()`；`.background(.background)` → `Color(.systemBackground)`。

## 刻意没动的东西（iOS 16 本来就有）
- `NavigationStack` / `navigationDestination`、`ShareLink`、`Charts`（折线/柱状图）、
  `TextField(axis:)`、`.searchable`、`.scrollContentBackground`、`.scrollIndicators`、
  `Task.sleep(for:)`、`URLSession.bytes`、`.fontDesign` 均是 iOS 16 可用，保留原样。
- Swift 版本仍是 6.0，`#Preview`、并发模型、测试夹具均未动。

## 已知限制（请在 Mac 上验证）
1. 未经 `xcodebuild` 编译验证：沙箱无 Xcode/Swift 工具链，只能做 grep + 括号平衡静态检查。
   风险最高的三处已在上面标出：EmptyStateView 泛型构造器、Loader 转发的 Combine、
   `@ObservedObject` 参数视图的合成初始化。
2. iOS 16 真机上 SF Symbol 个别新图标（如 gauge 类）可能显示为占位，属系统图标版本问题，
   不影响编译与功能；如遇缺失可换成 iOS 16 已有图标。
3. 视觉降级是故意的：iOS 16 没有 Liquid Glass，卡片就是 Material + 细边框，不是“没适配好”。
