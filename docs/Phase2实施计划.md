# Phase 2 实施计划 — UI 骨架阶段

> 本文档是 Phase 2（UI 骨架）的工作说明书。每个任务完成后用 `dart analyze` 验证再进下一个。

---

## 0. 背景

Phase 0（Domain）+ Phase 1（PTP/IP 协议层）已完成。Phase 2 搭 UI 骨架，Phase 3 真机验证 + 下载。

**为什么 Phase 2 先做 UI 骨架**：UI 骨架一次写好，Phase 3/4 只填肉，不做重复功。

---

## 1. 总体目标

| 交付 | 说明 |
|---|---|
| Riverpod Provider 拓扑 | 6 个 Provider 全链路打通，注入 fake 可单测 |
| 4 个 Tab 页面 | 连接 / 相册 / 下载 / 设置 — 占位 UI |
| Shared 包 | 主题 + 主按钮 + 卡片 + 空状态 + 占位 logger |
| pubspec | 加 `shared_preferences` + `google_fonts` + `package:logging` |
| lint | `analysis_options.yaml` 加强 |
| 测试 | 21 Notifier 单测 + 8 widget smoke = 29 新增（**覆盖率不要求 ≥ 80%（协议层目标，AGENTS.md §6.1）**，但每条 Notifier 必须有 happy + error 测试；widget smoke 必须断言关键 UI 元素存在；`dart analyze` 零警告 + `flutter test` 全绿是 commit 前最低门槛） |
| DI 装配 | `main.dart` → `app.dart` → ProviderScope → 各 Page |

---

## 2. 主题决策 — 暖阳琥珀 (Amber)

源自原 iOS `NikonConnectIOS` 的 Claude-style 设计，HTML 原型第一套。

### 2.1 色板

对标原 iOS `AppTheme` 18 个色 token + workflow 状态色函数。

#### 2.1.1 18 个色 token

| Token | Hex | 用途 |
|---|---|---|
| `--bg` | `#F9F9F8` | 全局背景暖白（原 iOS `canvas`） |
| `--card` | `#FFFFFF` | 卡片底色（原 iOS `surface`） |
| `--surface-elevated` | `#FFFFFF` | 浮层底色（Dialog / BottomSheet） |
| `--surface-muted` | `#F5F5F5` | 次级面板 / MetricTile 底（原 iOS `surfaceMuted`） |
| `--control-bg` | `#F2F2F3` | 输入框 / 控件底（原 iOS `controlBackground`） |
| `--bdr` | `rgba(0,0,0,0.07)` | 卡片/列表边框（原 iOS `border`） |
| `--div` | `rgba(0,0,0,0.04)` | 列表项分隔（原 iOS `subtleFill`） |
| `--sep` | `rgba(0,0,0,0.08)` | TabBar 阴影 / 工具栏分隔（原 iOS `separator`） |
| `--shadow` | `rgba(0,0,0,0.05)` | 卡片阴影（原 iOS `shadow`） |
| `--t1` | `#1A1A1A` | 主文字（近黑，原 iOS `ink`） |
| `--t2` | `#6B7079` | 次要文字（原 iOS `inkMuted`） |
| `--tm` | `#B5AFA6` | 时间戳/辅助文字 |
| `--a` | `#D4A24E` | 强调色琥珀金（原 iOS `accent`） |
| `--a-s` | `#E8B84B` | 强调色浓（原 iOS `accentStrong`） |
| `--a-l` | `#F5E6C8` | 强调色浅底（原 iOS `accentSoft`） |
| `--info` | `#4069B3` | 信息蓝（原 iOS `info`） |
| `--ok` | `#5B8C5A` | 成功/完成绿（原 iOS `success`） |
| `--warn` | `#D47507` | 警告橙（原 iOS `warning`） |
| `--er` | `#DB262E` | 错误红（原 iOS `danger`） |
| `--btn` | `#1A1A1A` | 按钮底色（黑） |
| `--btn-t` | `#FFFFFF` | 按钮文字白 |

#### 2.1.2 Workflow 状态色函数

对标原 iOS `AppTheme.workflowColor(for: CameraWorkflowState)`：

```dart
/// CameraWorkflowState → 颜色
/// 原 iOS: waitingForWifi → info / connecting/loadingPhotos/downloading → warning
///        / connected → success / error → danger
Color AppTheme.workflowColor(CameraWorkflowState state) {
  switch (state) {
    case .waitingForWifi:    return AppTheme.info;
    case .connecting:        return AppTheme.warn;
    case .loadingPhotos:     return AppTheme.warn;
    case .downloading:       return AppTheme.warn;
    case .connected:         return AppTheme.ok;
    case .error:             return AppTheme.er;
  }
}
```

**测试覆盖**（写 app_theme.dart 时必加）：6 个 state → 6 色 全测。

### 2.2 字体

**Phase 2 字体决策**：保留 iOS `.system(.rounded)` 风格 + HTML 原型衬线。

| 名 | Dart | 备注 |
|---|---|---|
| 衬线（大标题） | `GoogleFonts.instrumentSerif()` | "Viewfinder"、"相册"、"下载"、"设置" 页面标题（H1 26pt regular） |
| 默认（正文） | `Theme.of(context).textTheme` (系统) | iOS 苹方 / Android 思源；**Flutter 默认 `.rounded` style**（对齐 iOS `.system(.rounded)`） |
| 等宽（标签） | `GoogleFonts.dmMono()` | 端口/大小/格式/时间戳标签 |

