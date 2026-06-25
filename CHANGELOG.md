# Changelog

All notable changes to Brume are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-06-23


The first release of Brume. 🌫️

### Added
- **Unified canvas** — write and draw on the same page. Tap anywhere in Write
  mode to drop a draggable text note; switch to Draw mode to sketch with finger
  or Apple Pencil over your words.
- **Drawing tools** — pen, pencil, marker, and eraser, with a six-colour soothing
  palette (ink, clay, sage, rose, sky, amber) shared between text and ink.
- **Moods** — tag each entry with one of five gentle moods (Happy, Calm, Tender,
  Alive, Grateful).
- **Journal home** — chronological list with text previews, mood, and a live
  thumbnail of each entry's drawing. Pull-to-reveal search.
- **Splash & onboarding** — an animated self-drawing "B" splash, a three-step
  onboarding with code-drawn illustrations, and a first-run in-canvas coach.
- **Light & dark themes** — warm cream day theme and deep-indigo night theme with
  fully adaptive colours.
- **PDF export** — export any entry (text + drawing) as a clean PDF on cream paper.
- **Face ID lock** — optional biometric lock for the whole app.
- **Gentle reminders** — optional, kindly-worded daily local notification with
  background support.
- **Hand-drawn design system** — sketchy borders, lined/dotted paper, handwriting
  typography, and a code-generated app icon and banner (no image assets).

### Notes
- 100% native Apple frameworks (SwiftUI, SwiftData, PencilKit, PDFKit,
  LocalAuthentication, UserNotifications). No third-party dependencies.
- All data stays on-device. No accounts, no analytics, no network code.
