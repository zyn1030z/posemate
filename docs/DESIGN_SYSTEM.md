# Design System

The Phase-2 reference for the Posely AI visual language: tokens, the `lib/core/design/` component kit, feedback patterns, and accessibility rules. The living, on-device version of this document is the dev-only gallery at [`/dev/design-gallery`](#opening-the-gallery).

---

## Philosophy

- **Dark-first.** The flagship experience is a deep-slate dark theme (`#0F172A` background). Light mode exists as a supported variant, but every component is designed on dark and verified there first.
- **Glassmorphism.** Elevated surfaces are frosted glass: low-alpha white fills, hairline strokes, and backdrop blur. Depth comes from blur and soft ambient shadows, not hard elevation.
- **Emerald identity.** One brand hue — emerald `#10B981` — carries the identity: primary actions, selection, glow, success. Everything else stays neutral so photography remains the hero.
- **Inter / InterDisplay type.** Body and UI text use **Inter** (weights 400–700); large headings and hero numerals use **InterDisplay** (weights 600–800) with tight negative tracking. Confident weights, relaxed line heights, Apple-like restraint.
- **Decisive motion.** Micro-interactions are fast (150 ms), transitions default to 250 ms, and long luxurious easings (`easeOutExpo`) are reserved for branded moments.

## Tokens

All tokens live in `lib/core/theme/tokens/` and are compile-time constants. Theme-dependent values resolve through the `PoselyColors` theme extension (`context.posely`).

### Colors (`app_colors.dart`)

Emerald brand scale:

| Token | Hex | Use |
| --- | --- | --- |
| `emerald50` | `#ECFDF5` | Faint mint wash on light surfaces |
| `emerald100` | `#D1FAE5` | Subtle highlights, badges |
| `emerald200` | `#A7F3D0` | Hover tints on light surfaces |
| `emerald300` | `#6EE7B7` | Glow edges, gradients |
| `emerald400` | `#34D399` | Vivid accent, selected icons |
| `emerald500` | `#10B981` | **Core brand emerald** (`primary`) |
| `emerald600` | `#059669` | Pressed / light-mode contrast |
| `emerald700` | `#047857` | Deep gradient ends |
| `emerald800` | `#065F46` | Deep containers |
| `emerald900` | `#064E3B` | Near-forest container tone |

Neutrals and text (dark flagship):

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#0F172A` | App background |
| `surface` | `#111827` | Cards, bars |
| `surfaceElevated` | `#1E293B` | Dialogs, inputs, raised cards |
| `surfaceHighest` | `#334155` | Tracks, handles, pressed fills |
| `outline` | `#33415F` | Hairline outlines |
| `textPrimary` | `#F8FAFC` | Primary text |
| `textSecondary` | `#94A3B8` | Supporting text |
| `textTertiary` | `#64748B` | Hints, captions |
| `textOnPrimary` | `#052E1F` | Text/icons on emerald fills |

Semantic:

| Token | Hex | Use |
| --- | --- | --- |
| `success` | `#10B981` | Positive state (brand-aligned) |
| `warning` | `#F59E0B` | Caution |
| `error` | `#F43F5E` | Errors, destructive actions |
| `info` | `#38BDF8` | Informational |

Glass overlays: `glassWhite` (white 8%), `glassStroke` (white 12%), `glassStrong` (white 14%), `glassDark` / `glassDarkStroke` (light-mode slate equivalents), `scrim` (black 60%).

**Score thresholds** — AI scores are normalized 0..1 and colored by `AppColors.forScore(score)`:

| Range | Token | Color |
| --- | --- | --- |
| `score < 0.5` | `scoreLow` | Rose `#F43F5E` |
| `0.5 ≤ score < 0.8` | `scoreMid` | Amber `#F59E0B` |
| `score ≥ 0.8` | `scoreHigh` | Emerald `#10B981` |

Never hand-pick score colors — always resolve through `AppColors.forScore` so rings, pills, and HUDs agree.

### Spacing (`app_spacing.dart`) — 4-pt scale

| Token | px | Token | px |
| --- | --- | --- | --- |
| `xxs` | 2 | `xxl` | 24 |
| `xs` | 4 | `sectionGap` | 28 |
| `sm` | 8 | `xxxl` | 32 |
| `md` | 12 | `huge` | 40 |
| `lg` | 16 | `massive` | 56 |
| `xl` | 20 | | |

Presets: `screenPadding` (20 px horizontal) for screen content, `cardPadding` (16 px all sides) for cards and glass panels.

### Radius (`app_radius.dart`)

| Token | px | Use |
| --- | --- | --- |
| `sm` | 10 | Chips, small controls |
| `md` | 14 | Inputs, tiles |
| `lg` | 18 | Buttons |
| `xl` | 24 | Cards, dialogs |
| `xxl` | 32 | Sheets |
| `pill` | 999 | Pills, avatars |

Prebuilt: `brSm`…`brPill` (`BorderRadius`), `cardShape`, `sheetShape` (top-only rounding).

### Shadows (`app_shadows.dart`)

| Token | Character | Use |
| --- | --- | --- |
| `soft` | Low-alpha, 18 blur | Resting cards, tiles |
| `medium` | Two layers, up to 28 blur | Popovers, menus |
| `high` | Two layers, up to 48 blur | Dialogs, sheets |
| `emeraldGlow` | Emerald-tinted halo | Hero buttons, score highlights only |

### Blur sigmas (`app_blur.dart`)

| Token | Sigma | Use |
| --- | --- | --- |
| `soft` | 12 | Subtle frost behind small controls |
| `glass` | 20 | Standard glass cards, bars, sheets |
| `heavy` | 36 | Full-screen veils, modal backgrounds |

Helper: `AppBlur.glassFilter([sigma])` builds the `ImageFilter` for backdrop filters.

### Durations & curves (`app_durations.dart`)

| Token | Value | Use |
| --- | --- | --- |
| `fast` | 150 ms | Taps, toggles, icon swaps |
| `base` | 250 ms | Default transitions |
| `slow` | 400 ms | Sheets, hero moves |
| `splash` | 1600 ms | Splash reveal |
| `shimmer` | 1200 ms | One shimmer sweep |
| `easeOutExpo` | curve | Long deceleration tail |
| `spring` | `easeOutBack` | Pop-in badges |
| `emphasized` | M3 emphasized | Large surface transitions |

### Gradients (`app_gradients.dart`)

| Token | Shape | Use |
| --- | --- | --- |
| `emeraldHero` | Diagonal linear, emerald 400→600 | Hero buttons, highlight cards |
| `darkVeil` | Vertical, transparent→black | Text legibility over photos |
| `glassSheen` | Diagonal faint white | Glass catch-of-light |
| `scoreRing` | Sweep rose→amber→emerald | Circular score dials |
| `backgroundAurora` | Radial faint emerald | Ambient depth behind dark screens |

## Component catalog

All components live in `lib/core/design/` and are exported by the barrel — import once:

```dart
import 'package:posely_ai/core/design/design.dart';
```

### GlassPanel — `glass/glass_panel.dart`

The base frosted surface: backdrop blur, glass fill, hairline stroke, optional sheen.

```dart
GlassPanel(
  padding: AppSpacing.cardPadding,
  blurSigma: AppBlur.glass,
  child: ...,
)
```

- **Do** use it for bars, HUD overlays, and non-tappable surfaces over imagery.
- **Don't** nest glass inside glass — stacked blurs are expensive and muddy.

### GlassCard — `glass/glass_card.dart`

A tappable glass container with pressed feedback.

```dart
GlassCard(
  onTap: () => context.go(...),
  child: ...,
)
```

- **Do** use it for interactive cards over photos or gradients.
- **Don't** use it on plain dark backgrounds where there is nothing to blur — use a solid `surface` card instead.

### PoselyButton — `buttons/posely_button.dart`

Variants `primary | glass | ghost | danger`, sizes `large | medium | small`, plus `icon`, `loading`, and `expand`.

```dart
PoselyButton(
  label: 'Continue',
  onPressed: _submit,
  variant: PoselyButtonVariant.primary,
  size: PoselyButtonSize.large,
  expand: true,
)
```

- **Do** keep exactly one `primary` per screen; disable by passing `onPressed: null`; use `loading` during async work.
- **Don't** use `danger` for anything but destructive actions; don't stack two expanded buttons of equal weight.

### PoselyIconButton — `buttons/posely_icon_button.dart`

Circular glass icon button with an `active` (emerald) state.

```dart
PoselyIconButton(
  icon: Icons.favorite_rounded,
  active: isLiked,
  onPressed: _toggleLike,
  semanticLabel: 'Like',
)
```

- **Do** always pass `semanticLabel` — an icon alone is invisible to screen readers.
- **Don't** shrink `size` below 44 px for primary interactions.

### PoselyChip — `chips/posely_chip.dart`

Selectable filter chip with optional leading icon.

```dart
PoselyChip(
  label: 'Portrait',
  icon: Icons.person_rounded,
  selected: isSelected,
  onTap: _toggle,
)
```

- **Do** use chips for filters and multi-select tags in a `Wrap`.
- **Don't** use a chip as a button — chips represent state, buttons perform actions.

### PoselyTextField — `inputs/posely_text_field.dart`

Branded text input with label, hint, error, obscure, prefix/suffix, and autofill support.

```dart
PoselyTextField(
  label: 'Email',
  hint: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
  errorText: state.emailError,
  onChanged: controller.setEmail,
)
```

- **Do** surface validation through `errorText`; wire `textInputAction` + `onSubmitted` for form flow.
- **Don't** build ad-hoc `TextField`s — every input in the app goes through this component.

### showPoselyBottomSheet — `sheets/posely_bottom_sheet.dart`

Glass modal sheet with grabber and optional title.

```dart
await showPoselyBottomSheet<void>(
  context: context,
  title: 'Choose a pose set',
  builder: (context) => ...,
);
```

- **Do** use sheets for pickers, option lists, and secondary flows; set `isScrollControlled` for tall content.
- **Don't** put blocking decisions in a dismissible sheet — that is a dialog's job.

### showPoselyDialog / showPoselyConfirmDialog — `dialogs/posely_dialog.dart`

Branded alert dialog with icon and action list, plus a boolean confirm helper.

```dart
final ok = await showPoselyConfirmDialog(
  context: context,
  title: 'Discard changes?',
  confirmLabel: 'Discard',
  destructive: true,
);
```

- **Do** keep to two actions; mark the destructive one with `isDestructive`.
- **Don't** use dialogs for success feedback — use a toast.

### PoselyToast — `feedback/posely_toast.dart`

Transient overlay notice, kinds `success | error | info`.

```dart
PoselyToast.show(context, message: 'Pose saved', kind: PoselyToastKind.success);
```

- **Do** keep messages to one short sentence.
- **Don't** attach actions to toasts — if the user must respond, use a snackbar or dialog.

### PoselySnackbar — `feedback/posely_snackbar.dart`

Bottom notice with an optional single action.

```dart
PoselySnackbar.show(
  context,
  message: 'Photo deleted',
  actionLabel: 'Undo',
  onAction: _undo,
);
```

- **Do** use it exactly when a transient message needs one recovery action (undo, retry).
- **Don't** show more than one at a time.

### EmptyState / SuccessState — `states/`

Full-area placeholders with icon, title, message, and optional action; pair with `AppErrorView` and `AppLoadingView` from `core/shared/widgets/` for the four canonical async states.

```dart
EmptyState(
  title: 'No poses yet',
  message: 'Browse the library to get started.',
  action: PoselyButton(label: 'Browse', onPressed: _browse),
)
```

- **Do** always offer a next step via `action` when one exists.
- **Don't** show a bare technical message — write for the user.

### ShimmerBox / PoseCardSkeleton / SkeletonGrid — `skeleton/`

Shimmer placeholders for loading content; `SkeletonGrid` mirrors the pose grid layout.

```dart
SkeletonGrid(itemCount: 6, crossAxisCount: 2, aspectRatio: 3 / 4)
```

- **Do** match skeleton shapes to the real content's layout (same aspect ratio, same grid).
- **Don't** mix skeletons with spinners on the same surface.

### ScoreRing / ScorePill — `score/`

Score visualizations for normalized 0..1 scores, colored via the score thresholds.

```dart
ScoreRing(score: 0.92, size: 104, label: 'Pose match')
ScorePill(label: 'Lighting', score: 0.64)
```

- **Do** pass raw normalized scores — the components resolve color and formatting.
- **Don't** re-map or re-color scores locally.

### SectionHeader — `common/section_header.dart`

Section title row with an optional trailing action.

```dart
SectionHeader(title: 'Trending', actionLabel: 'See all', onAction: _openAll)
```

- **Do** use it above every content rail/section for consistent rhythm (`sectionGap` above it).
- **Don't** use it for the screen title — that is the app bar / `screenTitle` style.

## Feedback patterns

| Situation | Use |
| --- | --- |
| Confirmation of a completed action, no response needed | **Toast** (`success`) |
| Non-blocking failure the user should know about | **Toast** (`error`) |
| Transient message with exactly one recovery action (undo, retry) | **Snackbar** |
| Blocking decision, destructive or irreversible action | **Dialog** (`showPoselyConfirmDialog`) |
| Choosing from options, secondary flows, pickers | **Bottom sheet** |
| Content area failed to load | **AppErrorView** with `onRetry` in place |
| Content area is loading | **Skeletons** (known layout) or **AppLoadingView** (unknown) |
| Content area is legitimately empty | **EmptyState** with a next-step action |

## Accessibility

- **Touch targets:** interactive elements are at least 44×44 px. Small buttons may look compact but keep a 44 px hit area.
- **Semantics:** every icon-only control gets a `semanticLabel`; toasts and snackbars announce politely; score components expose their value as readable text.
- **Reduced motion:** components honor `MediaQuery.disableAnimations` — shimmer, ring sweeps, and pop-ins degrade to static/instant rendering.
- **Contrast:** `textPrimary` on `background` and `textOnPrimary` on emerald fills meet WCAG AA. Never place `textTertiary` on glass over bright imagery without a `darkVeil` behind it.

## Opening the gallery

The gallery is registered in the router for every flavor but linked from nowhere in production UI.

- Route: `/dev/design-gallery` (`RoutePaths.designGallery` / `RouteNames.designGallery`)
- From any dev build: `context.go(RoutePaths.designGallery)` — e.g. temporarily wired to a debug tile or button.
- Future: once the `posely://` deep-link scheme lands, `posely://dev/design-gallery` will open it directly on dev/uat builds.

Screen: `lib/features/settings/presentation/screens/design_gallery_screen.dart`.

## File map — `lib/core/design/`

```
lib/core/design/
├── design.dart                    # Barrel — the only import call sites need
├── glass/
│   ├── glass_panel.dart           # GlassPanel — frosted base surface
│   └── glass_card.dart            # GlassCard — tappable glass container
├── buttons/
│   ├── posely_button.dart         # PoselyButton + variant/size enums
│   └── posely_icon_button.dart    # PoselyIconButton — circular icon button
├── chips/
│   └── posely_chip.dart           # PoselyChip — selectable filter chip
├── inputs/
│   └── posely_text_field.dart     # PoselyTextField — branded text input
├── sheets/
│   └── posely_bottom_sheet.dart   # showPoselyBottomSheet
├── dialogs/
│   └── posely_dialog.dart         # showPoselyDialog / showPoselyConfirmDialog
├── feedback/
│   ├── posely_toast.dart          # PoselyToast overlay notices
│   └── posely_snackbar.dart       # PoselySnackbar with optional action
├── states/
│   ├── empty_state.dart           # EmptyState placeholder
│   └── success_state.dart         # SuccessState placeholder
├── skeleton/
│   ├── shimmer_box.dart           # ShimmerBox primitive
│   ├── pose_card_skeleton.dart    # PoseCardSkeleton — pose card shape
│   └── skeleton_grid.dart         # SkeletonGrid — grid of pose skeletons
├── score/
│   ├── score_ring.dart            # ScoreRing — animated circular score
│   └── score_pill.dart            # ScorePill — compact labeled score
└── common/
    └── section_header.dart        # SectionHeader — title + optional action
```