> **决策说明**：Phase 2 引入 Instrument Serif 是 HTML 原型给的视觉锚点，但保留 iOS `.rounded` 字体（Flutter 默认无 .rounded 修饰）。Phase 4 视觉抛光时如需统一，可改用衬线作为默认。

#### 2.2.1 Typography scale

对标原 iOS `.title2 / .title3 / .body / .footnote` 等（写 app_theme.dart 时一并实现）：

| 用途 | Flutter textTheme | iOS 对位 | size / weight |
|---|---|---|---|
| 大标题（页面 H1） | `displayLarge` | `.title2` | 22 / bold（Instrument Serif） |
| 中标题（卡片标题） | `titleLarge` | `.headline` | 17 / bold |
| 正文 | `bodyLarge` | `.body` | 17 / regular |
| 辅助文字 | `bodyMedium` | `.subheadline` | 15 / regular |
| 标签 / 注释 | `labelSmall` | `.caption2` | 11 / medium（DM Mono） |
| 数值（MetricTile 大字） | `titleMedium` | `.title3` | 20 / bold |

> 注：原 iOS `.title2` 是 22pt（不是 Phase 2 §2.2.1 之前写的 26pt）；`.body` 是 17pt（不是 15pt）。Phase 4 视觉抛光时可微调。

### 2.3 Spacing & Radius tokens

| Token | 值 | 用途 |
|---|---|---|
| `--space-xs` | 4 | 紧凑 |
| `--space-s` | 8 | 标准 |
| `--space-m` | 12 | 卡片内 |
| `--space-l` | 16 | 卡片间距 |
| `--space-xl` | 24 | Section 间距 |
| `--space-2xl` | 36 | 页面顶部 |
| `--radius-s` | 8 | 小标签 |
| `--radius-m` | 12 | 输入框 |
| `--radius-l` | 18 | 卡片 |
| `--radius-pill` | 100 | 胶囊按钮 |

### 2.4 共享 widget

`features/shared/` 包（含 widget）：

| Widget | 对标原 iOS | 说明 |
|---|---|---|
| `PrimaryActionButton` | 原 `PrimaryActionButton` | 主按钮（黑底白字圆角胶囊 + 图标，可设禁用） |
| `SecondaryActionButton` | 原 `SecondaryActionButton` | 次按钮（白底黑字圆角胶囊，可配前景色） |
| `CustomCard` | 原 `CustomCard` | 卡片容器（白底 + 圆角 18 + 阴影）— 4 个页面 section 容器都用 |
| `SectionHeader` | 原 `SectionHeader(title:)` | section 标题（11px 大写 + 字距 1.5） |
| **`StatusBadge`** | **`StatusBadgeView` 46 行** | 圆点 + 状态 label（占位静态，无 pulsing）— Connection 页状态指示用 |
| **`MetricTile`** | **`AppTheme.swift` MetricTile 21 行** | 图标 + 数值 + 标签（Gallery 已加载/已选择 + Downloads 记录数/已入相册 + Settings 状态指标） |
| **`GridRowItem`** | **`SharedComponents.swift` GridRowItem** | 设置页 Grid 列表项（图标 + label + value + chevron） |
| **`DownloadProgressDetails`** | **`SharedComponents.swift` DownloadProgressDetails** | 下载页 activeDownloadSection 显示当前下载进度 |
| **`Haptics`** | **`SharedComponents.swift` Haptics** | 触觉反馈（Phase 2 占位，Phase 4 才接实际震动） |
| **`ShimmerView`** | **`SharedComponents.swift` ShimmerView** | 缩略图加载占位动画（Phase 2 占位静态，Phase 4 才加动画） |
| **`LensGlowView`** | **`SharedComponents.swift` LensGlowView** | 连接页 hero 镜头呼吸光晕（Phase 2 占位静态圆形 + 边框） |

**`EmptyState` + `ErrorBanner` Phase 2 不做**：
- iOS 没独立 `EmptyStateView` widget；Settings/Downloads 用 inline `VStack/Text/Image` 自渲染空状态
- iOS 没独立 `ErrorBanner` widget；全局 alert 用 `.alert(item: $shell.alertContext)` 系统弹窗
- Phase 2 沿用 inline 渲染，不抽 widget

**命名沿用原 iOS**：保留 `PrimaryActionButton` / `SecondaryActionButton` 命名（不加 Action 后缀就跟 iOS 对不齐）。`StatusBadge` / `MetricTile` / `Haptics` / `ShimmerView` / `LensGlowView` / `GridRowItem` / `DownloadProgressDetails` / `CustomCard` / `SectionHeader` 都跟 iOS 一致。

**widget 文件归属**：
- `app_theme.dart`：`MetricTile`（跟 iOS 同文件模式）+ ColorTokens + Typography + Spacing + Radius + workflowColor()
- `shared_components.dart`：`PrimaryActionButton` / `SecondaryActionButton` / `CustomCard` / `SectionHeader` / `GridRowItem` / `DownloadProgressDetails` / `Haptics` / `ShimmerView` / `LensGlowView`
- `status_badge.dart`：单独的 `StatusBadge` widget（对标 iOS 独立文件 `App/StatusBadgeView.swift` → `Viewfinder方案.md §11.1` 规划 `lib/features/shared/status_badge.dart`）

