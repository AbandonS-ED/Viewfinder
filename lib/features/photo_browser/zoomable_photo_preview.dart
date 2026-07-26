import 'package:flutter/material.dart';

import '../shared/viewfinder_theme.dart';

/// 全屏照片预览：双击缩放 + 拖动平移 + 单击关闭（仅 1x）
///
/// - **双击落点 → 2.5x**，再双击回到 1x
/// - **缩放状态（>1.1x）下单击空白处不关闭**，避免误触
/// - **1x 状态下单击关闭**，符合 iOS Photos 习惯
/// - **缩放时 close 按钮淡出**，避免遮挡照片
/// - **拖动平移**：InteractiveViewer 内置，缩放后自动启用
class ZoomablePhotoPreview extends StatefulWidget {
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

  /// 点击关闭回调（仅在 1x 时由内部 tap 触发；close 按钮不受缩放限制）
  final VoidCallback onClose;

  @override
  State<ZoomablePhotoPreview> createState() => _ZoomablePhotoPreviewState();
}

class _ZoomablePhotoPreviewState extends State<ZoomablePhotoPreview> {
  /// 双击缩放的目标倍率
  static const double _zoomedScale = 2.5;

  /// 判定是否"已缩放"的阈值（大于此值则视为进入缩放态）
  static const double _zoomThreshold = 1.1;

  final TransformationController _ctrl = TransformationController();

  /// 同步 InteractiveViewer 的当前缩放比例
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTransformChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final next = _ctrl.value.getMaxScaleOnAxis() > _zoomThreshold;
    if (next != _isZoomed) {
      setState(() => _isZoomed = next);
    }
  }

  /// 双击处理：1x ↔ _zoomedScale 切换，缩放中心为屏幕中心
  /// （iOS Photos 行为一致：不缩放到落点，而是中心）
  void _handleDoubleTap() {
    if (_isZoomed) {
      _ctrl.value = Matrix4.identity();
    } else {
      _ctrl.value = Matrix4.identity()..scaleByDouble(_zoomedScale, _zoomedScale, 1.0, 1.0);
    }
  }

  /// 单击关闭（仅 1x）；缩放态下空 tap 不响应，避免误触
  void _handleTap() {
    if (!_isZoomed) {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    final imageWidget = widget.heroTag == null
        ? widget.image
        : Hero(tag: widget.heroTag!, child: widget.image);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // onDoubleTap + onTap 共存：onTap 会被双击检测窗口延迟 ~300ms
              // （iOS Photos 同样行为：单击关闭有轻微延迟）
              onDoubleTap: _handleDoubleTap,
              onTap: _handleTap,
              child: InteractiveViewer(
                transformationController: _ctrl,
                minScale: 1.0,
                maxScale: 5.0,
                child: Center(child: imageWidget),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isZoomed ? 0.0 : 1.0,
              child: IconButton(
                icon: Icon(Icons.close, color: t.btnT, size: 28),
                onPressed: widget.onClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}