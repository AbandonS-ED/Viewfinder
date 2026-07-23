import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/app_shell/app_shell_view_model.dart';
import 'features/connection_setup/connection_container.dart';
import 'features/downloads/downloads_container.dart';
import 'features/photo_browser/gallery_container.dart';
import 'features/settings/settings_container.dart';
import 'features/shared/app_theme.dart';

class ViewfinderApp extends ConsumerStatefulWidget {
  const ViewfinderApp({super.key});

  @override
  ConsumerState<ViewfinderApp> createState() => _ViewfinderAppState();
}

class _ViewfinderAppState extends ConsumerState<ViewfinderApp> {
  int _selectedIndex = 0;
  String? _shownAlertId;

  @override
  Widget build(BuildContext context) {
    ref.listen(appShellProvider.select((s) => s.alertContext), (prev, next) {
      if (next == null) return;
      if (next.id == _shownAlertId) return;
      _shownAlertId = next.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(next.title),
            content: Text(next.message),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(appShellProvider.notifier).dismissAlert();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('好'),
              ),
            ],
          ),
        );
      });
    });

    final shell = ref.watch(appShellProvider);
    final isLoading = shell.isShowingGlobalActivity;

    return MaterialApp(
      title: 'Viewfinder',
      theme: amberTheme(),
      home: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: const [
                ConnectionContainer(),
                GalleryContainer(),
                DownloadsContainer(),
                SettingsContainer(),
              ],
            ),
            if (isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 64),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                shell.globalActivityTitle ?? '加载中…',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wifi_outlined),
              selectedIcon: Icon(Icons.wifi),
              label: '连接',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: '相册',
            ),
            NavigationDestination(
              icon: Icon(Icons.download_outlined),
              selectedIcon: Icon(Icons.download),
              label: '下载',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