---

## 3. Provider 拓扑

```
preferencesStoreProvider (Provider<AppPreferencesStore>)
    ├── transportFactoryProvider (Provider<CameraTransportFactory>)
    │       └── connectionProvider (NotifierProvider<ConnectionNotifier, ConnectionState>)
    │               └── galleryProvider (AsyncNotifierProvider<GalleryNotifier, List<PhotoAsset>>)
    │
    └── preferencesProvider (NotifierProvider<PreferencesNotifier, CameraConnectionConfig>)

downloadManagerProvider (NotifierProvider<DownloadManagerNotifier, DownloadQueueState>)
    └── connectionProvider (读 CameraSession 决定能否下载；Phase 2 占位不强依赖)

appShellProvider (NotifierProvider<AppShellNotifier, AppShellState>)
    └── (监听各 Notifier 状态变化，emit 全局 alerts / diagnostics)
```

**设计说明**：
- `downloadManagerProvider` **不依赖** `galleryProvider`：下载队列以"选中的照片"为输入，跟图库列表独立
- Phase 2 中 `downloadManager` 是**占位实现**，只持有空队列；Phase 3 才从 connection session 拉真实下载项
- `preferencesProvider` 复用 `preferencesStoreProvider`，**不依赖** transport chain
- **`appShellProvider` 是跨功能的全局状态**：原 iOS `AppShellViewModel` 49 行管理全局 alerts + diagnostics + activeTask 计数。Phase 2 必须有对应 Provider，否则全局提示无处挂

| Provider | 类型 | 依赖 | 测试注入 |
|---|---|---|---|
| `preferencesStoreProvider` | `Provider` | — | `SharedPreferences.setMockInitialValues` |
| `transportFactoryProvider` | `Provider` | preferencesStore | override `FakeCameraTransportFactory` |
| `connectionProvider` | `NotifierProvider<ConnectionNotifier, ConnectionState>` | preferencesStore + transportFactory | override transport factory（§3.4） |
| `galleryProvider` | `AsyncNotifierProvider<GalleryNotifier, GalleryState>` | connection（Phase 2 占位只读，不 watch connection） | 直接 mock 12 asset 返回 |
| `downloadManagerProvider` | `NotifierProvider` | connection（弱依赖：读 activeSession 决定能否下载；Phase 2 占位不强依赖） | override factory |
| `preferencesProvider` | `NotifierProvider` | preferencesStore | `SharedPreferences` mock |
| `appShellProvider` | `NotifierProvider` | — | 直接构造 AppShellNotifier |

**拓扑决策记录**（与 `架构.md §6.1` 同步）：
- 原 `架构.md §6.1` 把 `downloadManagerProvider` 依赖 `galleryProvider` —— **Phase 2 改为弱依赖 connectionProvider**：下载队列用选中资产，跟图库列表独立
- 此决策需要在执行完 Phase 2 后同步更新 `架构.md §6.1` Provider 拓扑表

**AppShellNotifier 单一类决策**（与 `Viewfinder方案.md §6` 同步）：
- 原 `Viewfinder方案.md §6 / §11.1` 说 AppShellViewModel 是"多个 Provider 组合 (无对应单一 Notifier)"
- Phase 2 改为**单一 Notifier**（appShellProvider），State 用 freezed AppShellState
- 此决策需要在执行完 Phase 2 后同步更新 `Viewfinder方案.md §6` + `§11.1`

#### 3.1 AppShellState 结构（任务 2.6a）

对标原 iOS `AppShellViewModel` 49 行 4 个公开方法 / 3 个状态字段：

```dart
// 文件：lib/features/app_shell/app_shell_state.dart
@freezed
class AppShellState with _$AppShellState {
  const AppShellState._();  // 私有构造，允许内嵌 getter（绕开 freezed 2.5.8 bug）
  
  const factory AppShellState({
    /// 全局日志，FIFO 30 条上限（原 iOS `activityLog`）
    @Default(<LogEntry>[]) List<LogEntry> activityLog,
    /// 当前显示的 alert（null = 无）
    AlertContext? alertContext,
    /// 全局 loading 标题（null = 不显示 overlay）
    String? globalActivityTitle,
  }) = _AppShellState;
  
  bool get isShowingGlobalActivity => globalActivityTitle != null;
}

// 文件：lib/features/app_shell/app_shell_view_model.dart
class AppShellNotifier extends Notifier<AppShellState> {
  // Riverpod 2.x Notifier 默认 main-isolated（@MainActor），不需要显式标注

  @override
  AppShellState build() {
    // 监听其他 Provider 状态变化，emit 全局 alerts（iOS AppShellViewModel 同样靠 shell.appendLog 写入）
    ref.listen(connectionProvider, (prev, next) {
      if (next.workflowState == .error) {
        appendLog('连接错误: ${next.lastSummary}');
      }
    });
    ref.listen(galleryProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) => appendLog('相册错误: $err'),
      );
    });
    return const AppShellState();
  }
  
  void setGlobalActivityTitle(String? title) { state = state.copyWith(globalActivityTitle: title); }
  void showAlert({required String title, required String message}) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = state.copyWith(alertContext: AlertContext(id: id, title: title, message: message));
  }
  void dismissAlert() { state = state.copyWith(alertContext: null); }
  void appendLog(String message) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final entry = LogEntry(id: id, timestamp: DateTime.now(), message: message);
    final newLog = [entry, ...state.activityLog].take(30).toList();
    state = state.copyWith(activityLog: newLog);
  }
  String handleError(Object error) {
    final message = error is CameraAppError ? error.message : error.toString();
    appendLog(message);
    showAlert(title: '出现问题', message: message);
    return message;
  }
}
```

