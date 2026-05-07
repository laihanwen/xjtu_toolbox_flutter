# XJTU Toolbox Current Function Architecture

This document summarizes the existing Android app architecture so future agents can port features into the Flutter project without rediscovering the whole codebase.

## Source Overview

Existing Android project path:

```text
D:\learn\code\final\xjtu-toolbox-android
```

Primary source root:

```text
app/src/main/java/com/xjtu/toolbox/
```

The Android app is a single-module Kotlin app using:

- Jetpack Compose for UI
- MIUIX components for HyperOS-like UI
- OkHttp for HTTP
- Gson and Jsoup for JSON/HTML parsing
- Room for local database
- Android EncryptedSharedPreferences for sensitive storage
- Media3 ExoPlayer for video playback
- Android AppWidget/RemoteViews for home screen widgets

## High-Level Runtime Architecture

```text
MainActivity
  AppNavigation
    Login state and session restoration
    Bottom tabs and route dispatch
    Feature screens
  AppLoginState / AppLoginStateViewModel
    Shared CAS session
    Per-service login instances
    Cookie jars
    WebVPN mode
    Cached user/profile data

Feature Screen
  remembers local UI state
  creates feature API wrapper
  calls Android login/session object
  reads/writes cache or Room when needed
  renders Compose UI
```

Important issue for migration:

- Much of the Android UI and feature state is inside Compose screens.
- `MainActivity.kt` is very large and contains routing, app shell, login state, update UI, and home/profile sections.
- Flutter migration should separate these concerns instead of recreating one large Dart file.

## Cross-Cutting Modules

### Auth

Android package:

```text
auth/
```

Responsibilities:

- CAS unified login
- captcha and MFA flow
- RSA password encryption
- token extraction for service-specific systems
- SSO reuse through shared OkHttp clients and cookies
- service-specific re-authentication

Key files:

- `XJTULogin.kt`: base CAS login implementation
- `LoginScreen.kt`: login type definitions and UI
- `AttendanceLogin.kt`: attendance and JWXT login variants
- `JwappLogin.kt`: JWAPP token login
- `YwtbLogin.kt`: one-stop service token login
- `CampusCardLogin.kt`: campus card OAuth/JWT login
- `LibraryLogin.kt`: library login
- `VenueLogin.kt`: venue login
- `DzpzLogin.kt`: transcript/OA login
- `CouponLogin.kt`: coupon login

Flutter target:

- `core/session`
- future `core/auth`
- future `core/network`

### Utilities and Storage

Android package:

```text
util/
```

Responsibilities:

- secure credential storage
- persistent CookieJar
- WebVPN URL transform
- generic cache
- Room database creation and migrations
- JSON helpers
- XJTU time utilities

Key files:

- `CredentialStore.kt`
- `PersistentCookieJar.kt`
- `WebVpnUtil.kt`
- `DataCache.kt`
- `AppDatabase.kt`
- `XjtuTime.kt`
- `JsonExt.kt`

Flutter target:

- `core/storage`
- `core/network`
- `core/webvpn`
- `core/time`

## Feature Modules

### Schedule

Android package:

```text
schedule/
```

User features:

- personal schedule
- weekly course view
- exam schedule
- textbook information
- custom courses
- holiday filtering
- ICS export/share
- all-school course search

Key files:

- `ScheduleScreen.kt`
- `ScheduleApi.kt`
- `ScheduleCache.kt`
- `ScheduleExport.kt`
- `CustomCourseEntity.kt`
- `CustomCourseDialog.kt`
- `HolidayApi.kt`
- `SchoolCourseScreen.kt`
- `SchoolCourseApi.kt`

Migration notes:

- Good candidate for phased migration after core storage and login are ready.
- Start with Dart models and cache format.
- `CustomCourseEntity` requires database migration planning.
- `ScheduleExport` requires platform file/share support.

### Campus Card

Android package:

```text
card/
```

User features:

- balance
- transaction records
- monthly/category/meal-time statistics
- homepage card cache
- campus card widget data

Key files:

- `CampusCardScreen.kt`
- `CampusCardApi.kt`
- `auth/CampusCardLogin.kt`
- `widget/CampusCardWidgetProvider.kt`

Migration notes:

- Depends on CAS/OAuth/JWT.
- Widget support remains Android-native.
- Statistics logic can be ported to Dart and tested independently.

### Attendance

Android package:

```text
attendance/
```

User features:

- attendance records
- term filtering
- weekly/current statistics
- status filtering

