# Phase 10: Gallery Feature Plan

## Task Breakdown

### 1. Data Layer (Models & Local Storage)
- **Model**: Create `CaptureRecord` entity (using `freezed` and `json_serializable`) with fields: `id`, `localPath`, `remoteUrl`, `poseId`, `score`, `timestamp`, `isSynced`.
- **Local Database**: Configure `hive_ce` box for storing `CaptureRecord` entries. Implement `CaptureLocalDataSource` for CRUD operations.
- **API Client**: Define `GalleryApiClient` using `retrofit` for `/gallery/photos` endpoints (sync, upload, fetch).
- **Repository**: Implement `GalleryRepository` to coordinate local metadata with remote sync status.

### 2. State Management (Riverpod)
- Create a `GalleryNotifier` to manage the list of captures.
- Implement states for: loading, empty, populated, and syncing.
- Add methods for deleting captures and triggering background syncs.

### 3. UI/UX: Gallery Grid (Dark Mode Premium)
- **Styling Guidelines** (Based on Liquid Glass Design System):
  - **Colors**: Primary Background `#18181B`, Secondary `#27272A`, Text/CTA `#F8FAFC`.
  - **Typography**: Clean sans-serif (match existing `Inter` or introduce `Satoshi`).
  - **Effects**: Liquid Glass style — translucent overlays using `BackdropFilter` for dynamic blur, and smooth fluid animations (400-600ms curves).
- **Component**: Build `GalleryScreen` featuring a masonry grid of local captures.
- **Routing**: Update `app_router.dart` (`RoutePaths.gallery`) to replace `ComingSoonScreen` with `GalleryScreen`.

### 4. UI/UX: Detail & Compare Viewer
- Build `CaptureDetailScreen` with Hero animations from the grid.
- **Compare View**: Implement a toggleable view (side-by-side or slider overlay) comparing the user's captured photo against the original pose template.
- **Interactions**: Fluid transitions and liquid glass UI elements for the bottom action bar.

### 5. Actions: Share & Organize
- Integrate `share_plus` to allow sharing the captured image directly from the detail screen.
- Implement delete/organize functions that remove the file locally and update the Hive index.

## Agent Assignments

- **Backend/Data Agent**:
  - Setup `CaptureRecord` freezed model and Hive adapters.
  - Implement `GalleryApiClient` (Retrofit) and `GalleryRepository`.
- **Flutter UI Agent**:
  - Build `GalleryScreen` (Masonry Grid) and `CaptureDetailScreen`.
  - Apply the Dark Mode Premium (Liquid Glass) design system.
  - Integrate `share_plus`, Hero animations, and Riverpod state.

## Verification Checklist

- [ ] `CaptureRecord` Hive box successfully reads and writes local metadata.
- [ ] `/gallery/photos` endpoints are defined in Retrofit client.
- [ ] `GalleryScreen` displays captures in a masonry grid using `#18181B` background.
- [ ] `CaptureDetailScreen` provides a working "Compare with Template" visual overlay.
- [ ] `share_plus` successfully shares the local photo via the native share sheet.
- [ ] The `ComingSoonScreen` for the Gallery tab is completely replaced.
- [ ] Fluid animations (400-600ms) and dynamic blur effects are present in the UI.