**任务 2.6a 单测覆盖**（4 个）：
1. `setGlobalActivityTitle / dismissAlert / showAlert` 状态切换
2. `appendLog` FIFO 30 条上限
3. `handleError` 接受 `StateError('boom')`（普通 Error）→ 写入 log + 显示 alert
4. `handleError` 接受 `CameraAppError.networkProbeFailed('原因')` → 用 `error.message`（**不**重复拼接 recoverySuggestion，对齐 iOS `userFacingMessage(for:)`）

#### 3.2 ConnectionState 结构（任务 2.4）

对标原 iOS `ConnectionViewModel` 176 行 9 个 `@Published` 字段。**用 freezed 普通 class（不是 sealed），因为有 9 个独立字段而非离散 state**：

```dart
// 文件：lib/features/connection_setup/connection_state.dart
@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    @Default(CameraWorkflowState.waitingForWifi) CameraWorkflowState workflowState,
    CameraSession? activeSession,
    @Default('') String hostInput,
    @Default('') String portInput,
    @Default(CameraTransportMode.experimentalNikon) CameraTransportMode transportMode,
    @Default(true) bool autoExportToPhotoLibrary,
    @Default(true) bool prioritizeJPEGDownloads,
    @Default(false) bool isWorking,
    @Default('先在系统设置里连接 Nikon 相机的 Wi-Fi，然后回到这里开始。') String lastSummary,
  }) = _ConnectionState;
  
  const ConnectionState._();
  
  /// 对齐 iOS `canAttemptConnection: Bool`
  bool get canAttemptConnection => true;
}

// 文件：lib/features/connection_setup/connection_view_model.dart
class ConnectionNotifier extends Notifier<ConnectionState> {
  @override
  ConnectionState build() {
    final prefs = ref.watch(preferencesStoreProvider);
    final config = prefs.loadConnectionConfig();
    return ConnectionState(
      hostInput: config.host,
      portInput: config.port.toString(),
      transportMode: config.transportMode,
      autoExportToPhotoLibrary: config.autoExportToPhotoLibrary,
      prioritizeJPEGDownloads: config.prioritizeJPEGDownloads,
    );
  }
  
  // ... (connect / disconnect / setHost / setPort / setTransportMode / setAutoExport / setPrioritizeJPEG)
}
```

**任务 2.4 测试用例**（5 个，对应原 iOS 9 个字段 + 行为）：
1. `build()` 初始 state：从 `preferencesStoreProvider` 读 `CameraConnectionConfig`，字段映射正确
2. `connect()` 成功：state.workflowState → `.connecting` → `.connected`，activeSession 非 null
3. `connect()` 失败：state.workflowState → `.error`，lastSummary 写入错误消息
4. `disconnect()`：state.workflowState → `.waitingForWifi`，activeSession = null
5. `setHost` / `setPort` / `setTransportMode`：修改字段并持久化到 preferencesStore（fake store 用 mock）

> 注意：`refreshPhotos()` **不**属 ConnectionNotifier。原 iOS `GalleryViewModel.refreshPhotos()`，由 GalleryNotifier 处理。Container 层 (`connection_container.dart`) 在 onConnect 成功后调 `ref.read(galleryProvider.notifier).refresh()`。

#### 3.3 GalleryState 结构（任务 2.5）

原 iOS `GalleryViewModel` 4 个 `@Published`：photoAssets / hasMorePhotos / selectedAssetIDs / isLoading。

**Phase 2 GalleryNotifier state 用 freezed class 包 AsyncValue**（因为 selectedAssetIDs + isLoading 不能塞进 AsyncValue<List<PhotoAsset>>）：

```dart
// 文件：lib/features/photo_browser/gallery_state.dart
@freezed
class GalleryState with _$GalleryState {
  const factory GalleryState({
    @Default(<PhotoAsset>[]) List<PhotoAsset> photoAssets,
    @Default(false) bool hasMorePhotos,
    @Default(<String>{}) Set<String> selectedAssetIDs,  // Phase 2 mock 用 String id
    @Default(false) bool isLoading,
  }) = _GalleryState;
  
  const GalleryState._();
  
  bool get hasSelection => selectedAssetIDs.isNotEmpty;
  int get selectedAssetsCount => selectedAssetIDs.length;
}

// 文件：lib/features/photo_browser/gallery_view_model.dart
class GalleryNotifier extends AsyncNotifier<GalleryState> {
  @override
  Future<GalleryState> build() async {
    // Phase 2 mock 数据：12 张占位 PhotoAsset
    return _mockState();
  }
  
  Future<void> refresh() async { ... }   // 重新生成 mock
  Future<void> loadMore() async { ... }
  void toggleSelection(String id) { ... }
  void selectAll() { ... }
  void clearSelection() { ... }
  
  GalleryState _mockState() => GalleryState(
    photoAssets: List.generate(12, (i) => PhotoAsset(
      id: 'mock-$i',
      remoteIdentifier: '$i',
      fileName: 'DSC_0${i + 100}.NEF',
      kind: i.isEven ? PhotoAssetKind.raw : PhotoAssetKind.jpeg,
      byteSize: 1024 * 1024 * (10 + i),
      captureDate: DateTime.now().subtract(Duration(hours: i)),
      thumbnailInfo: null,
    )),
    hasMorePhotos: false,
  );
}
```