Key files:

- `AttendanceScreen.kt`
- `AttendanceApi.kt`
- `auth/AttendanceLogin.kt`

Migration notes:

- Depends on internal service and possibly WebVPN.
- Do not port before WebVPN and auth are stable.

### Empty Room

Android package:

```text
emptyroom/
```

User features:

- public classroom availability
- campus/building/section filters
- room seat count lookup

Key files:

- `EmptyRoomScreen.kt`
- `EmptyRoomApi.kt`

Migration notes:

- Lower-risk candidate if data source is public and does not require login.
- Good early feature after app shell.

### Notification

Android package:

```text
notification/
```

User features:

- multi-source notice aggregation
- notice listing/detail

Key files:

- `NotificationScreen.kt`
- `NotificationApi.kt`

Migration notes:

- Good early candidate if APIs do not require complex auth.

### Library

Android package:

```text
library/
```

User features:

- seat status
- reservation status
- seat recommendation
- seat map visualization
- check-in/cancel operations

Key files:

- `LibraryScreen.kt`
- `LibraryApi.kt`
- `SeatMapCanvas.kt`
- `SeatMapView.kt`
- `SeatNeighborData.kt`
- `auth/LibraryLogin.kt`

Migration notes:

- Depends on auth and often internal network/WebVPN.
- Seat map can be ported to Flutter Canvas after API models are stable.

### Venue

Android package:

```text
venue/
```

User features:

- venue list
- available slots
- favorites
- booking
- slider captcha interaction

Key files:

- `VenueScreen.kt`
- `VenueApi.kt`
- `VenueFavorites.kt`
- `SliderCaptcha.kt`
- `auth/VenueLogin.kt`

Migration notes:

- Slider captcha behavior is sensitive; port only after API tests and UI gesture handling are clear.
- Favorites storage should be moved to Flutter storage layer.

### Course Replay and Downloads

Android package:

```text
classreplay/
```

User features:

- TronClass course list
- replay activity list
- multi-camera video playback
- replay download queue
- pause/resume/cancel downloads
- download manager screen

Key files:

- `ClassScreen.kt`
- `ClassApi.kt`
- `ClassLogin.kt`
- `VideoPlayerScreen.kt`
- `DownloadManager.kt`
- `DownloadManagerScreen.kt`
- `DownloadTaskEntity.kt`

Migration notes:

- High-risk area due to video, file system, background work, and Room task state.
- Keep behind platform bridge until requirements are stable.

### LMS

Android package:

```text
lms/
```

User features:

- courses
- homework
- scores/comments
- courseware/resources
- live/replay resource URLs
- attachment download

Key files:

- `LmsScreen.kt`
- `LmsApi.kt`
- `LmsLogin.kt`
- `LmsModels.kt`

Migration notes:

- Models are a good early extraction target.
- Downloads require platform support.

### JWAPP and Score Reports

Android packages:

```text
jwapp/
score/
```

User features:

- official grades
- FineReport/report-based grade queries
- GPA and score display

Key files:

- `jwapp/JwappScoreScreen.kt`
- `jwapp/JwappApi.kt`
- `jwapp/CjcxApi.kt`
- `score/ScoreReportScreen.kt`
- `score/ScoreReportApi.kt`
- `auth/JwappLogin.kt`

Migration notes:

- Depends heavily on auth and HTML/report parsing.
- Port parsers with fixtures before UI.

### Judge

Android package:

```text
judge/
```

User features:

- regular course evaluation
- GSTE graduate evaluation
- one-click evaluation workflows

Key files:

- `JudgeScreen.kt`
- `JudgeApi.kt`
- `GsteJudgeScreen.kt`
- `GsteJudgeApi.kt`
- `auth/GsteLogin.kt`

Migration notes:

- High-risk because it performs write operations.
- Do not implement until auth, confirmation UI, and dry-run safeguards are designed.

### Transcript

Android package:

```text
dzpz/
```

User features:

- transcript/certificate workflow
- form linkage
- submit/check/download PDF

Key files:

- `TranscriptScreen.kt`
- `TranscriptApi.kt`
- `auth/DzpzLogin.kt`

Migration notes:

- Multi-step workflow; model state machine first.
- Download/export requires platform file support.

### Coupon

Android package:

```text
coupon/
```

User features:

- electronic meal coupon records
- coupon type filters
- status display
- image/loading support

Key files:

- `CouponScreen.kt`
- `CouponApi.kt`
- `CouponModels.kt`
- `auth/CouponLogin.kt`

