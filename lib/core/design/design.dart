/// The Posely AI design system — one import for the whole component kit.
///
/// A dark-first, glassmorphic component library built on the Phase-1
/// design tokens (colors, typography, spacing, radius, shadows, blur,
/// motion) with the emerald brand identity at its core. Import this
/// barrel instead of individual component files:
///
/// ```dart
/// import 'package:posely_ai/core/design/design.dart';
/// ```
///
/// The kit is organized by role:
/// - glass: frosted blur surfaces (panels and tappable cards)
/// - buttons: filled, glass, ghost, and danger buttons plus icon buttons
/// - chips: selectable filter chips
/// - inputs: branded text fields
/// - sheets: modal bottom sheets
/// - dialogs: alert and confirm dialogs
/// - feedback: toasts and snackbars
/// - states: empty and success placeholders
/// - skeleton: shimmer loading placeholders
/// - score: AI score rings and pills
/// - common: shared layout pieces such as section headers
///
/// Every component is showcased on the dev-only gallery screen at
/// /dev/design-gallery and documented in docs/DESIGN_SYSTEM.md.
library;

export 'package:posely_ai/core/design/buttons/posely_button.dart';
export 'package:posely_ai/core/design/buttons/posely_icon_button.dart';
export 'package:posely_ai/core/design/chips/posely_chip.dart';
export 'package:posely_ai/core/design/common/section_header.dart';
export 'package:posely_ai/core/design/dialogs/posely_dialog.dart';
export 'package:posely_ai/core/design/feedback/posely_snackbar.dart';
export 'package:posely_ai/core/design/feedback/posely_toast.dart';
export 'package:posely_ai/core/design/glass/glass_card.dart';
export 'package:posely_ai/core/design/glass/glass_panel.dart';
export 'package:posely_ai/core/design/inputs/posely_text_field.dart';
export 'package:posely_ai/core/design/score/score_pill.dart';
export 'package:posely_ai/core/design/score/score_ring.dart';
export 'package:posely_ai/core/design/sheets/posely_bottom_sheet.dart';
export 'package:posely_ai/core/design/skeleton/pose_card_skeleton.dart';
export 'package:posely_ai/core/design/skeleton/shimmer_box.dart';
export 'package:posely_ai/core/design/skeleton/skeleton_grid.dart';
export 'package:posely_ai/core/design/states/empty_state.dart';
export 'package:posely_ai/core/design/states/success_state.dart';