**任务 2.5 测试用例**（5 个）：
1. `build()` 初始 state：返回 12 个 mock assets
2. `refresh()`：state 重置为 mock
3. `loadMore()`：mock 列表超过 12 时返回下一页（Phase 2 mock 不变，测 async 行为）
4. `toggleSelection(id)`：选/取消改 selectedAssetIDs
5. `selectAll()` / `clearSelection()` 边界（命名对齐 iOS：`selectAllAssets()` / `clearSelection()`）

#### 3.4 test mock 注入路径

测试需要 fake `CameraTransport` 和 fake `CameraSession`，但 Domain 已有 `CameraSession`（freezed）。**统一在 `test/helpers/` 下新建**：

```dart
// 文件：test/helpers/fake_camera_transport.dart
class FakeCameraTransport implements CameraTransport {
  final CameraSession sessionToReturn;
  final CameraAppError? errorToThrow;
  
  @override
  Future<CameraSession> connect({required CameraConnectionConfig config}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return sessionToReturn;
  }
  // ... 其他方法 stub
}

class FakeCameraTransportFactory implements CameraTransportFactory {
  final FakeCameraTransport fakeTransport;
  @override
  CameraTransport makeTransport() => fakeTransport;
}
```

**使用 pattern**：
```dart
test('connect 成功', () async {
  final container = ProviderContainer(overrides: [
    transportFactoryProvider.overrideWithValue(FakeCameraTransportFactory(
      fakeTransport: FakeCameraTransport(
        sessionToReturn: CameraSession(
          id: 'test-1', cameraName: 'Test Camera',
          connectedHost: '192.168.1.1', port: 15740,
          connectedAt: DateTime.now(), capabilities: {...},
        ),
      ),
    )),
  ]);
  // ...
});
```

---

## 4. 目录结构（新建的加粗）

```
lib/
├── main.dart                          ← runApp(ProviderScope(child: ViewfinderApp()))
├── app.dart                           ← MaterialApp + NavigationBar + 4 Tab
│
├── domain/                            ← 不变
│
├── protocol/                          ← 不变
│
├── services/
│   └── preferences_store.dart         ← AppPreferencesStore (shared_preferences)
│
├── features/
│   ├── connection_setup/
│   │   ├── connection_container.dart ← 组合根（ConsumerWidget，watch providers → 渲染 page）
│   │   ├── connection_page.dart       ← 连接页 UI（纯 Widget）
│   │   ├── connection_view_model.dart ← ConnectionNotifier
│   │   └── widgets/                   ← ConnectButton / StatusIndicator / LensGlowView 占位
│   ├── photo_browser/
│   │   ├── gallery_container.dart    ← 组合根
│   │   ├── gallery_page.dart          ← 缩略图网格 UI
│   │   ├── gallery_view_model.dart    ← GalleryNotifier
│   │   └── widgets/                   ← ThumbnailGrid / PlaceholderThumb / StateChip
│   ├── downloads/
│   │   ├── downloads_container.dart   ← 组合根
│   │   ├── downloads_page.dart        ← 队列页（占位）
│   │   └── download_manager_view_model.dart ← DownloadManagerNotifier
│   ├── settings/
│   │   ├── settings_container.dart   ← 组合根
│   │   ├── settings_page.dart         ← 设置页
│   │   ├── settings_view_model.dart   ← PreferencesNotifier
│   │   └── widgets/                   ← FormFieldRow / ToggleRow（表单输入复用）
│   └── shared/
│       ├── app_theme.dart             ← 暖白 + 琥珀金 + 14 token + typography + spacing + workflowColor() + MetricTile
│       ├── shared_components.dart     ← PrimaryActionButton / SecondaryActionButton / CustomCard / SectionHeader / GridRowItem / DownloadProgressDetails / Haptics / ShimmerView / LensGlowView
│       ├── formatters.dart            ← byteSize / date 格式化
│       └── status_badge.dart          ← StatusBadge（对标 iOS App/StatusBadgeView.swift 独立文件）
│
└── services/
    ├── preferences_store.dart         ← AppPreferencesStore (shared_preferences)
    └── logger.dart                    ← 占位 Logger（包 package:logging）— 路径与 Viewfinder方案.md §11.1 对齐
```

**为什么用三件套（Container / Page / ViewModel）**：
- AGENTS.md §4 / Viewfinder方案.md §11 都要求三件套
- 原 iOS 每个 Feature 都有 ContainerView/View/ViewModel
- Container 是 Provider 与 Widget 的连接点：用 `ConsumerWidget` watch providers + 把数据传给 `Page`
- Page 是纯 Widget：不直接 ref.watch，保持 presentation 层无业务
- ViewModel 是 Notifier：业务逻辑 + 状态