Migration notes:

- `CouponModels.kt` already has parser tests in Android project; port tests to Dart.

### Jiaocai

Android package:

```text
jiaocai/
```

User features:

- textbook center search
- online reading in WebView
- PDF download

Key files:

- `JiaocaiScreen.kt`
- `JiaocaiApi.kt`
- `JiaocaiLogin.kt`

Migration notes:

- WebView cookie sync is critical.
- Downloads require platform support.

### NeoSchool

Android package:

```text
neo/
```

User features:

- course list
- chapters
- resources
- resource download URLs

Key files:

- `NeoScreen.kt`
- `NeoApi.kt`
- `NeoModels.kt`
- `NeoSession.kt`

Migration notes:

- Good model-first candidate.
- Session behavior is separate from CAS-style login and needs explicit handling.

### YWTB and NSA

Android packages:

```text
ywtb/
nsa/
```

User features:

- one-stop service user data
- profile/nickname
- NSA OAuth2 student profile and photo

Key files:

- `YwtbScreen.kt`
- `YwtbApi.kt`
- `NsaApi.kt`
- `auth/YwtbLogin.kt`

Migration notes:

- Used by profile/home display.
- Cache behavior must respect sensitive data.

### GMIS

Android package:

```text
gmis/
```

User features:

- graduate system courses
- graduate scores

Key files:

- `GmisScreen.kt`
- `GmisApi.kt`
- `auth/GmisLogin.kt`

Migration notes:

- Depends on OAuth/cookie login.

### Payment Code

Android package:

```text
pay/
```

User features:

- payment code display

Key files:

- `PaymentCodeScreen.kt`
- `PaymentCodeApi.kt`

Migration notes:

- Treat as sensitive financial/identity UI.
- Verify token lifetime and screen privacy requirements before porting.

### Browser

Android package:

```text
browser/
```

User features:

- in-app browser
- cookie sync from OkHttp session
- download handoff

Key file:

- `BrowserScreen.kt`

Migration notes:

- Must be designed as a shared WebView service in Flutter, not copied into every feature.

### Calendar

Android package:

```text
calendar/
```

User features:

- school calendar
- terms
- calendar events

Key files:

- `SchoolCalendarScreen.kt`
- `SchoolCalendarApi.kt`

Migration notes:

- Good early migration candidate if API can be accessed without complex auth.

### App Settings and Shared UI

Android packages:

```text
ui/
ui/settings/
ui/components/
ui/theme/
```

User features:

- theme/dark mode
- navigation style
- default tab
- network mode
- update channel
- reusable chips, dropdowns, top bars, state components

Key files:

- `ui/settings/SettingsScreen.kt`
- `ui/components/AppChip.kt`
- `ui/components/AppDropdownMenu.kt`
- `ui/components/AppTopBar.kt`
- `ui/components/StateComponents.kt`
- `ui/theme/Theme.kt`
- `ui/theme/Color.kt`
- `ui/ScheduleComponents.kt`

Migration notes:

- Good early area for Flutter app shell and design system.

### Android Widgets

Android package:

```text
widget/
```

User features:

- 2x2 schedule widget
- 4x2 schedule widget
- campus card widget

Key files:

- `ScheduleWidgetProvider.kt`
- `ScheduleWidgetRemoteViewsService.kt`
- `CampusCardWidgetProvider.kt`

Migration notes:

- Keep as Android-native or recreate via native bridge.
- Flutter alone cannot replace Android RemoteViews widgets.

## Suggested Feature Migration Priority

1. App shell, theme, bottom navigation, settings UI
2. Static/reusable components and empty/error/loading states
3. Calendar, empty room, notification models
4. Public API clients and parsers with fixtures
5. Schedule models/cache/custom course storage
6. Auth/session foundation
7. WebVPN and cookie persistence
8. Campus card, attendance, library, venue
9. WebView-based features
10. Downloads, video, widgets, APK update/install

## Agent Prompt Template

Use this structure when asking another agent to work on a feature:

```text
Read docs/agent_technical_constraints.md and docs/agent_function_architecture.md first.
Target Flutter project: D:\learn\code\final\xjtu_toolbox_flutter.
Reference Android files: <list exact files>.
Task: <small, specific change>.
Constraints:
- Do not modify unrelated features.
- Keep platform-specific logic behind lib/src/platform_bridge.
- Add or update tests when adding models/parsers/state logic.
- Report changed files and verification commands.
```

