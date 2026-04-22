---
name: starnyx-flutter-design
description: Design and implement polished Flutter mobile interfaces for StarNyx. Use this skill when the user asks to create, restyle, or refine screens, widgets, themes, bottom sheets, onboarding, empty states, motion, or other presentation-layer UI in this Flutter app. Focus on production-ready Dart and Flutter code, cosmic-minimal aesthetics, reusable theme tokens, and mobile-first interaction instead of web CSS or React patterns.
---

This skill translates UI requests into Flutter code that matches StarNyx's approved visual language instead of default Material styling or web-oriented frontend patterns.

## Start Here

Before coding, load only the files relevant to the current task:

- `docs/ui/starnyx_visual_baseline.md`
- The matching mockup image from `docs/ui/` if one exists
- `lib/app/theme/app_theme.dart`
- `lib/core/constants/app_colors.dart`
- `lib/core/constants/app_spacing.dart`
- `lib/core/constants/app_radius.dart`
- `lib/core/constants/app_layout.dart`
- Shared visual widgets in `lib/core/widgets/`
- The target screen or widget file you are changing

If the task touches a flow that does not exist yet, inspect the closest screen and extend the same design language.

## Design Intent

Keep every design decision inside the StarNyx product tone:

- Cosmic minimalism, not generic sci-fi noise
- Dark atmospheric backgrounds with restrained gradient light
- Spacious layouts with clear hierarchy and large radii
- Material as interaction shell, not as the visible design language
- Privacy-first, calm, personal, and reflective rather than loud or gamified

Each screen should have one memorable visual move. Examples: a strong hero composition, a distinctive sheet treatment, a refined constellation card, or a carefully staged entrance animation. Do not stack multiple competing ideas.

## Flutter-First Rules

- Solve UI in Flutter terms: `ThemeData`, design tokens, composition, `BoxDecoration`, gradients, custom painting, and reusable widgets
- Do not think in web primitives such as CSS utilities, hover-first interaction, or DOM layout tricks
- Prefer existing shared tokens and widgets before introducing new ones
- If new colors, spacing, radii, or shadows are needed repeatedly, add them to shared constants instead of hardcoding them in one screen
- Keep business logic out of visual widgets; UI belongs in the presentation layer
- Avoid adding dependencies unless they clearly unlock a meaningful UI capability that Flutter cannot cover cleanly

## Visual Guardrails

- Preserve the approved palette direction from `app_colors.dart`; evolve it carefully instead of replacing it wholesale
- Avoid default Material cards, default buttons, and stock settings-list styling
- Avoid overusing blur, glow, gradients, and opacity stacks; cosmic does not mean visually noisy
- Avoid generic "AI app" aesthetics such as purple-on-black everything, random glassmorphism, or interchangeable dashboard layouts
- Typography should feel intentional through scale, spacing, and weight even if the app stays on system fonts for now
- Icons, dividers, and outlines should stay subtle; key actions and key data should carry the contrast

## Mobile Quality Bar

Every implementation should be checked against mobile constraints:

- Works on small phones without clipped content
- Respects `SafeArea` and gesture/navigation insets
- Handles keyboard appearance where inputs exist
- Uses comfortable tap targets and thumb-friendly primary actions
- Scrolls when content can exceed viewport height
- Maintains readable contrast and hierarchy in dark mode
- Keeps animation smooth and avoids heavy repaint paths

## Motion Guidance

- Prefer restrained, meaningful motion over constant ambient animation
- Start with implicit animations such as `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSlide`, and `TweenAnimationBuilder`
- Use explicit controllers only when choreography genuinely needs it
- Keep durations short and calm; motion should support clarity, not distract from content
- Reuse or extend existing cosmic background and starfield effects before inventing new animated layers

## Implementation Workflow

1. Identify the user goal, the target screen, and the UI state being changed
2. Choose a clear aesthetic direction within the existing StarNyx visual baseline
3. Decide whether the change belongs in shared tokens, shared widgets, or only the target screen
4. Implement the layout and styling in Flutter with reusable building blocks
5. Check empty, loading, error, and populated states if the screen supports them
6. Validate with project analysis or tests when feasible

When summarizing the work, briefly state the chosen visual direction and mention any shared tokens or reusable widgets that were added.

## Where Changes Usually Belong

- Global palette, text, field, card, and sheet behavior: `lib/app/theme/` and `lib/core/constants/`
- Reusable visual patterns: `lib/core/widgets/`
- Screen-specific layout and composition: feature presentation files
- One-off decorative painting: a tightly scoped widget or painter near the affected screen

## Avoid

- Converting the app into a generic Material 3 sample
- Copying web landing-page aesthetics into a mobile flow
- Introducing large visual refactors without checking existing mockups and baseline docs
- Hardcoding repeated magic numbers across multiple files
- Mixing product design work with repository, use case, bloc, or database changes unless the task explicitly needs both
