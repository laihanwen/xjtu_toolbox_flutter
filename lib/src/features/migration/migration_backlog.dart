import '../../core/migration_area.dart';

enum MigrationStatus {
  notStarted,
  planned,
  inProgress,
  blocked,
  done,
}

class MigrationBacklogItem {
  const MigrationBacklogItem({
    required this.area,
    required this.title,
    required this.status,
    required this.notes,
  });

  final MigrationArea area;
  final String title;
  final MigrationStatus status;
  final String notes;
}

const migrationBacklog = <MigrationBacklogItem>[
  MigrationBacklogItem(
    area: MigrationArea.auth,
    title: 'Model CAS, SSO, captcha and MFA state',
    status: MigrationStatus.planned,
    notes: 'Port after XJTULogin behavior is covered by tests.',
  ),
  MigrationBacklogItem(
    area: MigrationArea.webVpn,
    title: 'Port WebVPN URL transform',
    status: MigrationStatus.planned,
    notes: 'AES-CFB logic should be tested with known Android outputs.',
  ),
  MigrationBacklogItem(
    area: MigrationArea.storage,
    title: 'Define secure storage and database migration',
    status: MigrationStatus.planned,
    notes: 'EncryptedSharedPreferences and Room need explicit migration.',
  ),
  MigrationBacklogItem(
    area: MigrationArea.widgets,
    title: 'Keep Android widgets behind native bridge',
    status: MigrationStatus.blocked,
    notes: 'RemoteViews/AppWidgetProvider cannot be pure Flutter.',
  ),
  MigrationBacklogItem(
    area: MigrationArea.downloads,
    title: 'Design replay and attachment download manager',
    status: MigrationStatus.planned,
    notes: 'Needs platform file APIs and background behavior review.',
  ),
  MigrationBacklogItem(
    area: MigrationArea.video,
    title: 'Select video playback strategy',
    status: MigrationStatus.planned,
    notes: 'Current Android implementation uses Media3 ExoPlayer.',
  ),
];
