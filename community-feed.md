# Project Plan: Phase 11 (Community)

## Overview
Develop the community features for Posemate, including a paginated infinite-scroll social feed at `/community/feed`, sharing of poses/captures, likes, comments, and follow/unfollow functionality with optimistic updates. Implement reporting, blocking, and moderation hooks essential for App Store approval of User-Generated Content (UGC) applications.

## UI/UX Design System Recommendations
Based on the `ui-ux-pro-max` guidelines for a "Community social feed dark mode premium UI":

### Pattern: Community/Forum Landing
- **Conversion:** Show active community (member count, posts today). Highlight benefits. Preview content. Easy onboarding.
- **CTA:** Join button prominent + After member showcase
- **Sections:**
  1. Hero (community value prop)
  2. Popular topics/categories
  3. Active members showcase
  4. Join CTA

### Style: Vibrant & Block-based
- **Keywords:** Bold, energetic, playful, block layout, geometric shapes, high color contrast, duotone, modern
- **Performance:** Good
- **Accessibility:** Ensure WCAG compliance

### Colors (Dark Mode Premium adaptation implied, though output showed light variants, adjust for dark mode retaining vibrancy)
- **Primary:** `#7C3AED` (Community purple)
- **Secondary:** `#A78BFA`
- **CTA:** `#22C55E` (Join green)
- **Text/Background:** Adjust to dark equivalents while keeping high contrast for premium feel.

### Typography: Satoshi / General Sans (or DM Sans fallback)
- **Mood:** Premium, modern, clean, sophisticated, versatile, balanced.

### Key Effects
- Large sections (48px+ gaps), animated patterns, bold hover (color shift), scroll-snap, large type (32px+), 200-300ms transitions.

### Anti-patterns to Avoid
- Flat design without depth
- Text-heavy pages

## Task Breakdown

### 1. Database & Schema Updates
- [ ] Define schemas for Posts (Feed Items), Likes, Comments.
- [ ] Define schemas for Followers/Following relationships.
- [ ] Define schemas for Moderation (Reports, Blocks, Hidden Content).
- [ ] Create necessary indexes for efficient querying of feeds and relationships.

### 2. Backend Services & APIs (Node.js/Express or similar)
- [ ] Create API for `/community/feed` with `Paginated<T>` cursor-based infinite scroll.
- [ ] Create APIs for creating, deleting, and fetching posts (sharing poses/captures).
- [ ] Create APIs for Likes (toggle like/unlike) and Comments (CRUD).
- [ ] Create APIs for Follow/Unfollow users.
- [ ] Create APIs for User Moderation (Report user/post, Block user) to comply with UGC guidelines.

### 3. Frontend Feed & Interaction (React/Flutter/Next.js)
- [ ] Implement Infinite Scroll Feed component using the design system guidelines (Block-based, vibrant).
- [ ] Implement Post Component (displaying pose/capture data).
- [ ] Implement Optimistic Updates for Likes and Follow/Unfollow actions to ensure a premium, snappy feel.
- [ ] Implement Commenting interface with smooth animations (200-300ms transitions).

### 4. Moderation Tools (UGC Compliance)
- [ ] Add "Report Post" and "Report User" flows in the UI.
- [ ] Add "Block User" functionality in the UI.
- [ ] Filter out blocked users' content and reported content from the feed locally and via API.
- [ ] (Optional Admin) Basic dashboard or logging for reviewing reported content.

## Agent Assignments

- **Backend/Data Agent:** 
  - Database schema migrations.
  - Implement feed pagination API, engagement APIs (likes, comments, follows).
  - Implement moderation APIs (report, block).
- **Frontend/UI Agent:** 
  - Build UI components following the vibrant, block-based premium design system.
  - Implement infinite scroll, optimistic updates for likes/follows.
  - Implement moderation UI (report/block dialogs).
- **QA/Review Agent:** 
  - Verify all functional requirements, especially optimistic UI states and pagination logic.
  - Ensure Apple App Store UGC compliance (blocking and reporting works effectively).

## Verification Checklist
- [ ] `/community/feed` loads with `Paginated<T>` cursor-based infinite scroll.
- [ ] Users can successfully share a pose/capture to the feed.
- [ ] Users can like/unlike posts, with the UI updating instantly (Optimistic UI).
- [ ] Users can add, view, and delete comments on posts.
- [ ] Users can follow/unfollow other members, with the UI updating instantly.
- [ ] A user can report inappropriate content/posts (UGC requirement).
- [ ] A user can block another user, immediately hiding their content from the feed (UGC requirement).
- [ ] The UI adheres to the Vibrant & Block-based design style with specified fonts and transitions.
- [ ] No emojis as icons (use SVGs like Heroicons/Lucide).
- [ ] All clickable elements have `cursor-pointer` and smooth hover states.
- [ ] Accessible focus states and respects `prefers-reduced-motion`.
