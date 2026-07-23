import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection_view_model.dart';
import 'connection_page.dart';

class ConnectionContainer extends ConsumerWidget {
  const ConnectionContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionProvider);
    final notifier = ref.read(connectionProvider.notifier);
    return ConnectionPage(
      state: state,
      onConnect: () => notifier.connect(),
      onDisconnect: () => notifier.disconnect(),
    );
  }
}
