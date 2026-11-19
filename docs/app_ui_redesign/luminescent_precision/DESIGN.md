---
name: Luminescent Precision
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1c1b1e'
  surface-container: '#201f22'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e5e1e4'
  on-surface-variant: '#bbcabf'
  inverse-surface: '#e5e1e4'
  inverse-on-surface: '#313032'
  outline: '#86948a'
  outline-variant: '#3c4a42'
  surface-tint: '#4edea3'
  primary: '#4edea3'
  on-primary: '#003824'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#006c49'
  secondary: '#d0bcff'
  on-secondary: '#3c0091'
  secondary-container: '#571bc1'
  on-secondary-container: '#c4abff'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#e29100'
  on-tertiary-container: '#523200'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d0bcff'
  on-secondary-fixed: '#23005c'
  on-secondary-fixed-variant: '#5516be'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.03em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.025em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 12px
    letterSpacing: 0.04em
  numeral-lg:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.03em
  numeral-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.02em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system expresses a disciplined, ultra-refined aesthetic engineered for focused daily progress. Crafted around absolute deep black OLED foundations, the interface merges high-contrast minimalism with razor-sharp emissive accents. It evokes quiet mastery, personal agency, and calm visual focus.

The visual direction combines pristine dark mode ergonomics with subtle physical luminosity:
- **True OLED Canvas**: Deep black foundational layers eliminate visual distraction, conserve battery on mobile OLED displays, and establish an infinite depth plane.
- **Micro-Luminescence**: Functional semantic states emit controlled, tight atmospheric glows rather than broad diffuse shadows, transforming completion actions into rewarding tactile milestones.
- **Architectural Restraint**: Information architecture favors generous breathing room, hairline demarcation, and geometric rhythm over heavy surfaces or decorative clutter.

## Colors

The palette relies on a stark value contrast between an abyssal neutral architecture and electric, saturated status signals.

### Palette Architecture
- **Pitch Neutral Canvas (`#000000` to `#08080A`)**: Grounding baseline that enables true pixel shutoff across mobile displays.
- **Elevated Surfaces**:
  - Base Container: `#121316` (used for inactive module cards and grid blocks).
  - Active / Floating Container: `#18191E` (used for interactive cards, menus, and bottom sheets).
- **Hairline Demarcation**: `rgba(255, 255, 255, 0.08)` produces precise structural borders without increasing visual weight.
- **Luminescent Accents**:
  - **Emerald (`#10B981`)**: Primary habitual completion, positive streaks, active momentum.
  - **Electric Violet (`#8B5CF6`)**: Secondary milestones, identity rituals, long-term analytics.
  - **Energetic Amber (`#F59E0B`)**: Warnings, pending items, streak preservation, time-sensitive alerts.
  - **Sleek Coral (`#F43F5E`)**: Missed logs, destructive actions, high-friction habit breaks.
- **Text & Foreground**:
  - High-emphasis: `#FFFFFF` (100% white for titles, numerical targets, active tallies).
  - Medium-emphasis: `rgba(255, 255, 255, 0.65)` for secondary copy and contextual units.
  - Low-emphasis / Muted: `rgba(255, 255, 255, 0.38)` for axis markers, inactive dots, and dividers.

## Typography

Typography delivers surgical clarity and dense numerical scanning:
- **Tight Kerning**: Headlines and numbers utilize negative tracking to feel cohesive, solid, and modern.
- **Tabular Figures**: All data displays, timers, streak counters, and heatmaps must enable tabular numbers (`font-variant-numeric: tabular-nums;`) to prevent layout shift during state changes.
- **Hierarchical Discipline**: Reserve high-contrast pure white exclusively for titles and dynamic metrics. Subtitles, metadata, and timestamps drop to muted opacities to preserve visual hierarchy.

## Layout & Spacing

The layout is built mobile-first, prioritizing one-handed thumb interaction along the lower screen half:
- **Grid Architecture**: Mobile screens use a 4-column layout with `1rem` margins and `0.75rem` gutters. Tablet and wider viewports adapt to an 8-column layout capped at `640px` max-width to maintain the focused mobile-app ergonomics.
- **Vertical Rhythm**: Layout gaps follow an exact 4px/8px modular scale. Card-to-card stack spacing defaults to `space-md` (`16px`). Sectional divisions adhere to `space-lg` (`24px`).
- **Ergonomic Safe Zones**: Fixed navigation, creation triggers, and primary progress selectors reside within the bottom 120px of the viewport, with `env(safe-area-inset-bottom)` applied.

