import 'package:flutter/material.dart';

import '../../domain/camera_connection_config.dart';
import '../shared/shared_components.dart';

class DefaultsSection extends StatelessWidget {
  const DefaultsSection({super.key, required this.config});

  final CameraConnectionConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('当前生效值'),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              GridRowItem(
                label: '目标地址',
                value: '${config.host}:${config.port}',
                icon: Icons.wifi,
              ),
              const SizedBox(height: 8),
              GridRowItem(
                label: '下载后处理',
                value: config.autoExportToPhotoLibrary
                    ? '下载后同步到系统相册'
                    : '仅保留在应用本地',
                icon: Icons.photo_library_outlined,
              ),
              const SizedBox(height: 8),
              GridRowItem(
                label: '下载排序',
                value: config.prioritizeJPEGDownloads
                    ? 'JPEG / PNG 优先，RAW 后补'
                    : '保持相机当前顺序',
                icon: Icons.swap_vert,
              ),
            ],
          ),
        ),
      ],
    );
  }
}