import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/active_download_progress.dart';
import '../formatters.dart' as fmt;
import '../viewfinder_theme.dart';

class DownloadProgressDetails extends StatelessWidget {
  const DownloadProgressDetails({super.key, required this.progress});

  final ActiveDownloadProgress progress;

  @override
  Widget build(BuildContext context) {
    final t = ViewfinderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.fileName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '第 ${progress.currentItemNumber} / ${progress.totalItemCount} 项',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              progress.percentageText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.aS,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.fractionCompleted,
            backgroundColor: t.surfaceMuted,
            valueColor: AlwaysStoppedAnimation(t.aS),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${fmt.fileSize(progress.bytesTransferred)} / ${fmt.fileSize(progress.totalBytes)}',
          style: GoogleFonts.dmMono(
            textStyle: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}