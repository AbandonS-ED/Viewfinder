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

void main() {
  testWidgets('ConnectionPage 未连接态：显示 LensGlow + 连接按钮', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectionPage(
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
      MaterialApp(
        home: ConnectionPage(
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
      MaterialApp(
        home: GalleryPage(
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
      MaterialApp(
        home: GalleryPage(
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
      const MaterialApp(
        home: DownloadsPage(state: DownloadQueueState()),
      ),
    );
    expect(find.text('概览'), findsOneWidget);
    expect(find.text('下载队列'), findsOneWidget);
  });

  testWidgets('SettingsPage 默认配置：显示开关和 GridRow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: SettingsPage(
            config: const CameraConnectionConfig(),
            onSetHost: (_) {},
            onSetPort: (_) {},
            onSetAutoExport: (_) {},
            onSetPrioritizeJPEG: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('相机连接'), findsOneWidget);
    expect(find.text('下载行为'), findsOneWidget);
    expect(find.text('当前生效值'), findsOneWidget);
  });

  testWidgets('ConnectionPage 连接中：显示 loading 指示器', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectionPage(
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
      MaterialApp(
        home: GalleryPage(
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
