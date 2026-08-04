# Project Plan: Phase 9 (Realtime Matching & AI Coach)

## UI/UX Design System Guidelines (ui-ux-pro-max)

Based on the `ui-ux-pro-max` search for "Realtime AI Coach Matching":

*   **Pattern:** Feature-Rich + Conversion
    *   **CTA:** Above the fold
    *   **Sections:** Hero, Features, CTA
*   **Style:** Flat Design
    *   **Keywords:** 2D, minimalist, bold colors, no shadows, clean lines, simple shapes, typography-focused, modern, icon-heavy.
*   **Colors:**
    *   Primary: `#2563EB`
    *   Secondary: `#3B82F6`
    *   CTA: `#F97316`
    *   Background: `#F8FAFC`
    *   Text: `#1E293B`
*   **Typography:** Inter / Inter (Clear + Professional typography)
*   **Key Effects:** No gradients/shadows, simple hover (color/opacity shift), fast loading, clean transitions (150-200ms ease), minimal icons.
*   **Avoid (Anti-patterns):** Poor profiles + No reviews.

## Task Breakdown

1.  **UI/UX Implementation (Realtime Matching Interfaces)**
    *   Apply the Flat Design System: configure Tailwind (or equivalent framework) with the exact color palette, typography (`Inter`), and transition rules.
    *   Create the **Hero Section** with clear messaging about the AI Coach matching.
    *   Create the **Features Section** detailing how the matching works.
    *   Create the **CTA Section** (placed above the fold) using the designated CTA color `#F97316`.
    *   Design AI Coach profile cards. *Crucial:* Ensure profiles are rich and contain visible reviews/ratings to avoid identified anti-patterns.

2.  **Matching Engine (Backend)**
    *   Implement real-time matching logic via WebSockets or SSE for connecting users to their personalized AI fitness coach.
    *   Develop the AI Coach profile retrieval system including robust data and historical reviews.

3.  **Frontend Integration**
    *   Connect the UI components to the real-time matching API.
    *   Ensure all interactive elements follow accessibility and interaction design guidelines (e.g., fast loading, minimal SVGs, simple hovers).

## Agent Assignments

*   **Frontend / UI Developer Agent:** Responsible for Task 1 and Task 3. Will implement the Flat Design System, set up components (Hero, Features, CTA, Coach Profiles), and wire up the UI to real-time events.
*   **Backend / System Developer Agent:** Responsible for Task 2. Will build the real-time matching API, WebSocket connections, and coach profile database layer.
*   **QA / Tester Agent:** Responsible for running through the Verification Checklist, testing for accessibility, responsiveness, and real-time synchronization.

## Verification Checklist (Pre-delivery)

- [ ] No emojis as icons (use SVG: Heroicons/Lucide).
- [ ] `cursor-pointer` on all clickable elements.
- [ ] Hover states with smooth transitions (150-300ms).
- [ ] Light mode: text contrast 4.5:1 minimum.
- [ ] Focus states visible for keyboard nav.
- [ ] `prefers-reduced-motion` respected.
- [ ] Responsive design verified at: 375px, 768px, 1024px, 1440px.
- [ ] Coach profiles display complete information and reviews (no poor profiles).
- [ ] Main CTA is visible above the fold.