## Elevation & Depth

Visual hierarchy uses tonal surface layering, hairline borders, and micro-luminescence instead of traditional cast shadows:
- **Baseline Layer**: Ground viewport background `#000000`.
- **Card Level 1 (Base Container)**: `#121316` bounded by a 1px border of `rgba(255, 255, 255, 0.08)`. No drop shadow.
- **Card Level 2 (Elevated / Active)**: `#18191E` with a 1px border of `rgba(255, 255, 255, 0.12)`.
- **Micro-Glow Tokens**:
  - `glow-emerald`: `0px 0px 16px rgba(16, 185, 129, 0.28), 0px 0px 4px rgba(16, 185, 129, 0.5)`
  - `glow-violet`: `0px 0px 16px rgba(139, 92, 246, 0.28), 0px 0px 4px rgba(139, 92, 246, 0.5)`
  - `glow-amber`: `0px 0px 16px rgba(245, 158, 11, 0.28), 0px 0px 4px rgba(245, 158, 11, 0.5)`
- **Backdrop Diffusion**: Modal sheets and bottom floating navigation use `#08080A` with 80% opacity and a `20px` background blur (`backdrop-filter: blur(20px)`).

## Shapes

The geometry balances smooth curved containers with tight internal indicators:
- **Structural Cards**: `20px` to `24px` corner radii produce an organic silhouette against the dark viewport. Large modal sheets expand to `28px` top radius.
- **Controls & Buttons**: Pill-shaped (`9999px`) styling governs interactive triggers, active filters, and completion buttons.
- **Heatmap & Dot Grids**: Daily matrix dots use `rounded-sm` (`4px` to `6px`) or perfect circles (`50%`), maintaining geometric balance in tight data matrices.

## Components

### Buttons & Quick Actions
- **Primary Pill**: Background `#10B981`, label `#000000` (weight 600), fully rounded (`rounded-full`), height `52px`. On press/active: triggers `glow-emerald` and subtle scale compression (`scale(0.98)`).
- **Secondary / Ghost Pill**: Background `rgba(255, 255, 255, 0.06)`, border `1px solid rgba(255, 255, 255, 0.08)`, label `#FFFFFF`. Hover/Focus increases border to `rgba(255, 255, 255, 0.16)`.
- **Floating Action Pill**: Positioned bottom-center, floating above content with a blurred `#18191E` background, vibrant emerald icon, and hairline white stroke.

### Habit Cards & Status Rows
- **Surface**: `#121316` fill, `20px` corner radius, `1px solid rgba(255, 255, 255, 0.08)`.
- **Structure**: Left side hosts an icon encapsulated in a rounded squircle with muted tint; center holds the habit title and current streak; right side holds a tactile completion control.
- **Completed State**: Card background shifts slightly to `rgba(16, 185, 129, 0.05)`, and the outer border transitions to `rgba(16, 185, 129, 0.3)`.

### Completion Triggers (Checkboxes & Toggles)
- Custom circular action ring (`36px × 36px` touch-target enlarged to `48px`).
- **Unchecked**: Outer ring `2px solid rgba(255, 255, 255, 0.2)`, center empty `#000000`.
- **Checked**: Spring-animated fill with `#10B981`, white crisp check icon, emitting instant `glow-emerald`.

### Heatmaps & Dot Matrices
- **Grid Layout**: 7 rows (days of week) by multi-column horizontal scroll.
- **Cell Size**: `12px × 12px` squares with `3px` corner radius and `3px` gap.
- **Levels**:
  - Level 0 (Empty): `#18191E`
  - Level 1: `rgba(16, 185, 129, 0.25)`
  - Level 2: `rgba(16, 185, 129, 0.5)`
  - Level 3: `rgba(16, 185, 129, 0.75)`
  - Level 4 (Goal Hit): `#10B981` with localized micro-glow.

### Input Fields
- Container height `50px`, pill-shaped or `16px` rounded corners, fill `#121316`, border `1px solid rgba(255, 255, 255, 0.08)`.
- Text color `#FFFFFF`, placeholder `rgba(255, 255, 255, 0.3)`.
- Focus state: Border transitions to `#10B981` with an inner glow highlight.

### Chips & Filters
- Compact `32px` height, fully rounded pill.
- Inactive: `#121316` fill, `rgba(255, 255, 255, 0.6)` text.
- Active: Tinted accent background (e.g., `rgba(139, 92, 246, 0.15)`), accent border `1px solid #8B5CF6`, accent text `#8B5CF6`.