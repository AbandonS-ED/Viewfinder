import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viewfinder/domain/camera_connection_config.dart';
import 'package:viewfinder/domain/camera_session.dart';
import 'package:viewfinder/domain/camera_workflow_state.dart';
import 'package:viewfinder/domain/download_queue_state.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/features/connection_setup/connection_page.dart';
import 'package:viewfinder/features/connection_setup/connection_state.dart' as cs;
import 'package:viewfinder/features/downloads/downloads_page.dart';
import 'package:viewfinder/features/photo_browser/gallery_page.dart';
import 'package:viewfinder/features/photo_browser/gallery_state.dart';
import 'package:viewfinder/features/settings/settings_page.dart';
import 'package:viewfinder/features/shared/theme_palette.dart';
import 'package:viewfinder/features/shared/viewfinder_theme.dart';

Widget _wrap(Widget home) => MaterialApp(
      theme: viewfinderTheme(amberPalette),
      home: home,
    );

void main() {
  testWidgets('ConnectionPage 未连接态：显示 LensGlow + 连接按钮', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ConnectionPage(
          state: const cs.ConnectionState(),
          onConnect: () {},
          onDisconnect: () {},
        ),
      ),
    );
    expect(find.text('连接相机'), findsOneWidget);
    expect(find.text('Viewfinder'), findsOneWidget);
  });

  testWidgets('ConnectionPage 已连接态：显示相机名 + 断开按钮', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ConnectionPage(
          state: cs.ConnectionState(
            workflowState: CameraWorkflowState.connected,
            activeSession: CameraSession(
              id: 's1',
              cameraName: 'Nikon Z8',
              connectedAt: DateTime.now(),
            ),
          ),
          onConnect: () {},
          onDisconnect: () {},
        ),
      ),
    );
    expect(find.text('断开连接'), findsOneWidget);
    expect(find.text('Nikon Z8'), findsOneWidget);
  });

  testWidgets('GalleryPage 空状态：显示暂无照片', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GalleryPage(
          state: const GalleryState(),
          onRefresh: () {},
          onLoadMore: () {},
          onToggleSelection: (_) {},
          onSelectAll: () {},
          onClearSelection: () {},
        ),
      ),
    );
    expect(find.text('暂无照片'), findsOneWidget);
  });

  testWidgets('GalleryPage 加载 12 张 mock：显示缩略图和 MetricTile', (tester) async {
    final mockAssets = List.generate(12, (i) => PhotoAsset(
      id: 'mock-$i',
      remoteIdentifier: '$i',
      fileName: 'DSC_0${i + 100}.NEF',
      kind: i.isEven ? PhotoAssetKind.raw : PhotoAssetKind.jpeg,
      byteSize: 1024 * 1024 * 10,
      captureDate: DateTime.now(),
    ));
    await tester.pumpWidget(
      _wrap(
        GalleryPage(
          state: GalleryState(photoAssets: mockAssets),
          onRefresh: () {},
          onLoadMore: () {},
          onToggleSelection: (_) {},
          onSelectAll: () {},
          onClearSelection: () {},
        ),
      ),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('DownloadsPage 空队列：显示占位 section', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const DownloadsPage(state: DownloadQueueState()),
      ),
    );
    expect(find.text('概览'), findsOneWidget);
    expect(find.text('下载队列'), findsOneWidget);
  });

  testWidgets('SettingsPage 默认配置：显示开关和 GridRow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: SettingsPage(
            config: const CameraConnectionConfig(),
            onSetHost: (_) {},
            onSetPort: (_) {},
            onSetAutoExport: (_) {},
            onSetPrioritizeJPEG: (_) {},
            selectedPalette: amberPalette,
            onSelectTheme: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // 顶部可见 sections：相机连接 + 外观 (新增)
    expect(find.text('相机连接'), findsOneWidget);
    expect(find.text('外观'), findsOneWidget);
    // 主题色按钮 5 个 (amber/forest/slate/terr/onyx)
    expect(find.text('amber'), findsOneWidget);
    expect(find.text('forest'), findsOneWidget);
    expect(find.text('slate'), findsOneWidget);
    expect(find.text('terr'), findsOneWidget);
    expect(find.text('onyx'), findsOneWidget);
  });

  testWidgets('ConnectionPage 连接中：显示 loading 指示器', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ConnectionPage(
          state: const cs.ConnectionState(
            workflowState: CameraWorkflowState.connecting,
            isWorking: true,
          ),
          onConnect: () {},
          onDisconnect: () {},
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('GalleryPage 选中状态：显示全选按钮和选中标记', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GalleryPage(
          state: GalleryState(
            photoAssets: [
              PhotoAsset(id: 'a1', remoteIdentifier: '1', fileName: 'a.jpg',
                  kind: PhotoAssetKind.jpeg, byteSize: 100, captureDate: DateTime.now()),
              PhotoAsset(id: 'a2', remoteIdentifier: '2', fileName: 'b.jpg',
                  kind: PhotoAssetKind.jpeg, byteSize: 200, captureDate: DateTime.now()),
            ],
            selectedAssetIDs: {'a1'},
          ),
          onRefresh: () {},
          onLoadMore: () {},
          onToggleSelection: (_) {},
          onSelectAll: () {},
          onClearSelection: () {},
        ),
      ),
    );
    expect(find.text('全选'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}