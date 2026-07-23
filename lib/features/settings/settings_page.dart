import 'package:flutter/material.dart';

import '../../domain/camera_connection_config.dart';
import '../shared/app_theme.dart';
import '../shared/shared_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.config,
    required this.onSetHost,
    required this.onSetPort,
    required this.onSetAutoExport,
    required this.onSetPrioritizeJPEG,
  });

  final CameraConnectionConfig config;
  final void Function(String) onSetHost;
  final void Function(String) onSetPort;
  final void Function(bool) onSetAutoExport;
  final void Function(bool) onSetPrioritizeJPEG;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;

  @override
  void initState() {
    super.initState();
    _hostCtrl = TextEditingController(text: widget.config.host);
    _portCtrl = TextEditingController(text: widget.config.port.toString());
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.host != widget.config.host &&
        _hostCtrl.text != widget.config.host) {
      _hostCtrl.text = widget.config.host;
    }
    if (oldWidget.config.port != widget.config.port &&
        _portCtrl.text != widget.config.port.toString()) {
      _portCtrl.text = widget.config.port.toString();
    }
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _connectionSection(context),
        const SizedBox(height: 24),
        _downloadSection(context),
        const SizedBox(height: 24),
        _defaultsSection(context),
        const SizedBox(height: 24),
        _supportSection(context),
      ],
    );
  }

  Widget _connectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('相机连接'),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '先在相机上启用 Wi-Fi，然后填下面这台相机的 IP 和端口。',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppThemeColors.t2,
                ),
              ),
              const SizedBox(height: 16),
              _buildField(
                context,
                label: '相机 IP',
                controller: _hostCtrl,
                hint: '192.168.1.1',
                keyboardType: TextInputType.url,
                onSubmitted: widget.onSetHost,
              ),
              const SizedBox(height: 14),
              _buildField(
                context,
                label: '端口',
                controller: _portCtrl,
                hint: '15740',
                keyboardType: TextInputType.number,
                onSubmitted: widget.onSetPort,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _downloadSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('下载行为'),
        const SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              _buildToggle(
                context,
                title: '允许自动导出到系统相册',
                value: widget.config.autoExportToPhotoLibrary,
                onChanged: widget.onSetAutoExport,
              ),
              const Divider(height: 24, color: AppThemeColors.div),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggle(
                    context,
                    title: '启用 JPEG 优先 / RAW 后补',
                    value: widget.config.prioritizeJPEGDownloads,
                    onChanged: widget.onSetPrioritizeJPEG,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '选中混合格式时，会优先下载 JPEG / PNG，再继续下载 RAW 和视频，体感会更快。',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppThemeColors.t2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _defaultsSection(BuildContext context) {
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
                value: '${widget.config.host}:${widget.config.port}',
                icon: Icons.wifi,
              ),
              const SizedBox(height: 8),
              GridRowItem(
                label: '下载后处理',
                value: widget.config.autoExportToPhotoLibrary
                    ? '下载后同步到系统相册'
                    : '仅保留在应用本地',
                icon: Icons.photo_library_outlined,
              ),
              const SizedBox(height: 8),
              GridRowItem(
                label: '下载排序',
                value: widget.config.prioritizeJPEGDownloads
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

  Widget _supportSection(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader('支持与版本'),
        SizedBox(height: 12),
        CustomCard(
          child: Column(
            children: [
              GridRowItem(
                label: '版本',
                value: 'Viewfinder v0.2.0',
                icon: Icons.info_outline,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required void Function(String) onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppThemeColors.t2,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onSubmitted: onSubmitted,
          onChanged: onSubmitted,
          style: const TextStyle(fontSize: 16, color: AppThemeColors.t1),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: AppThemeColors.tm),
            filled: true,
            fillColor: AppThemeColors.controlBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(
          value: value,
          activeTrackColor: AppThemeColors.aL,
          activeThumbColor: AppThemeColors.aS,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
