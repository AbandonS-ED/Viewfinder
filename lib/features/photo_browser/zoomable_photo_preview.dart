import 'package:flutter/material.dart';

import '../shared/viewfinder_theme.dart';

/// 全屏照片预览：双击缩放 + 拖动平移 + 点击关闭
class ZoomablePhotoPreview extends StatelessWidget {
  const ZoomablePhotoPreview({
    super.key,
    required this.image,
    this.heroTag,
    required this.onClose,
  });

  /// 已渲染好的图片 widget（一般是 Image.memory / Image.network）
  final Widget image;

  /// Hero 动画标签（可选，用于从 thumbnail 飞入）
  final Object? heroTag;

  /// 点击关闭回调
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(
                  child: heroTag == null
                      ? image
                      : Hero(tag: heroTag!, child: image),
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: t.btnT, size: 28),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}