**为什么 Connection/Gallery 加 `widgets/` 子目录**：
- AGENTS.md §5 要求 View (Page) ≤ 300 行；超出就拆 widget
- Connection 页（LensGlowView 占位 + 状态文字 + 重试提示）容易超 200 行
- Gallery 页（缩略图网格 + 加载/空/错误 3 态）必须拆
- Settings 也加 widgets/：表单行（FormFieldRow / ToggleRow）抽出来避免 Page 超 300 行
- Downloads 是简单占位，Page 本身体积可控，**不拆**

---

## 5. 任务切片（16 个，按顺序）

| # | 任务 | 估时 | 产出 |
|---|---|---|---|
| 2.0 | 创建 features/ 目录骨架（含 widgets/ 子目录） | 15 分钟 | 5 个 feature 目录 + shared/ 目录 | ✅ |
| 2.1 | `pubspec.yaml` 加 `shared_preferences ^2.x` + `google_fonts ^6.x` + `logging ^1.x` | 10 分钟 | `flutter pub get` 干净 | ✅ |
| 2.2 | `services/preferences_store.dart` | 1 小时 | AppPreferencesStore | ✅ |
| 2.3 | `settings_view_model.dart` + 4 单测 | 1.5 小时 | PreferencesNotifier | ✅ |
| 2.4 | `connection_view_model.dart` + 5 单测 | 2 小时 | ConnectionNotifier | ✅ |
| 2.5 | `gallery_view_model.dart` + 5 单测 | 2 小时 | GalleryNotifier | ✅ |
| 2.6 | `download_manager_view_model.dart` + 3 单测 | 1.5 小时 | DownloadManagerNotifier 占位 | ✅ |
| 2.6a | `app_shell_view_model.dart` + 4 单测 | 1.5 小时 | AppShellNotifier（全局 alerts/diagnostics） | ✅ |

#### 5.2 Notifier 测试用例清单

详细 State 类型定义见 §3.1 / §3.2 / §3.3。

**PreferencesNotifier (4)**：
1. `build()` 初始 state：从 `preferencesStoreProvider` 读 `CameraConnectionConfig`，字段映射正确
2. `setHost` / `setPort` / `setTransportMode` / `setAutoExportToPhotoLibrary` / `setPrioritizeJPEGDownloads` 修改字段
3. `save()` 持久化到 SharedPreferences（key: `camera_connection_config`）
4. 改 host 后重启（清空 SharedPreferences 再 load）验证 schema 兼容

**ConnectionNotifier (5)**（状态定义见 §3.2）：
1. `build()` 初始 state：从 `preferencesStoreProvider` 读 config，9 个字段映射正确
2. `connect()` 成功：state.workflowState → `.connecting` → `.connected`，activeSession 非 null（用 FakeCameraTransportFactory mock）
3. `connect()` 失败：state.workflowState → `.error`，lastSummary 写入错误消息
4. `disconnect()`：state.workflowState → `.waitingForWifi`，activeSession = null
5. `setHost` / `setPort` / `setTransportMode`：修改字段并持久化到 preferencesStore

**GalleryNotifier (5)**（状态定义见 §3.3）：
1. `build()` 初始 state：返回 12 个 mock assets 的 AsyncValue.data
2. `refresh()`：state 重置为 12 个 mock
3. `loadMore()`：Phase 2 mock 不变，验证 async 行为完成
4. `toggleSelection(id)`：选/取消改 selectedAssetIDs
5. `selectAllAssets()` / `clearSelection()` 边界（命名对齐 iOS）

**DownloadManagerNotifier (3)**：
1. `build()` 初始 state：`DownloadQueueState.empty()`（`jobs = []`, `status = .idle`）
2. `enqueue(asset)`：构造 `PhotoAsset(id: '1', remoteIdentifier: '100', fileName: 'DSC_0100.NEF', kind: .raw, byteSize: 10MB, captureDate: DateTime.now())` 后调 `enqueue`，state.jobs.length = 1
3. `cancelJob(id)`：status → `.cancelled`

**AppShellNotifier (4)**（§3.1 已列）：
1. 状态切换：`setGlobalActivityTitle` / `dismissAlert` / `showAlert`
2. `appendLog` FIFO 30 条上限
3. `handleError` 接受 `StateError('boom')`（普通 Error）→ 写 log + 显示 alert
4. `handleError` 接受 `CameraAppError.networkProbeFailed('原因')` → 用 `error.message`（**不**重复拼接 recoverySuggestion，对齐 iOS `userFacingMessage(for:)`）

**测试 mock 注入**（§3.4）：`test/helpers/fake_camera_transport.dart` 提供 `FakeCameraTransport` + `FakeCameraTransportFactory`，测试用 `ProviderContainer(overrides: [transportFactoryProvider.overrideWithValue(...)])` 注入。

