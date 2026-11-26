# Design System

## Direction

Kmail Desktop uses a calm, premium, desktop-first Material 3 visual language. The default UI must look complete without blur. Blur is optional and subtle.

## Tokens

### Colors (`lib/design_system/tokens/app_colors.dart`)

Semantic tokens for light/dark themes:
- Primary / onPrimary
- Secondary
- Accent
- Background / Surface / Elevated surface / Muted surface
- Border / Divider
- Text primary / secondary / disabled
- Success / Warning / Error / Info
- Selection / Hover / Focus ring

### Typography (`app_typography.dart`)

Segoe UI-based desktop typography scale:
- Display small, Headline small
- Title large/medium/small
- Body large/medium/small
- Label large/medium/small

Font licensing: no bundled custom font files in Phase 1; uses Windows-available Segoe UI with Flutter fallback.

### Spacing (`app_spacing.dart`)

`xxs=4, xs=8, sm=12, md=16, lg=24, xl=32, xxl=40`

### Radii (`app_radii.dart`)

`sm=8, md=12, lg=16, xl=20, pill=999`

### Motion (`app_motion.dart`)

Settings: `full`, `reduced`, `off`. Motion respects OS reduced-motion where possible. Durations resolve to zero when off.

### Density (`settings_controller.dart`)

`compact=0.88`, `comfortable=1.0`, `spacious=1.14`. Density affects message rows, list padding, and spacing-sensitive UI.

## Components

Implemented reusable/customized components:
- App shell layout and toolbar
- Sidebar navigation items and account card
- Message list rows with selection, unread, star, attachment indicators
- Reader pane with action bar, metadata, remote-image banner, attachment section
- Attachment cards and preview dialog
- Compose dialog
- Settings dialog/sections
- Empty/loading/error/fallback states (contextual)

## Theme behavior

- Light, dark, and system theme modes.
- Material 3 `ColorScheme` generated from semantic tokens.
- Component themes customized for inputs, buttons, dialogs, lists, tooltips, dividers, checkboxes.
- No mobile bottom navigation; desktop three-panel layout.

## Accessibility

- Visible focus via Material/Theme focus styles.
- Tooltips on icon actions.
- Text scaling setting (0.9–1.3).
- Reduced/off motion settings.
- Status not color-only: unread dot plus weight, labels/text, icons.

## Known visual limitations

- No custom font bundle yet; typography relies on system font availability.
- Blur is a simple opacity/surface treatment in Phase 1, not OS acrylic/mica.
- Some components use standard Material widgets with custom theming; further refinement planned.