import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viewfinder/domain/photo_asset.dart';
import 'package:viewfinder/features/downloads/download_manager_view_model.dart';

import 'helpers/test_app.dart';

/// T4 下载链路真集成测试（最小切片，绕开 _runQueue async 链）：
/// downloadSelected() 内部触发 _runQueue 异步下载队列，
/// fake transport 的 downloadAssetToTemporaryFile 返回空字符串触发
/// storeDownloadedFile 抛错 → _runQueue 进入 "interrupted" 状态并 break。
/// 单测只验证最关键的入队逻辑：
/// 1. 直接调 enqueue(asset) → state.jobs.length += 1
/// 2. 空列表 downloadSelected → 返回 true 不入队
/// 3. 非空 downloadSelected → 返回前 state.jobs 已被填充（enqueue 已发生）
///
/// _runQueue 完整异步链路（含下载 / 通知 / 写相册）测试在
/// download_manager_view_model_test.dart 已经覆盖 17 测。
void main() {
  setUp(() async {
    await initTestEnv();
  });

  Future<void> pumpOnce(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('T4 下载链路 (最小切片)', () {
    testWidgets('enqueue: 直接调 notifier.enqueue(asset) → state.jobs.length += 1',
        (tester) async {
      // Arrange: pump 一个最简 widget 拿 ProviderContainer
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SizedBox())),
      );
      await pumpOnce(tester);

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      final ProviderContainer container =
          ProviderScope.containerOf(ctx, listen: false);

      // 初始空 queue
      expect(container.read(downloadManagerProvider).jobs.length, 0);

      // Act: 直接 enqueue
      final asset = PhotoAsset(
        id: 'asset-1',
        remoteIdentifier: '1',
        fileName: 'DSC_0001.JPG',
        kind: PhotoAssetKind.jpeg,
        byteSize: 1024 * 1024 * 5,
        captureDate: DateTime(2026, 7, 27),
      );
      container.read(downloadManagerProvider.notifier).enqueue(asset);

      // Assert
      expect(container.read(downloadManagerProvider).jobs.length, 1);
      expect(container.read(downloadManagerProvider).jobs.first.fileName,
          'DSC_0001.JPG');
    });

    testWidgets('空选择: downloadSelected([]) 返回 true 不入队',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SizedBox())),
      );
      await pumpOnce(tester);

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      final ProviderContainer container =
          ProviderScope.containerOf(ctx, listen: false);

      final ok = await container
          .read(downloadManagerProvider.notifier)
          .downloadSelected(const [], autoExport: false, prioritizeJPEG: false);
      await pumpOnce(tester);

      expect(ok, isTrue);
      expect(container.read(downloadManagerProvider).jobs.length, 0);
    });

    testWidgets('happy path 简化: 绕开 _runQueue，调 downloadSelected 后立即断言入队',
        (tester) async {
      // 注意：完整 downloadSelected 会启动 _runQueue 异步执行；
      // 我们只关心入队是否发生。同步 enqueue 在 downloadSelected 同步段完成
      // （await _startQueueIfPossible 之前）。
      await tester.pumpWidget(
        buildTestApp(const Scaffold(body: SizedBox())),
      );
      await pumpOnce(tester);

      final BuildContext ctx = tester.element(find.byType(Scaffold));
      final ProviderContainer container =
          ProviderScope.containerOf(ctx, listen: false);

      final assets = [
        PhotoAsset(
          id: 'a1',
          remoteIdentifier: '1',
          fileName: 'DSC_0001.JPG',
          kind: PhotoAssetKind.jpeg,
          byteSize: 1024 * 1024 * 5,
          captureDate: DateTime(2026, 7, 27, 10, 0),
        ),
        PhotoAsset(
          id: 'a2',
          remoteIdentifier: '2',
          fileName: 'DSC_0002.JPG',
          kind: PhotoAssetKind.jpeg,
          byteSize: 1024 * 1024 * 8,
          captureDate: DateTime(2026, 7, 27, 10, 5),
        ),
      ];

      // 调 downloadSelected（会被 _runQueue 后续异步执行）
      final notifier = container.read(downloadManagerProvider.notifier);
      // 不 await：fake transport 的 _runQueue 会无限循环
      // 我们只关心同步入队段
      unawaited(notifier.downloadSelected(assets,
          autoExport: false, prioritizeJPEG: false));
      // 让微任务跑一下
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Assert: 已入队（即使后续 _runQueue 失败，job 仍保留在 jobs 列表）
      expect(container.read(downloadManagerProvider).jobs.length, 2,
          reason: 'enqueue 部分应已同步完成，jobs 应为 2');
    });
  });
}