| # | 任务 | 估时 | 产出 |
|---|---|---|---|
| 2.7 | features/shared 包（`app_theme.dart` + `shared_components.dart` + `formatters.dart` + `status_badge.dart`） | 4 小时 | 主题 + 9 widget + 3 formatter（详见 §2.4） | ✅ |
| 2.7a | `lib/services/logger.dart`（统一路径，§18 修订） | 30 分钟 | 包 package:logging 占位 Logger | ✅ |
| 2.8 | `connection_container.dart` + `connection_page.dart`（+ widgets/ 删空目录） | 1.5 小时 | 连接页 UI（未连接 + 已连接 readySection） | ✅ |
| 2.9 | `gallery_container.dart` + `gallery_page.dart`（+ widgets/ 删空目录） | 2.5 小时 | 缩略图网格 + 3 态 + 12 mock + filterBar (4 chip 占位) + MetricTile (已加载/已选择 占位) | ✅ |
| 2.10 | `downloads_container.dart` + `downloads_page.dart` | 1.5 小时 | 队列页（5 section 占位：overview/queue/active/throughput/records） | ✅ |
| 2.11 | `settings_container.dart` + `settings_page.dart`（+ widgets/ 删空目录） | 1.5 小时 | 设置页（4 section：相机连接/下载行为/当前生效值/支持与版本） | ✅ |
| 2.12 | `app.dart` + `main.dart` 装配 | 1.5 小时 | ProviderScope + Tab + entry point | ✅ |
| 2.13 | 8 widget smoke test（每页 happy + error） | 2.5 小时 | 8 个 smoke test | ✅ |
| 2.13a | `lib/services/download_asset_prioritizer.dart`（JPEG 优先排序） | 30 分钟 | 对齐 iOS DownloadAssetPrioritizer enum | ✅ |
| 2.14 | `analysis_options.yaml` 加强（具体规则见 §6.6） | 30 分钟 | 全套 lint | ✅ |
| 2.15 | 验收 + commit + push + 更新 docs | 1 小时 | git + 项目状态.md | ⏳ 待用户决定 commit |

**总估时**：~28 小时纯干活（不含验收；按 4-5h/天 → **约 2.5 周**）

> 注：§1 "约 4 周" 含偶发中断 / 反馈等待；这里取 2.5 周为中等估计。

### 5.1 任务依赖图

执行前先看清依赖关系。**严格按编号顺序做**，每个任务产出是下一个的输入。

| 任务 | 前置 | 产出 |
|---|---|---|
| 2.0 目录 | — | 5 个 feature 目录 + shared/ 目录 |
| 2.1 pubspec | — | shared_preferences + google_fonts + package:logging |
| 2.2 preferences_store | 2.1 | AppPreferencesStore |
| 2.3 PreferencesNotifier | 2.2 | Notifier + 4 测试 |
| 2.4 ConnectionNotifier | 2.2 | Notifier + 5 测试 |
| 2.5 GalleryNotifier | 2.4 | Notifier + 5 测试 |
| 2.6 DownloadManagerNotifier | 2.4 | Notifier + 3 测试 |
| 2.6a AppShellNotifier | — | Notifier + 4 测试 |
| 2.7 shared 包 | — | app_theme + shared_components + formatters + status_badge + 5 widgets |
| 2.7a services/logger.dart | 2.1 | 包装 package:logging 占位 Logger |
| 2.8 connection_container + page + widgets | 2.4, 2.7 | UI（未连 + 已连 readySection） |
| 2.9 gallery_container + page + widgets | 2.5, 2.7 | UI |
| 2.10 downloads_container + page | 2.6, 2.7 | UI（5 section 占位） |
| 2.11 settings_container + page + widgets | 2.3, 2.7 | UI（3 section） |
| 2.12 app 装配 | 2.0-2.11 | 全链路打通 |
| 2.13 widget smoke | 2.12 | 8 个 smoke test |
| 2.13a download_asset_prioritizer | 2.6 | JPEG 优先排序 |
| 2.14 lint | 2.13 | 全套 lint |
| 2.15 验收 | 2.14 | commit + push + docs |

**任务 2.12 entry point 结构**（对标原 iOS `NikonConnectApp.swift` 66 行手工注入）：

```dart
// main.dart — 23 行
void main() {
  runApp(const ProviderScope(child: ViewfinderApp()));
}

// app.dart — ViewfinderApp 内部
class ViewfinderApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),  // amber 主题
      home: AppShell(),         // NavigationBar + 4 Tab
    );
  }
}

// AppShell (在 app.dart) 用 NavigationBar + IndexedStack 切换 4 Tab
// 每 Tab 调用对应 *_container.dart 的 build()
```

**关键设计**：
- `ProviderScope` 顶层注入；不用 `autoDispose`（Phase 2 占位 UI 不频繁创建销毁）
- 6 个 Provider（preferencesStore / transportFactory / connection / gallery / downloadManager / preferences / appShell）在 ProviderScope 内自动 `ref.watch` 解析依赖
- 单测时用 `ProviderContainer` + `overrideWith` 注入 fake transport（task 2.4-2.6 测试）

**Tab 标签决策**：用 HTML 原型 "连接 / 相册 / 下载 / 设置"
- iOS 原项目用 "相机 / 照片 / 下载 / 设置"（SwiftUI NavigationStack 时代产物）
- Phase 2 用更操作化标签 —— "连接"强调动作、"相册"强调产物（跟原 iOS `相机` / `照片` 对位但用词更准确）
- HTML 原型 amber 主题已经选了这套，Phase 2 一致使用

---

## 6. 验收标准

```bash
cd "D:\桌面\Nikon_connect\Viewfinder"

dart analyze                     # No issues found!
flutter test                     # All tests passed (≥ 68 total)
flutter build apk --debug        # BUILD SUCCESSFUL
```

