# Phase 7: Upload Photo → Pose Extraction Plan

## 🛑 Phase 0: Socratic Gate & Clarifications (User Review Required)

> [!IMPORTANT]
> The `HANDOFF.md` specifies that the `ExtractionRepository` should handle "status polling" for extraction. However, the `API_CONTRACTS.md` states that `POST /ai/extract-pose` returns a `200` with the extracted pose object directly (unlike `POST /ai/generate-poses` which returns a 202 with a job).
> 
> **Question 1:** Should we treat `POST /ai/extract-pose` as a synchronous API call (awaiting the response), or should we implement a polling mechanism (e.g., if the backend was updated to return a Job ID for extraction)?
> 
> **Question 2:** For the UI image picker, do we have a preferred cropping library (e.g., `image_cropper`), or should we rely on basic `image_picker` functionality and handle the 10MB guard manually?

## Project Overview

- **Task:** Implement Phase 7 (Upload Photo → Pose Extraction)
- **Project Type:** MOBILE (Flutter)
- **Success Criteria:** 
  - Users can select a photo from their gallery.
  - The photo is guarded against the 10MB limit.
  - Multipart upload to `POST /ai/extract-pose` with `Idempotency-Key`.
  - The extracted pose is displayed as an overlay.
  - Graceful handling of `422` (no_pose_detected) errors.

## Tech Stack & Architecture

- **Data Models:** `ExtractionState` (client-side state machine: idle, picking, uploading, extracting, success, error) or `ExtractionJob` if polling is required.
- **Packages:** `image_picker`, `dio` (for FormData multipart).
- **Architecture:** 
  - **Domain:** `ExtractionState`, `ExtractPoseUseCase`
  - **Data:** `ExtractionDatasource` (multipart upload), `ExtractionRepositoryImpl`
  - **Presentation:** `UploadPoseScreen`, `UploadPoseController`

## Task Breakdown

### Task 1: Domain & Data Models
- **Agent:** `mobile-developer`
- **Input:** `API_CONTRACTS.md`
- **Output:** `ExtractionState` freezed class to handle the UI state machine, and `ExtractPoseUseCase`.
- **Verify:** `flutter test` for state transitions.

### Task 2: ExtractionRepository & Datasource
- **Agent:** `mobile-developer`
- **Input:** `dio` multipart config, `AppException.fromDio`
- **Output:** `ExtractionApiDatasource` with `Idempotency-Key` logic and 10MB check. `ExtractionRepositoryImpl` to wrap the API in `ApiResult`.
- **Verify:** Unit tests mocking Dio to return 200 (Success) and 422 (no_pose_detected).

### Task 3: UploadPoseController
- **Agent:** `mobile-developer`
- **Input:** `ExtractPoseUseCase`
- **Output:** AsyncNotifier to manage the state flow (picking -> cropping -> uploading -> success).
- **Verify:** Unit tests validating the controller transitions correctly on success/failure.

### Task 4: UploadPoseScreen (UI)
- **Agent:** `mobile-developer`
- **Input:** `image_picker`, Core Design Tokens
- **Output:** Glassmorphism UI for photo selection, a loading state during extraction, and error handling toasts/dialogs.
- **Verify:** Visual check + widget tests for empty, loading, and error states.

## Phase X: Verification Checklist
- [ ] `flutter analyze` returns 0 issues.
- [ ] `flutter test` passes all tests (including new repository/controller tests).
- [ ] No strict-cast or strict-inference violations.
- [ ] Socratic Gate questions answered before proceeding.
