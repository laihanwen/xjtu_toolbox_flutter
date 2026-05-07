enum MigrationArea {
  auth,
  network,
  storage,
  webVpn,
  schedule,
  campusCard,
  library,
  webView,
  downloads,
  widgets,
  video,
}

extension MigrationAreaLabel on MigrationArea {
  String get label {
    return switch (this) {
      MigrationArea.auth => 'Auth',
      MigrationArea.network => 'Network',
      MigrationArea.storage => 'Storage',
      MigrationArea.webVpn => 'WebVPN',
      MigrationArea.schedule => 'Schedule',
      MigrationArea.campusCard => 'Campus Card',
      MigrationArea.library => 'Library',
      MigrationArea.webView => 'WebView',
      MigrationArea.downloads => 'Downloads',
      MigrationArea.widgets => 'Widgets',
      MigrationArea.video => 'Video',
    };
  }
}
