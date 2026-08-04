# Posely AI UI/UX Redesign Plan (Dark Mode & Premium Minimalist)

## 🛑 Phase 0: Socratic Gate & Clarifications (User Review Required)

> [!IMPORTANT]
> The interface is currently considered "too bright". To ensure the new design perfectly matches your vision, please clarify:
> 
> 1. **True Dark vs. Dim Light:** Do we want to switch the default app theme entirely to a **True Dark Mode** (e.g., deep charcoal `#121212` or pure black `#000000` backgrounds), or just make the current "Light Mode" significantly darker/greyer?
> 2. **Accent Color:** Currently we use Blue (`#007AFF`). Do you want to keep this, or switch to a more vibrant accent (like neon orange or green) that pops better against a true dark background?
> 3. **Cards & Depth:** In a dark theme, should we use flat subtle borders (minimalist) or maintain glassmorphism (frosted glass overlays) for depth?

## Project Overview

- **Goal:** Redesign all screens of the Posely AI app to be darker, cleaner, and more premium, addressing the feedback that screens are currently too bright.
- **Project Type:** MOBILE (Flutter)
- **Primary Agent:** `mobile-developer`
- **Success Criteria:**
  - Backgrounds are deep and easy on the eyes.
  - Text contrast meets WCAG AA standards (4.5:1).
  - Premium aesthetic is achieved (minimalist layouts, generous padding, subtle depth).

## Tech Stack & Design System (Based on UI/UX Pro Max)

- **Platform:** Flutter
- **Theme Mode:** Forced Dark or Deep Dark implementation.
- **Typography:** Retain existing clean geometric sans-serif (Inter/SF Pro) but optimize font weights for dark backgrounds (slightly lighter weights to prevent glare).
- **Color Palette (Proposed Dark Premium):**
  - Background: `#0F172A` (Slate 900) or `#000000` (OLED Black)
  - Surface (Cards): `#1E293B` (Slate 800)
  - Primary Accent: `#3B82F6` (Blue 500) or user preference.
  - Text Primary: `#F8FAFC` (Slate 50)
  - Text Secondary: `#94A3B8` (Slate 400)

## Task Breakdown

### Task 1: Redefine App Theme Tokens (Colors, Shadows, Gradients)
- **Agent:** `mobile-developer`
- **Skills:** `mobile-design`, `ui-ux-pro-max`
- **Input:** Current `app_colors.dart`, `app_shadows.dart`, `app_gradients.dart`
- **Output:** Deep dark hex codes applied to core tokens. Removal of bright aurora effects in favor of subtle radial glows.
- **Verify:** Run `flutter run` and check the visual output of the design gallery/home screen.

### Task 2: Refactor Home Screen & Pose Rail
- **Agent:** `mobile-developer`
- **Input:** `home_screen.dart`, `pose_rail.dart`
- **Output:** Dark backgrounds applied, text colors contrast-checked, empty states look premium.
- **Verify:** No hardcoded light colors remain. `flutter test` passes.

### Task 3: Refactor Search Screen & Cards
- **Agent:** `mobile-developer`
- **Input:** `pose_search_screen.dart`, `pose_card.dart`
- **Output:** Search inputs, suggestion chips, and bento grid cards updated to dark theme specifications.
- **Verify:** UI aligns with premium minimalist constraints.

### Task 4: Refactor Detail Screen & Pose Extraction UI
- **Agent:** `mobile-developer`
- **Input:** `pose_detail_screen.dart`, etc.
- **Output:** Video/Image containers blend seamlessly with the dark background. Analytics/scores use high contrast.
- **Verify:** Visual check of the detailed view.

### Task 5: Refactor Auth Screens & Settings
- **Agent:** `mobile-developer`
- **Input:** `login_screen.dart`, `register_screen.dart`, `design_gallery_screen.dart`
- **Output:** Dark theme applied to text fields, social buttons, and typography.
- **Verify:** App starts in dark mode perfectly from the splash screen onwards.

## Phase X: Verification Checklist

- [ ] **Contrast Audit:** Verify all text against backgrounds (min 4.5:1).
- [ ] **Static Analysis:** `flutter analyze` returns 0 issues.
- [ ] **Tests:** `flutter test` passes (all 291+ tests).
- [ ] **No Hardcoded Values:** Ensure no stray `#FFFFFF` or light colors are hardcoded in widget files.
- [ ] **Socratic Gate:** User questions answered before coding starts.
