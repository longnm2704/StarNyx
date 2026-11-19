---
name: Obsidian Lumina
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1c1b1d'
  surface-container: '#201f21'
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
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
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
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
typography:
  headline-xl:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is engineered for mindful daily rituals, self-reflection, and continuous progress tracking. Built around an ultra-deep OLED aesthetic, it evokes quiet focus, precision, and nocturnal clarity. The emotional atmosphere mirrors an elite physical journal wrapped in matte dark stone, illuminated only by luminous status indicators.

The design philosophy combines **Minimalism** with **Tonal OLED Layering**:
- Uncluttered compositions prioritize micro-interactions, streak momentum, and personal notes without visual noise.
- Pure black negative space anchors the interface, preserving battery life and reducing cognitive load during morning check-ins and late-night journal sessions.
- Jewel-toned indicators (emerald, cyan, amber) are applied with surgical discipline, serving as bioluminescent rewards that mark completed commitments.

## Colors

The color palette operates on high-contrast nocturnal mechanics:

- **Surface Tiers**:
  - `Base Canvas`: Pure True Black (`#000000`) for absolute contrast and true OLED pixel deactivation.
  - `Surface Level 1`: Deep Obsidian (`#0A0A0C`) for underlying containers and modular layout tracks.
  - `Surface Level 2`: Midnight Slate (`#121215`) for elevated cards, active list items, and modal sheets.
  - `Surface Level 3`: Elevated Obsidian (`#1A1A1F`) for interactive state changes, active tabs, and input focus surfaces.

- **Hairline Outlines**:
  - `Border Subtle`: `rgba(255, 255, 255, 0.08)` for container boundaries and dividers.
  - `Border Focus`: `rgba(255, 255, 255, 0.18)` for interactive hover and focus rings.

- **Luminous Accents**:
  - `Primary Emerald` (`#10B981`): Habit completion, streak retention, and positive affirmation.
  - `Secondary Electric Cyan` (`#06B6D4`): Routine management, analytics, time tracking, and mental clarity markers.
  - `Tertiary Warm Amber` (`#F59E0B`): Journaling highlights, milestones, attention alerts, and evening reflection badges.

- **Typography & Monochrome Scales**:
  - `Text Primary`: `#F9FAFB` (High-contrast, glare-free off-white).
  - `Text Secondary`: `#9CA3AF` (Muted information, timestamps, and metric units).
  - `Text Tertiary / Disabled`: `#4B5563` (Inactive day markers, empty states).

## Typography

Typography balances geometric character with optimal reading ergonomics:

- **Space Grotesk** powers primary headlines, metrics, and milestone counters. Its subtle technical quirks reinforce precision tracking and modern aesthetics.
- **Plus Jakarta Sans** delivers optimal legibility for habit titles, journal entries, and contextual copy. Its open apertures ensure effortless scanning even on low-brightness OLED displays.
- **JetBrains Mono** handles time logs, streaks, completion counts, dates, and micro-labels. The monospaced cadence anchors numerical habit data uniformly across repeating lists.

## Layout & Spacing

The layout philosophy uses a **fluid-grid mobile-first architecture** designed for thumb-driven one-handed reachability:

- **Grid Alignment**: Mobile screens leverage a 4-column fluid layout with `1rem` (16px) margins and gutters. Desktop/Tablet expands to 8 and 12 columns with max layout bounds constrained to `680px` for focused habit entries and journals.
- **Touch Targets**: All actionable targets (habit checkboxes, date steppers, action pills) maintain a strict minimum bounding box of 44x44px.
- **Rhythm & Structure**: Component padding uses `space-md` (16px) for standard cards and `space-lg` (24px) for journal text areas. Vertical rhythm between modular card sections relies on `space-md` to preserve high visual density without crowding.

## Elevation & Depth

This design system rejects heavy Drop Shadows in favor of **Tonal Layering and Hairline Outlines**:

- **True OLED Tiering**: Visual hierarchy is created strictly through background lightness stepping:
  - Base Screen: `#000000`
  - Nested Cards: `#0A0A0C`
  - Interactive Action Rows: `#121215`
  - Modals & Floating Bottom Sheets: `#16161A`
- **Hairlines**: Every elevated card and floating component utilizes a 1px border colored `rgba(255, 255, 255, 0.08)`. This creates crisp separation on deep black panels without high visual glare.
- **Bioluminescent Glow**: When habits complete or streaks hit milestones, elements cast a subtle, focused glow using low-opacity accent illumination (`box-shadow: 0 0 24px rgba(16, 185, 129, 0.15)` for emerald, and `0 0 24px rgba(6, 182, 212, 0.15)` for cyan).

## Shapes

The design system enforces a **pill-shaped, tactile curve standard** (Level 3):
- Interactive buttons, filter pills, day-of-week toggles, and status badges use complete pill roundness (`border-radius: 9999px`).
- Habit cards, journal containers, and bottom sheets adopt softened corners with `rounded-lg` (2rem / 32px) and `rounded-md` (1rem / 16px) to contrast against sharp typographic details.
- Segmented progress bars and streak track rings use soft rounded caps.

## Components

### Buttons
- **Primary Action**: Pill-shaped (`rounded-full`), filled with `Primary Emerald` (`#10B981`) or high-contrast crisp white (`#FFFFFF`), with pure black bold typography.
- **Secondary / Ghost**: Pill-shaped with a pure black or `#0A0A0C` background, wrapped in a 1px hairline `rgba(255, 255, 255, 0.08)` and `Text Primary` copy.
- **Icon Action Buttons**: 44x44px rounded circles with midnight slate background (`#121215`) housing 20px hairline icons.

### Habit Cards
- **Card Chassis**: Background `#0A0A0C`, 1px border `rgba(255,255,255,0.08)`, radius `1rem` (16px), inner padding `1rem`.
- **Habit Progress**: Houses the habit title in `title-md`, streak pill badge with `JetBrains Mono` label, and a custom circular checkbox or horizontal swipe-to-complete indicator.
- **State Feedback**: On completion, card transitions to a faint accent border tint (`rgba(16, 185, 129, 0.3)`) with a brief bioluminescent glow.

### Checkboxes & Habit Check Toggles
- **Circular Checkboxes**: 28px diameter circles with a 1.5px border (`rgba(255, 255, 255, 0.2)`).
- **Checked State**: Solid fill of `#10B981` featuring an ink-black interior checkmark. Haptic feedback accompanies the tap.

### Chips & Filter Pills
- Fully pill-shaped (`border-radius: 9999px`), padding `6px 14px`.
- Inactive: `#121215` with `rgba(255,255,255,0.08)` border and `Text Secondary` typography.
- Active: Elevated surface with crisp white border (`rgba(255, 255, 255, 0.24)`) and jewel-tinted text/indicator dot.

### Journal Entry Card & Editor (Nhật ký)
- **Container**: Minimalist borderless text area or `#0A0A0C` enclosure.
- **Meta Row**: Monospaced time/date stamp in `label-md` alongside mood/tag chips.
- **Body**: Fluid multiline text field using `Plus Jakarta Sans` with `1.6` line-height for effortless night reflection.

### Streak Calendar Matrix (Heatmap / Daily Strip)
- Horizontal 7-day strip with rounded pill segments.
- Current active day highlighted with an emerald or cyan indicator dot beneath the date glyph.
- Completed days display an accent fill; inactive days remain `#121215` with hairline borders.