1. `dart analyze` 零警告
2. `flutter test` 全绿（现存 47 + 新增 29 = 76）
3. `flutter build apk --debug` 能装到 Android 真机
4. `flutter run` 起 app，4 个 Tab 切换正常
5. Settings 页改 host/port 保存后重启不变（**Phase 2 新增功能**：原 iOS Settings 页 host/port 只读；Phase 2 加可编辑输入框，对应 `PreferencesNotifier.setHost/setPort` 方法）
6. 连接页显示：
   - **未连接态**：LensGlowView 占位 + 状态文字（"未连接 — 请先连接相机 Wi-Fi"）+ 主按钮 "连接相机"
   - **已连接态**（readySection）：CustomCard 容器，相机名 + 照片数（"X 张照片"）+ "重新读取"按钮 + 断开连接次按钮
7. 相册页显示占位缩略图（mock 数据，12 个色块 + 标签）+ filterBar（4 chip 占位）+ MetricTile（已加载/已选择 占位）
8. 下载页显示 5 section 占位（overview / queue / active / throughput / records），每个 section 标 "Phase 3 实现"

---

## 6.5 已知坑和应急方案

### 6.5.1 google_fonts 首次下载失败

**症状**：
```
FontException: ... Could not find FontManifest
```

**原因**：`google_fonts ^6.x` 首次运行会从 Google Fonts CDN 拉字体；网络不稳或被墙时失败。

**解法**：
1. 短期：pubspec 加 `google_fonts: ^6.x`，运行时允许拉取：
   ```dart
   // main.dart 入口
   GoogleFonts.config.allowRuntimeFetching = true;
   ```
2. 长期（Phase 4 视觉抛光时）：把字体文件下载到 `assets/fonts/` 用本地版本（pubspec 加 `fonts:` 段）

### 6.5.2 shared_preferences 在测试中需要 mock

**症状**：Notifier 跑测试时报 `MissingPluginException` 或拿到 null

**解法**：标准 pattern
```dart
setUp(() async {
  SharedPreferences.setMockInitialValues({'host': '192.168.1.1'});
});
```

### 6.5.3 Riverpod 2.x Notifier API 跟旧 Provider 不同

**症状**：用旧 `StateNotifier` 写法编译失败；或 `FooState.initial()` 不存在（freezed 默认是 `FooState()`）。

**解法**：照官方 Notifier 文档写
```dart
@freezed
class FooState with _$FooState {
  const factory FooState({@Default(0) int count}) = _FooState;
}

class FooNotifier extends Notifier<FooState> {
  @override
  FooState build() => const FooState();  // 默认 freezed factory，不是 initial()
  // ...
}
final fooProvider = NotifierProvider<FooNotifier, FooState>(FooNotifier.new);
```

### 6.5.4 中文路径下 Flutter 工具链偶发崩溃

**症状**：`flutter pub get` 或 `flutter test` 在中文路径下偶发 LSP / IO 错误

**解法**：用 `dart analyze` 和 `dart test` 替代（仅在 UI 阶段有效；构建仍需 `flutter`）

---

### 6.6 Lint 规则（任务 2.14）

`analysis_options.yaml` 在现有 `flutter_lints ^6.0.0` 基础上加：

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - require_trailing_commas
    - avoid_print
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
    - prefer_final_locals
    - prefer_final_in_for_each
    - unawaited_futures
```

**不启用**（Phase 2 太严会卡住）：
- `always_declare_return_types`（Phase 2 快速写很多 Notifier，先不强求）
- `public_member_api_docs`（Phase 4 再加）

---

## 7. 不在本 Phase 范围

- ❌ 真机连 Nikon 验证（Phase 3）
- ❌ 缩略图从相机拉取（Phase 3 才接 `downloadThumbnail`）
- ❌ 下载完整文件（Phase 3）
- ❌ 进度通知 / Foreground Service（Phase 3）
- ❌ 触觉 / 动画 / 动效（Phase 4）
- ❌ iOS 平台创建（Phase 3）

### 7.1 Phase 3 注意事项（提前 flag）

**AssetThumbnailService 简化方案**（原 iOS 715 行 → Phase 3 必须简化）：

原 iOS 6 字典 × 2 种 derivative（thumbnail + preview）+ Task in-flight + unavailable set。Phase 3 简化为：
- 单 `thumbnail` derivative（首版只做 thumbnail；preview 跳过，Phase 4 才需要）
- 单字典 `_cache: Map<remoteIdentifier, Uint8List>`
- 单 Task 去重 `_inFlight: Map<remoteIdentifier, Future<Uint8List?>>`
- 磁盘缓存用 `path_provider`（Phase 3 已实现：内存 cache + in-flight 去重；磁盘 cache 因 Android 文件系统性能不适合小文件高频读写，改用纯内存方案）

不要复刻原 iOS 6 字典 + 2 derivative 的过度工程 — 当前架构只需要 1 个。

---

## 8. 提交规范

格式：`<动词><对象>：<一句话说明>`

例：
```
实现 features/shared 包：app_theme + shared_components + formatters
实现 PreferencesNotifier + settings_page 设置页读写
实现 connection_page + ConnectionNotifier 连接页 UI
实现 app.dart Tab 装配 + ProviderScope 全链路打通
```

---

## 9. 完成后

Phase 2 结束后，本工程就有了完整的 UI 骨架（4 Tab + Provider + 主题）。Phase 3 在骨架上填肉：真机验证 + 下载 + 进度通知。

**这份文档 = Phase 2 的工作说明书。**
