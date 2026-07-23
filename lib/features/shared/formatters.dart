String fileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) {
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(1)} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
  final gb = bytes / (1024 * 1024 * 1024);
  return '${gb.toStringAsFixed(2)} GB';
}

String logTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// 拍摄时间格式化（中文本地化）：今天 / 昨天 / 本年内 / 跨年
String captureDate(DateTime dt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final diffDays = today.difference(target).inDays;
  final hm = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  if (diffDays == 0) return '今天 $hm';
  if (diffDays == 1) return '昨天 $hm';
  if (dt.year == reference.year) {
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hm';
  }
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
