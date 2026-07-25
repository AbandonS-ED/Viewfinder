import 'package:flutter/material.dart';

import '../../domain/camera_connection_config.dart';
import '../shared/shared_components.dart';
import '../shared/theme_palette.dart';
import '../shared/viewfinder_theme.dart';
import 'appearance_section.dart';
import 'defaults_section.dart';
import 'support_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.config,
    required this.onSetHost,
    required this.onSetPort,
    required this.onSetAutoExport,
    required this.onSetPrioritizeJPEG,
    required this.selectedPalette,
    required this.onSelectTheme,
    this.onExportLogs,
  });

  final CameraConnectionConfig config;
  final void Function(String) onSetHost;
  final void Function(String) onSetPort;
  final void Function(bool) onSetAutoExport;
  final void Function(bool) onSetPrioritizeJPEG;
  final ThemePalette selectedPalette;
  final void Function(String) onSelectTheme;
  final Future<void> Function()? onExportLogs;

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
        AppearanceSection(
          selectedPalette: widget.selectedPalette,
          onSelectTheme: widget.onSelectTheme,
        ),
        const SizedBox(height: 24),
        _downloadSection(context),
        const SizedBox(height: 24),
        DefaultsSection(config: widget.config),
        const SizedBox(height: 24),
        SupportSection(
          appVersion: 'v0.2.0',
          onExportLogs: widget.onExportLogs,
        ),
      ],
    );
  }

  Widget _connectionSection(BuildContext context) {
    final t = ViewfinderTheme.of(context);
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
                  color: t.t2,
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
    final t = ViewfinderTheme.of(context);
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
              Divider(height: 24, color: t.div),
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
                      color: t.t2,
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

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required void Function(String) onSubmitted,
  }) {
    final t = ViewfinderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.t2,
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
          style: TextStyle(fontSize: 16, color: t.t1),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: TextStyle(color: t.tm),
            filled: true,
            fillColor: t.controlBg,
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
    final t = ViewfinderTheme.of(context);
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
          activeTrackColor: t.aL,
          activeThumbColor: t.aS,
          onChanged: onChanged,
        ),
      ],
    );
  }
}