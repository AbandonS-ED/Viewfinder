/// Shared widget 集合（barrel file）。
///
/// 每个 widget / utility 都在独立文件中实现，方便引用和测试：
/// - [section_header.dart] SectionHeader
/// - [custom_card.dart] CustomCard
/// - [primary_action_button.dart] PrimaryActionButton
/// - [secondary_action_button.dart] SecondaryActionButton
/// - [grid_row_item.dart] GridRowItem
/// - [download_progress_details.dart] DownloadProgressDetails
/// - [haptics.dart] Haptics
/// - [shimmer_view.dart] ShimmerView
/// - [lens_glow_view.dart] LensGlowView
///
/// 旧 import 路径 `shared_components.dart` 仍可用。
library;

export 'widgets/custom_card.dart';
export 'widgets/download_progress_details.dart';
export 'widgets/grid_row_item.dart';
export 'widgets/haptics.dart';
export 'widgets/lens_glow_view.dart';
export 'widgets/primary_action_button.dart';
export 'widgets/secondary_action_button.dart';
export 'widgets/section_header.dart';
export 'widgets/shimmer_view.dart';