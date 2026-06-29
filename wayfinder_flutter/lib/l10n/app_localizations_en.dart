// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wayfinder';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabMapTiles => 'Map tiles';

  @override
  String get settingsTabGeocoding => 'Geocoding';

  @override
  String get settingsTabBackup => 'Backup';

  @override
  String get settingsTabAbout => 'About';

  @override
  String get settingsAboutTitle => 'About Wayfinder';

  @override
  String get settingsAboutDescription =>
      'Read-only build and connection details for this client. Use the git commit to confirm whether the latest build is running.';

  @override
  String get settingsAboutOpenManual => 'Open user manual';

  @override
  String get settingsAboutLoading => 'Loading app info…';

  @override
  String settingsAboutLoadFailed(String error) {
    return 'Could not load app info: $error';
  }

  @override
  String get settingsAboutAppSection => 'Application';

  @override
  String get settingsAboutConnectionSection => 'Connection';

  @override
  String get settingsAboutDeploymentSection => 'Deployment';

  @override
  String get settingsAboutDockerImageId => 'Docker image ID';

  @override
  String get settingsAboutDockerImageIdUnavailable =>
      'Not available — recreate the container after pulling so the image ID is recorded at startup.';

  @override
  String get settingsAboutDockerImageRef => 'Docker image reference';

  @override
  String get settingsAboutContainerStarted => 'Container started';

  @override
  String settingsAboutDockerImageIdHint(String imageIdPrefix) {
    return 'The Docker image ID changes whenever you pull a new build. It should start with $imageIdPrefix and match the IMAGE ID column from docker compose images or docker image inspect.';
  }

  @override
  String get settingsAboutDockerImageIdHintUnavailable =>
      'After docker compose pull, run docker compose up -d --force-recreate so the container records the current image ID here. The ID changes on every new image build even when the tag stays :latest.';

  @override
  String get settingsAboutAppName => 'App name';

  @override
  String get settingsAboutVersion => 'Version';

  @override
  String get settingsAboutGitCommit => 'Git commit';

  @override
  String get settingsAboutGitCommitUnavailable =>
      'Not available (local dev build)';

  @override
  String get settingsAboutBuildTime => 'Built';

  @override
  String get settingsAboutPlatform => 'Platform';

  @override
  String get settingsAboutPackage => 'Package';

  @override
  String get settingsAboutApiServer => 'API server';

  @override
  String get settingsAboutWebServer => 'Web server';

  @override
  String get settingsAboutGeocodingServer => 'Geocoding server';

  @override
  String get settingsAboutGeocodingServerNotConfigured => 'Not configured';

  @override
  String settingsAboutCommitHint(String commit) {
    return 'Deployed builds include a git commit (for example $commit). Compare it to the latest commit on main or the image tag you pulled.';
  }

  @override
  String get actionSave => 'Save';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionLater => 'Later';

  @override
  String get actionOk => 'OK';

  @override
  String get actionReloadNow => 'Reload now';

  @override
  String get actionSaving => 'Saving…';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionImport => 'Import';

  @override
  String get actionExport => 'Export';

  @override
  String get actionRemoveAll => 'Remove all';

  @override
  String get actionClose => 'Close';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get actionOpenSettings => 'Open Settings';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionSignOut => 'Sign out';

  @override
  String get actionUploading => 'Uploading…';

  @override
  String get actionExporting => 'Exporting…';

  @override
  String get actionRestoring => 'Restoring…';

  @override
  String get actionAborting => 'Aborting…';

  @override
  String get statusLoading => 'Loading…';

  @override
  String get statusWorking => 'Working…';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceDescription =>
      'Choose a color theme for the app. Military themes use olive, tan, and forest green tones. Stored on the server so every browser uses the same theme.';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageDescription =>
      'Choose the language used throughout the app. Stored on the server so every browser uses the same language.';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get settingsThemeStyle => 'Theme style';

  @override
  String get settingsBrightness => 'Brightness';

  @override
  String get settingsMapHomeTitle => 'Map home';

  @override
  String get settingsMapHomeDescription =>
      'Coordinates and zoom for the home button on the map. Stored on the server so all clients share the same home location. Also used as the starting view when no previous map position is saved.';

  @override
  String get settingsLatitude => 'Latitude';

  @override
  String get settingsLongitude => 'Longitude';

  @override
  String get settingsZoom => 'Zoom';

  @override
  String settingsZoomHelper(String maxZoom) {
    return '0–$maxZoom';
  }

  @override
  String get settingsSaveHome => 'Save home';

  @override
  String get settingsUseCurrentMapView => 'Use current map view';

  @override
  String get settingsResetToDefault => 'Reset to default';

  @override
  String get settingsServerConnectionTitle => 'Server connection';

  @override
  String get settingsServerConnectionDescription =>
      'Wayfinder API server URL, including host and port. The web server URL (REST API and PMTiles) is derived automatically (API port + 2). Restart the app after changing this.';

  @override
  String get settingsServerUrl => 'Server URL';

  @override
  String settingsCurrentWebServer(String webUrl) {
    return 'Current web server: $webUrl';
  }

  @override
  String get settingsSaveServerUrl => 'Save server URL';

  @override
  String get settingsMeasurementsTitle => 'Measurements';

  @override
  String get settingsMeasurementsDescription =>
      'Choose how line distances are displayed on the map. Stored on the server so every browser uses the same units.';

  @override
  String get settingsAnglesTitle => 'Angles';

  @override
  String get settingsAnglesDescription =>
      'Choose how relative angles are displayed on the map and in bearing plots. Stored on the server so every browser uses the same format.';

  @override
  String get lineArrowDensityLabel => 'Arrow frequency';

  @override
  String get lineArrowDensitySparse => 'Sparse';

  @override
  String get lineArrowDensityLight => 'Light';

  @override
  String get lineArrowDensityBalanced => 'Balanced';

  @override
  String get lineArrowDensityFrequent => 'Frequent';

  @override
  String get lineArrowDensityDense => 'Dense';

  @override
  String get settingsCirclesTitle => 'Circles';

  @override
  String get settingsCirclesDescription =>
      'Choose the default size label shown on new circular zones. Stored on the server so every browser uses the same default.';

  @override
  String get settingsMapDebugTitle => 'Map debugging';

  @override
  String get settingsMapDebugDescription =>
      'Visual aids stored in this browser only.';

  @override
  String get settingsMapViewportDebugBorderTitle => 'Show map viewport border';

  @override
  String get settingsMapViewportDebugBorderDescription =>
      'Draws a red outline around the map canvas with archive, zoom, and center-tile details.';

  @override
  String get settingsMapTileBorderDebugTitle => 'Show tile borders';

  @override
  String get settingsMapTileBorderDebugDescription =>
      'Draws green borders around each map tile. Requires the viewport debug overlay above.';

  @override
  String get mapDebugOverlayCopyTooltip => 'Copy debug info';

  @override
  String get mapDebugOverlayCopied => 'Debug info copied to clipboard.';

  @override
  String get mapDebugOverlayCopyFailedTitle =>
      'Copy blocked — select and copy manually';

  @override
  String get settingsHomeLocationSaved => 'Home location saved.';

  @override
  String get settingsHomeLocationReset => 'Home location reset to default.';

  @override
  String get settingsOpenMapFirst => 'Open the map first to capture its view.';

  @override
  String get settingsHomeLocationInvalid =>
      'Enter valid numbers for latitude, longitude, and zoom.';

  @override
  String settingsHomeLocationSaveFailed(String error) {
    return 'Failed to save home location: $error';
  }

  @override
  String get settingsRestartRequiredTitle => 'Restart required';

  @override
  String settingsRestartRequiredMessage(String apiUrl, String webUrl) {
    return 'Server URL saved.\n\nAPI: $apiUrl\nWeb: $webUrl\n\nRestart the app to connect to the new server.';
  }

  @override
  String get settingsServerUrlReset =>
      'Server URL reset to default. Restart the app to apply.';

  @override
  String settingsServerUrlSaveFailed(String error) {
    return 'Failed to save server URL: $error';
  }

  @override
  String get themePreviewPrimary => 'Primary';

  @override
  String get themePreviewSecondary => 'Secondary';

  @override
  String get themePreviewSurface => 'Surface';

  @override
  String get themePreviewAccent => 'Accent';

  @override
  String get themePreviewButton => 'Button';

  @override
  String get themePreviewOutline => 'Outline';

  @override
  String get themeFamilyStandard => 'Standard';

  @override
  String get themeFamilyMilitary => 'Military';

  @override
  String get themeBrightnessLight => 'Light';

  @override
  String get themeBrightnessDark => 'Dark';

  @override
  String get themeChoiceMilitaryLight => 'Military light';

  @override
  String get themeChoiceMilitaryDark => 'Military dark';

  @override
  String get measurementMetric => 'Metric';

  @override
  String get measurementImperial => 'Imperial';

  @override
  String get measurementNautical => 'Nautical';

  @override
  String get measurementMetricShort => 'm/km';

  @override
  String get measurementImperialShort => 'ft/mi';

  @override
  String get measurementNauticalShort => 'nm';

  @override
  String get angleFormatDecimal => 'Decimal degrees';

  @override
  String get angleFormatDms => 'Degrees, minutes, seconds';

  @override
  String get angleFormatDecimalShort => 'DD';

  @override
  String get angleFormatDmsShort => 'DMS';

  @override
  String get circleSizeRadius => 'Radius';

  @override
  String get circleSizeDiameter => 'Diameter';

  @override
  String get circleSizeNone => 'None';

  @override
  String get circleSizeToggleRadius =>
      'Showing radius on map · tap for diameter';

  @override
  String get circleSizeToggleDiameter =>
      'Showing diameter on map · tap for none';

  @override
  String get circleSizeToggleNone => 'Size hidden on map · tap for radius';

  @override
  String get backupTitle => 'Map data backup';

  @override
  String get backupDescription =>
      'Export or restore all layers, markers, and zones. You can also back up with curl: GET /api/map-data';

  @override
  String get backupExportButton => 'Export map data (.json)';

  @override
  String get backupRestoreButton => 'Restore from backup';

  @override
  String get backupExportSuccess => 'Map data backup saved.';

  @override
  String backupExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get backupRestoreConfirmTitle => 'Restore map data?';

  @override
  String get backupRestoreConfirmMessage =>
      'This replaces all layers, markers, and zones on the server with the selected backup file. This cannot be undone.';

  @override
  String backupRestoreSuccess(int layers, int markers, int zones) {
    return 'Restored $layers layer(s), $markers marker(s), and $zones zone(s).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get mapTilesFolderTitle => 'PMTiles folder';

  @override
  String get mapTilesFolderDescription =>
      'Folder on the server containing .pmtiles archives. Stored in the database so every client uses the same map tile library after restart.';

  @override
  String get mapTilesStoragePathLabel => 'PMTiles storage path';

  @override
  String get mapTilesStoragePathRequired => 'PMTiles storage path is required.';

  @override
  String get mapTilesSaveAndRescan => 'Save and rescan folder';

  @override
  String mapTilesFolderSaved(String path) {
    return 'PMTiles folder saved. Resynced from $path.';
  }

  @override
  String mapTilesFolderSaveFailed(String error) {
    return 'Failed to save PMTiles folder: $error';
  }

  @override
  String get mapTilesMapsTitle => 'PMTiles Maps';

  @override
  String get mapTilesMapsDescription =>
      'Organize offline map archives into groups and choose which ones are drawn on the map. Only the best-matching enabled archive is shown at once to keep the map responsive.';

  @override
  String get mapTilesUploadButton => 'Upload .pmtiles file';

  @override
  String mapTilesUploadSuccess(String name) {
    return 'PMTiles file uploaded: $name';
  }

  @override
  String mapTilesUploadFailed(String error) {
    return 'Upload failed: $error';
  }

  @override
  String get mapTilesAllHidden => 'All map tiles hidden from the map.';

  @override
  String get mapTilesNewGroupTitle => 'New tile group';

  @override
  String get mapTilesGroupNameLabel => 'Group name';

  @override
  String get mapTilesGroupNameHint => 'e.g. Mid-Atlantic states';

  @override
  String mapTilesGroupCreated(String name) {
    return 'Created group \"$name\".';
  }

  @override
  String mapTilesGroupCreateFailed(String error) {
    return 'Could not create group: $error';
  }

  @override
  String get mapTilesDeleteGroupTitle => 'Delete tile group?';

  @override
  String mapTilesDeleteGroupMessage(String name) {
    return 'Delete \"$name\"? Files in this group will become ungrouped.';
  }

  @override
  String get mapTilesDeleteFileTitle => 'Delete PMTiles file?';

  @override
  String mapTilesDeleteFileMessage(String name) {
    return 'Remove \"$name\" from the server?';
  }

  @override
  String get mapTilesFileDeleted => 'PMTiles file deleted.';

  @override
  String mapTilesFilesLoadFailed(String error) {
    return 'Failed to load files: $error';
  }

  @override
  String mapTilesGroupsLoadFailed(String error) {
    return 'Failed to load groups: $error';
  }

  @override
  String get mapTilesNoFiles => 'No PMTiles files uploaded yet.';

  @override
  String mapTilesShownOnMapCount(int shown, int total) {
    return '$shown of $total shown on map';
  }

  @override
  String get mapTilesUngrouped => 'Ungrouped';

  @override
  String get mapTilesNoFilesAssigned => 'No files assigned';

  @override
  String get mapTilesShowUngroupedOnMap => 'Show ungrouped on map';

  @override
  String get mapTilesShowGroupOnMap => 'Show group on map';

  @override
  String get mapTilesDeleteGroupTooltip => 'Delete group';

  @override
  String get mapTilesUngroupedEmptyMessage =>
      'Files not assigned to a group appear here.';

  @override
  String get mapTilesGroupEmptyMessage =>
      'Assign files to this group from the menu on each tile.';

  @override
  String get mapTilesNoGroups => 'No groups';

  @override
  String mapTilesGroupCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get mapTilesManageGroupsTooltip => 'Manage groups';

  @override
  String get mapTilesNewGroup => 'New group';

  @override
  String get mapTilesShowAllOnMap => 'Show all on map';

  @override
  String get mapTilesHideAllFromMap => 'Hide all from map';

  @override
  String get layerLabel => 'Layer';

  @override
  String get layerUnassigned => 'Unassigned';

  @override
  String get layerUnknown => 'Unknown layer';

  @override
  String get formNameLabel => 'Name';

  @override
  String get formColorLabel => 'Color';

  @override
  String get formNotesLabel => 'Notes';

  @override
  String get formNotesPlaceholder => 'Add notes (saved as Markdown)...';

  @override
  String get formPreviewLabel => 'Preview';

  @override
  String get formShowNameOnMap => 'Show name on map';

  @override
  String get formBorderColorLabel => 'Border color';

  @override
  String get formFillColorLabel => 'Fill color';

  @override
  String get formUnitLabel => 'Unit';

  @override
  String get formFillOpacityHelp =>
      'Adjust opacity to control fill transparency.';

  @override
  String get coordinatesTitle => 'Coordinates';

  @override
  String get markerCreateTitle => 'Create marker';

  @override
  String get markerEditTitle => 'Edit marker';

  @override
  String get markerDefaultName => 'New marker';

  @override
  String get markerCoordinatesHelp =>
      'Edit latitude and longitude to move the marker on the map.';

  @override
  String get markerTrackingLabel => 'Tracking marker';

  @override
  String get markerTrackingHelp =>
      'Record movement history as a trail on the map.';

  @override
  String get markerNameHint => 'e.g. Home, Work, Trailhead';

  @override
  String get markerElevationLabel => 'Elevation (m)';

  @override
  String get markerIconLabel => 'Icon';

  @override
  String get markerIconHelp =>
      'Choose an icon for the map pin, such as Home for your house.';

  @override
  String get markerSaveSearchedCoordinatesTitle => 'Save searched coordinates';

  @override
  String get markerSaveSearchedCoordinatesConfirm => 'Save marker';

  @override
  String get lineCreateTitle => 'Create line';

  @override
  String get lineEditTitle => 'Edit line';

  @override
  String get lineDefaultName => 'New line';

  @override
  String get lineNameHint => 'e.g. Route to camp, Property boundary';

  @override
  String get lineDistanceLabel => 'Distance';

  @override
  String get lineStartPointLabel => 'Start point';

  @override
  String get lineEndPointLabel => 'End point';

  @override
  String get lineStyleLabel => 'Line style';

  @override
  String get lineBorderSolid => 'Solid';

  @override
  String get lineBorderDashed => 'Dashed';

  @override
  String get lineDirectionArrowsTitle => 'Direction arrows';

  @override
  String get lineDirectionArrowsSubtitle =>
      'Arrows point from the first point toward the second.';

  @override
  String get circleCreateTitle => 'Create circle';

  @override
  String get circleEditTitle => 'Edit circle';

  @override
  String get trackEditTitle => 'Edit track';

  @override
  String get trackTransportationModeLabel => 'Transportation';

  @override
  String get trackTransportationModeOnFoot => 'On foot';

  @override
  String get trackTransportationModeBike => 'Bicycle';

  @override
  String get trackTransportationModeLandVehicle => 'Land vehicle';

  @override
  String get trackTransportationModeWatercraft => 'Watercraft';

  @override
  String get trackTransportationModeAircraft => 'Aircraft';

  @override
  String get trackShowFootstepsLabel => 'Trail icons on map';

  @override
  String get trackShowFootstepsHelp =>
      'Show transportation icons along the movement trail.';

  @override
  String get circleDefaultName => 'New circle';

  @override
  String get circleNameHint => 'e.g. Search area, Property boundary';

  @override
  String get circleMeasurementsLabel => 'Measurements';

  @override
  String get circleCenterMoveHelp =>
      'Edit latitude and longitude to move the center, for example to match a marker.';

  @override
  String get circleInvalidSize => 'Enter a valid size of at least 1 m radius.';

  @override
  String get circleCenterLabel => 'Center';

  @override
  String get circleSizeLabelOnMap => 'Size label on map';

  @override
  String get circleCenterMarkerLabel => 'Center marker';

  @override
  String get rectangleCreateTitle => 'Create rectangle';

  @override
  String get rectangleEditTitle => 'Edit rectangle';

  @override
  String get rectangleDefaultName => 'New rectangle';

  @override
  String get rectangleCornerALabel => 'Corner A';

  @override
  String get rectangleCornerBLabel => 'Corner B';

  @override
  String get rectangleCenterMoveHelp =>
      'Moving the center shifts the whole rectangle on the map.';

  @override
  String get mapHomeTooltip => 'Home';

  @override
  String get mapSettingsTooltip => 'Settings';

  @override
  String get mapManualTooltip => 'User manual';

  @override
  String get userManualTitle => 'User Manual';

  @override
  String get userManualContentsTitle => 'Contents';

  @override
  String userManualLoadFailed(String error) {
    return 'Could not load the user manual: $error';
  }

  @override
  String get userManualEmpty => 'The user manual is empty.';

  @override
  String get mapShowObjectsTooltip => 'Show map objects';

  @override
  String mapLoadFailed(String error) {
    return 'Failed to load map: $error';
  }

  @override
  String get mapNoOfflineMapTitle => 'No offline map installed or visible';

  @override
  String get mapNoOfflineMapMessage =>
      'Upload a .pmtiles file in Settings, or turn on visibility for tiles already on the server.';

  @override
  String get mapObjectDetailsTitle => 'Map object';

  @override
  String get mapObjectDetailsLoading => 'Loading details…';

  @override
  String get mapObjectDetailsNotFound => 'This object could not be found.';

  @override
  String get mapObjectDetailType => 'Type';

  @override
  String get mapObjectTypeMarker => 'Marker';

  @override
  String get mapObjectTypeLine => 'Line';

  @override
  String get mapObjectTypeTrack => 'Track';

  @override
  String get mapObjectTypeCircle => 'Circle';

  @override
  String get mapObjectDetailCoordinates => 'Coordinates';

  @override
  String get mapObjectDetailElevation => 'Elevation';

  @override
  String get mapObjectDetailVisibility => 'Visibility';

  @override
  String get mapObjectVisibilityVisible => 'Visible';

  @override
  String get mapObjectVisibilityHidden => 'Hidden';

  @override
  String get mapObjectDetailLength => 'Length';

  @override
  String get mapObjectDetailPointCount => 'Points';

  @override
  String get mapObjectDetailStart => 'Start';

  @override
  String get mapObjectDetailEnd => 'End';

  @override
  String get mapObjectDetailRadius => 'Radius';

  @override
  String get mapObjectDetailDiameter => 'Diameter';

  @override
  String get mapObjectDetailCenter => 'Center';

  @override
  String get mapObjectDetailMapLabel => 'Map label';

  @override
  String get mapObjectMapLabelNone => 'None';

  @override
  String get mapObjectDetailDimensions => 'Dimensions';

  @override
  String get mapObjectDetailArea => 'Area';

  @override
  String get mapObjectsErrorServerUnreachable =>
      'The Wayfinder server could not be reached. Start the server to sync markers and zones.';

  @override
  String get mapObjectsErrorSignInRequired =>
      'Sign in to load your map objects.';

  @override
  String get mapObjectsErrorGeneric =>
      'Something went wrong while loading map objects. Check your connection and try again.';

  @override
  String get mapObjectsErrorRetry =>
      'Something went wrong while loading map objects. Please try again.';

  @override
  String get layersErrorTableMissing =>
      'The map layers database table is missing. Restart the Wayfinder server with migrations applied.';

  @override
  String get layersErrorEndpointUnavailable =>
      'Restart the Wayfinder server from the latest code.';

  @override
  String get layersErrorGeneric =>
      'Something went wrong while loading layers. Please try again.';

  @override
  String get sidebarTitle => 'Map Objects';

  @override
  String get sidebarCollapsePanel => 'Collapse panel';

  @override
  String get sidebarExpandPanel => 'Expand panel';

  @override
  String get sidebarLayerOrderHint =>
      'Top layers draw above lower ones. Use ▼ to expand or collapse layer contents.';

  @override
  String get sidebarLayersUnavailable => 'Layers unavailable';

  @override
  String get sidebarMarkersUnavailable => 'Markers unavailable';

  @override
  String get sidebarZonesUnavailable => 'Zones unavailable';

  @override
  String get sidebarAddLayer => 'Add layer';

  @override
  String get sidebarKeepOneLayer => 'You must keep at least one layer.';

  @override
  String get sidebarNewLayerTitle => 'New layer';

  @override
  String get sidebarRenameLayerTitle => 'Rename layer';

  @override
  String get sidebarLayerNameLabel => 'Layer name';

  @override
  String get sidebarDeleteLayerTitle => 'Delete layer?';

  @override
  String sidebarDeleteLayerMessage(String name) {
    return 'Delete \"$name\"? Its markers and zones will move to another layer.';
  }

  @override
  String get sidebarCollapseLayer => 'Collapse layer';

  @override
  String get sidebarExpandLayer => 'Expand layer';

  @override
  String get sidebarHideLayer => 'Hide layer';

  @override
  String get sidebarShowLayer => 'Show layer';

  @override
  String sidebarObjectCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objects',
      one: '1 object',
    );
    return '$_temp0';
  }

  @override
  String get sidebarSelectedForNewObjects => '· selected for new objects';

  @override
  String get sidebarMoveUp => 'Move up';

  @override
  String get sidebarMoveDown => 'Move down';

  @override
  String get sidebarTabMarkers => 'Markers';

  @override
  String get sidebarTabZones => 'Zones';

  @override
  String get sidebarViewList => 'List';

  @override
  String get sidebarViewTree => 'Tree';

  @override
  String get sidebarNoMatchingMarkers => 'No matching markers';

  @override
  String get sidebarNoMatchingZones => 'No matching zones';

  @override
  String get sidebarTryDifferentSearch => 'Try a different search term.';

  @override
  String get sidebarNoMarkersOnLayer => 'No markers on this layer';

  @override
  String get sidebarAddMarkerHint => 'Long-press the map to add a marker.';

  @override
  String get sidebarNoZonesOnLayer => 'No zones on this layer';

  @override
  String get sidebarAddZoneHint =>
      'Long-press the map and choose Line to draw one.';

  @override
  String get sidebarHideMarker => 'Hide marker';

  @override
  String get sidebarShowMarker => 'Show marker';

  @override
  String get sidebarEditMarker => 'Edit marker';

  @override
  String get sidebarDeleteMarker => 'Delete marker';

  @override
  String get sidebarHideNameOnMap => 'Hide name on map';

  @override
  String get sidebarShowNameOnMap => 'Show name on map';

  @override
  String get sidebarHideDistanceOnMap => 'Hide distance on map';

  @override
  String get sidebarShowDistanceOnMap => 'Show distance on map';

  @override
  String get sidebarHideLine => 'Hide line';

  @override
  String get sidebarShowLine => 'Show line';

  @override
  String get sidebarEditLine => 'Edit line';

  @override
  String get sidebarEditTrack => 'Edit track';

  @override
  String get sidebarDeleteTrack => 'Delete track';

  @override
  String get sidebarShowTrack => 'Show track';

  @override
  String get sidebarHideTrack => 'Hide track';

  @override
  String get sidebarDeleteLine => 'Delete line';

  @override
  String get sidebarHideCircle => 'Hide circle';

  @override
  String get sidebarShowCircle => 'Show circle';

  @override
  String get sidebarEditCircle => 'Edit circle';

  @override
  String get sidebarDeleteCircle => 'Delete circle';

  @override
  String get sidebarHideRectangle => 'Hide rectangle';

  @override
  String get sidebarShowRectangle => 'Show rectangle';

  @override
  String get sidebarEditRectangle => 'Edit rectangle';

  @override
  String get sidebarDeleteRectangle => 'Delete rectangle';

  @override
  String get sidebarHideZone => 'Hide zone';

  @override
  String get sidebarShowZone => 'Show zone';

  @override
  String get sidebarDeleteZone => 'Delete zone';

  @override
  String get searchReadinessReadySnackBar =>
      'Full search is ready — places and addresses.';

  @override
  String get searchReadinessCheckingTooltip => 'Checking search readiness…';

  @override
  String get searchReadinessUnavailableTooltip =>
      'Search readiness unavailable';

  @override
  String get searchReadinessFullReadyTooltip => 'Full search ready';

  @override
  String get searchReadinessBuildingTooltip => 'Building search indexes…';

  @override
  String get searchReadinessNotReadyTooltip => 'Full search not ready';

  @override
  String get searchReadinessGeocodingNotConfiguredTooltip =>
      'Geocoding server not configured';

  @override
  String get searchReadinessGeocodingUnavailableTooltip =>
      'Geocoding server unavailable';

  @override
  String searchReadinessImportInProgressTooltip(String phase) {
    return 'Import in progress: $phase';
  }

  @override
  String get searchReadinessImportPlacesDialogTitle =>
      'Place search data import';

  @override
  String get searchReadinessImportAddressesDialogTitle =>
      'Street address data import';

  @override
  String get searchReadinessFullReadyTitle => 'Full search ready';

  @override
  String get searchReadinessPlacesReadyTitle => 'Place search ready';

  @override
  String get searchReadinessAddressReadyTitle => 'Address search ready';

  @override
  String get searchReadinessWaitingForDataTitle => 'Waiting for geocoding data';

  @override
  String get searchReadinessNotReadyTitle => 'Search not ready yet';

  @override
  String searchReadinessIndexesBuilt(int ready, int total) {
    return 'Search indexes: $ready of $total';
  }

  @override
  String get searchReadinessCheckingStatus => 'Checking search status…';

  @override
  String get searchReadinessFullReadyMessage =>
      'You can search for places and street addresses from the map search bar.';

  @override
  String get searchReadinessPlacesOnlyMessage =>
      'You can search for place names from the map search bar. Import street address data in Settings → Geocoding to search addresses.';

  @override
  String get searchReadinessAddressOnlyMessage =>
      'You can search for street addresses from the map search bar. Import place data in Settings → Geocoding to search place names.';

  @override
  String get searchReadinessWaitingForDataMessage =>
      'Search indexes are ready. Import the missing datasets in Settings → Geocoding to enable search.';

  @override
  String get searchReadinessRequirementsTitle => 'Search requirements';

  @override
  String get searchReadinessRequirementPlacesData => 'Place data imported';

  @override
  String get searchReadinessRequirementAddressData =>
      'Street address data imported';

  @override
  String get searchReadinessRequirementIndexes => 'Search indexes built';

  @override
  String get searchReadinessRequirementReady => 'Ready';

  @override
  String get searchReadinessRequirementMissing => 'Not ready';

  @override
  String get searchReadinessPartialReadyTooltip => 'Partial search ready';

  @override
  String get searchReadinessPlacesOnlyTooltip => 'Place search ready';

  @override
  String searchReadinessPercentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String searchReadinessEta(String eta) {
    return 'Estimated time remaining: $eta';
  }

  @override
  String searchReadinessCurrentIndex(String name) {
    return 'Current index: $name';
  }

  @override
  String get searchReadinessServerUnreachable =>
      'Could not reach the server to check search status.';

  @override
  String get mapTilesReadyTooltip => 'Map tiles ready';

  @override
  String get mapTilesLoadingTooltip => 'Map tiles loading';

  @override
  String get mapTilesNotReadyTooltip => 'Map tiles not ready';

  @override
  String get mapTilesLoadingTitle => 'Loading map tiles';

  @override
  String get mapTilesCatalogLoadFailed => 'Failed to load map tile catalog.';

  @override
  String mapTilesOpeningLayer(String name) {
    return 'Opening: $name';
  }

  @override
  String get mapTilesLargeArchiveHelp =>
      'Large .pmtiles archives can take several minutes to open before tiles appear. Panning and zooming will fetch tiles as the map becomes ready.';

  @override
  String mapTilesLayersPrepared(int loaded, int enabled) {
    return 'Layers prepared: $loaded of $enabled';
  }

  @override
  String mapTilesActiveLayer(String name) {
    return 'Active layer: $name';
  }

  @override
  String get mapTilesReadyHelp =>
      'Tiles for the current map view should be visible. If the map is still blank, try zooming to the layer coverage area.';

  @override
  String mapTilesOpeningProgress(String name) {
    return 'Opening $name…';
  }

  @override
  String get greetingsConnected => 'You are connected';

  @override
  String get greetingsNameHint => 'Enter your name';

  @override
  String get greetingsSendToServer => 'Send to Server';

  @override
  String get greetingsNoResponse => 'No server response yet.';

  @override
  String get authSuccess => 'User authenticated.';

  @override
  String authFailed(String error) {
    return 'Authentication failed: $error';
  }

  @override
  String couldNotOpenLink(String url) {
    return 'Could not open link: $url';
  }

  @override
  String get geocodingAbortImport => 'Abort import';

  @override
  String get geocodingTitle => 'Geocoding';

  @override
  String get geocodingDescription =>
      'Download OSMNames data to the geocoding server for offline search. Place names and street addresses are imported separately.';

  @override
  String get geocodingServerConnectionTitle => 'Geocoding server';

  @override
  String get geocodingServerConnectionDescription =>
      'Separate from your main Wayfinder server. Run the geocoding stack on another machine when imports need a large database.';

  @override
  String get geocodingServerUrlLabel => 'Geocoding server web URL';

  @override
  String get geocodingSaveServerUrl => 'Save geocoding server URL';

  @override
  String get geocodingServerNotConfiguredMessage =>
      'Configure a geocoding server URL to enable place and address search. Restart the app after saving.';

  @override
  String get geocodingServerUrlSavedRestart =>
      'Geocoding server URL saved. Restart the app to connect.';

  @override
  String get geocodingServerUrlSaved => 'Geocoding server URL saved.';

  @override
  String get geocodingPlacesSectionTitle => 'Place names (geonames.tsv)';

  @override
  String get geocodingDownloadedDatasetsSectionTitle =>
      'Downloaded datasets (OSMNames)';

  @override
  String get geocodingDownloadedDatasetsSectionDescription =>
      'Large planet or regional imports from OSMNames. Custom locations above work without importing these.';

  @override
  String get geocodingPlaceDatasetLabel => 'Place dataset';

  @override
  String get geocodingCustomPlaceUrlLabel => 'Custom place data URL';

  @override
  String geocodingStatusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String geocodingLastSelection(String dataset) {
    return 'Last selection: $dataset';
  }

  @override
  String geocodingLastImport(String dateTime) {
    return 'Last import: $dateTime';
  }

  @override
  String get geocodingPlacesArchiveDescription =>
      'Archive place data as a JSON file, restore from a previous export, or remove all records from the server.';

  @override
  String get geocodingPlaceImportInProgress => 'Place import in progress…';

  @override
  String get geocodingDownloadImportPlaces => 'Download and import places';

  @override
  String get geocodingAddressesSectionTitle =>
      'Street addresses (housenumbers.tsv)';

  @override
  String get geocodingHousenumbersUrlLabel => 'Housenumbers data URL';

  @override
  String get geocodingAddressesArchiveDescription =>
      'Archive address data as a separate JSON file, restore from a previous export, or remove all records from the server.';

  @override
  String get geocodingAddressImportInProgress => 'Address import in progress…';

  @override
  String get geocodingDownloadImportHousenumbers =>
      'Download and import housenumbers';

  @override
  String get geocodingContributionsSectionTitle => 'Custom locations';

  @override
  String get geocodingContributionsSectionDescription =>
      'Add place names and coordinates that are not in OSMNames. These are stored separately from downloaded datasets and appear in search.';

  @override
  String get geocodingContributionsConfigureServerHint =>
      'Save a geocoding server URL above, then restart the app, to add and list custom locations.';

  @override
  String geocodingServerUnreachable(String url) {
    return 'Cannot reach the geocoding server. Check that it is running and that $url is reachable from your browser.';
  }

  @override
  String get geocodingContributionFormTitle => 'Add a location';

  @override
  String get geocodingContributionFormEditTitle => 'Edit location';

  @override
  String get geocodingContributionSaveAction => 'Save location';

  @override
  String get geocodingContributionClearForm => 'Clear form';

  @override
  String get geocodingContributionsListTitle => 'Saved locations';

  @override
  String get geocodingContributionsEmpty =>
      'No custom locations yet. Tap Add location to create one.';

  @override
  String get geocodingContributionsLoadFailed =>
      'Could not load custom locations. Update the geocoding server to the latest version.';

  @override
  String get geocodingContributionsFilterAll => 'All';

  @override
  String get geocodingContributionsFilterYours => 'Yours';

  @override
  String get geocodingContributionsFilterCommunity => 'Community';

  @override
  String get geocodingContributionsSourceYours => 'Added by you';

  @override
  String get geocodingContributionsSourceCommunity => 'From crowdsource';

  @override
  String get geocodingContributionAddTitle => 'Add location';

  @override
  String get geocodingContributionEditTitle => 'Edit location';

  @override
  String get geocodingContributionAddAction => 'Add location';

  @override
  String get geocodingContributionNameLabel => 'Name';

  @override
  String get geocodingContributionLatitudeLabel => 'Latitude';

  @override
  String get geocodingContributionLongitudeLabel => 'Longitude';

  @override
  String get geocodingContributionNotesLabel => 'Notes (optional)';

  @override
  String get geocodingContributionCountryLabel => 'Country (optional)';

  @override
  String get geocodingContributionCountryNone => 'None';

  @override
  String get geocodingContributionInvalidCoordinates =>
      'Enter valid latitude and longitude values.';

  @override
  String get geocodingContributionSaved => 'Location saved.';

  @override
  String get geocodingContributionDeleted => 'Location removed.';

  @override
  String get geocodingContributionDeleteTitle => 'Remove location?';

  @override
  String geocodingContributionDeleteMessage(String name) {
    return 'Remove \"$name\" from custom geocoding data?';
  }

  @override
  String get geocodingContributionImportedBadge => 'community';

  @override
  String get geocodingContributionsArchiveDescription =>
      'Export or import custom locations as a separate JSON file, or remove all custom records from the server.';

  @override
  String get geocodingContributionDataExported =>
      'Custom location data exported.';

  @override
  String get geocodingImportContributionArchiveTitle =>
      'Import custom locations?';

  @override
  String get geocodingImportContributionArchiveMessage =>
      'Merge locations from the selected file into the server. Existing entries with the same name and coordinates are updated.';

  @override
  String geocodingContributionArchiveImported(int count) {
    return 'Imported $count custom locations.';
  }

  @override
  String get geocodingRemoveAllContributionsTitle =>
      'Remove all custom locations?';

  @override
  String get geocodingRemoveAllContributionsMessage =>
      'This removes every custom location from the geocoding server. Downloaded OSMNames data is not affected.';

  @override
  String geocodingContributionsRemoved(int count) {
    return 'Removed $count custom locations.';
  }

  @override
  String get geocodingRowLabelContributions => 'locations';

  @override
  String get geocodingCrowdsourceSectionTitle => 'Crowdsource geocoding';

  @override
  String get geocodingCrowdsourceSectionDescription =>
      'Import anonymous community locations from a public git repository, or submit your local locations without sharing any personal information.';

  @override
  String get geocodingCrowdsourceUrlLabel => 'Crowdsource data URL';

  @override
  String get geocodingCrowdsourceUrlRequired => 'Enter a crowdsource data URL.';

  @override
  String get geocodingCrowdsourceSaveUrl => 'Save crowdsource URL';

  @override
  String get geocodingCrowdsourceUrlSaved => 'Crowdsource URL saved.';

  @override
  String get geocodingCrowdsourceImportAction => 'Import crowdsource data';

  @override
  String get geocodingCrowdsourceSubmitAction => 'Submit to crowdsource';

  @override
  String get geocodingCrowdsourceSubmitTitle => 'Submit anonymously?';

  @override
  String get geocodingCrowdsourceSubmitMessage =>
      'Only location names and coordinates are shared. No account information or personal identifiers are included.';

  @override
  String geocodingCrowdsourceImported(int count) {
    return 'Imported $count crowdsource locations.';
  }

  @override
  String geocodingCrowdsourceSubmitted(int count) {
    return 'Submitted $count anonymous locations to the crowdsource repository.';
  }

  @override
  String geocodingCrowdsourceBundleSaved(int count) {
    return 'Saved an anonymous bundle with $count locations. Submit it to the crowdsource repository manually.';
  }

  @override
  String geocodingSettingsLoadFailed(String error) {
    return 'Failed to load geocoding settings: $error';
  }

  @override
  String get geocodingStatusNotImported => 'Not imported';

  @override
  String get geocodingStatusDownloading => 'Downloading…';

  @override
  String get geocodingStatusImporting => 'Importing…';

  @override
  String geocodingStatusReady(String count, String label) {
    return 'Ready ($count $label)';
  }

  @override
  String get geocodingStatusFailed => 'Failed';

  @override
  String get geocodingStatusCancelled => 'Cancelled';

  @override
  String get geocodingCustomUrlLabel => 'Custom URL';

  @override
  String get geocodingRowLabelPlaces => 'places';

  @override
  String get geocodingRowLabelAddresses => 'addresses';

  @override
  String get geocodingRowLabelRows => 'rows';

  @override
  String geocodingImportProgress(
    String percent,
    String count,
    String rowLabel,
  ) {
    return '$percent% · $count $rowLabel imported';
  }

  @override
  String get geocodingImportPhaseDownloadingTitle => 'Downloading dataset';

  @override
  String get geocodingImportPhaseDownloadingDetail =>
      'Fetching the compressed place-name file from the internet.';

  @override
  String get geocodingImportPhaseImportingTitle => 'Reading place names';

  @override
  String get geocodingImportPhaseImportingDetail =>
      'Saving places to the server as they are read from the file.';

  @override
  String get geocodingImportPhaseImportingAddressesTitle =>
      'Reading street addresses';

  @override
  String get geocodingImportPhaseImportingAddressesDetail =>
      'Saving addresses to the server as they are read from the file.';

  @override
  String get geocodingImportPhaseFinalizingTitle => 'Wrapping up';

  @override
  String get geocodingImportPhaseFinalizingDetail =>
      'Saving the last batch before the final step.';

  @override
  String get geocodingImportPhaseCommittingTitle => 'Almost done';

  @override
  String geocodingImportPhaseCommittingDetail(String count, String rowLabel) {
    return 'All $count $rowLabel have been read. The server is now saving them for search. This can take one to three hours and the progress bar may pause here.';
  }

  @override
  String get geocodingImportDoNotRestartTitle => 'Keep the server running';

  @override
  String get geocodingImportDoNotRestartMessage =>
      'Do not restart or stop the server during this step. If you do, the import will be cancelled and you\'ll need to start over from the beginning.';

  @override
  String get geocodingSourceUrlRequired => 'Geocoding source URL is required.';

  @override
  String get geocodingPlanetImportStarted =>
      'Full planet place import started. This can take many hours.';

  @override
  String get geocodingPlaceImportStarted => 'Place-name import started.';

  @override
  String geocodingPlaceImportFailed(String error) {
    return 'Place import failed: $error';
  }

  @override
  String get geocodingPlaceImportAbortRequested =>
      'Place import abort requested. Existing data will be kept.';

  @override
  String geocodingAbortFailed(String error) {
    return 'Abort failed: $error';
  }

  @override
  String get geocodingHousenumbersUrlRequired =>
      'Housenumbers source URL is required.';

  @override
  String get geocodingHousenumbersImportStarted =>
      'Housenumbers import started. This can take many hours.';

  @override
  String geocodingHousenumbersImportFailed(String error) {
    return 'Housenumbers import failed: $error';
  }

  @override
  String get geocodingAddressImportAbortRequested =>
      'Address import abort requested. Existing data will be kept.';

  @override
  String get geocodingPlaceDataExported => 'Place data exported.';

  @override
  String get geocodingImportPlaceArchiveTitle => 'Import place archive?';

  @override
  String get geocodingImportPlaceArchiveMessage =>
      'This replaces all place-name records on the server with the selected archive file.';

  @override
  String geocodingPlaceArchiveImported(int count) {
    return 'Imported $count place record(s).';
  }

  @override
  String geocodingImportFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get geocodingRemoveAllPlacesTitle => 'Remove all place records?';

  @override
  String get geocodingRemoveAllPlacesMessage =>
      'This permanently deletes every place-name record from the server. This cannot be undone.';

  @override
  String geocodingPlacesRemoved(int count) {
    return 'Removed $count place record(s).';
  }

  @override
  String geocodingRemoveFailed(String error) {
    return 'Remove failed: $error';
  }

  @override
  String get geocodingHousenumberDataExported => 'Housenumber data exported.';

  @override
  String get geocodingImportHousenumberArchiveTitle =>
      'Import housenumber archive?';

  @override
  String get geocodingImportHousenumberArchiveMessage =>
      'This replaces all street-address records on the server with the selected archive file.';

  @override
  String geocodingHousenumberArchiveImported(int count) {
    return 'Imported $count address record(s).';
  }

  @override
  String get geocodingRemoveAllAddressesTitle => 'Remove all address records?';

  @override
  String get geocodingRemoveAllAddressesMessage =>
      'This permanently deletes every housenumber record from the server. This cannot be undone.';

  @override
  String geocodingAddressesRemoved(int count) {
    return 'Removed $count address record(s).';
  }

  @override
  String get geocodingPlanetImportWarning =>
      'The full planet import downloads about 1.4 GB and can take many hours to finish. For most users, start with the sample dataset or import a single country instead.';

  @override
  String get geocodingCountryImportDownloadNote =>
      'Country imports still download the global OSMNames file (~1.4 GB), but only the selected country is loaded into the database, so import finishes much sooner than the full planet.';

  @override
  String get geocodingHousenumbersImportWarning =>
      'The housenumbers file is separate from place names and is also about 1.4 GB compressed. Import can take many hours and loads street addresses (house number + street) worldwide. Place-name search and address search work independently.';

  @override
  String get geocodingDatasetSample => 'Sample (100k places)';

  @override
  String get geocodingDatasetSampleDescription =>
      'A small preview dataset. Best for testing search in a few minutes.';

  @override
  String get geocodingDatasetPlanet => 'Full planet (~23M places)';

  @override
  String get geocodingDatasetPlanetDescription =>
      'Imports every place in the OSMNames planet file. The download is about 1.4 GB compressed and the import can take many hours depending on your server hardware and network speed.';

  @override
  String get geocodingDatasetUs => 'United States';

  @override
  String get geocodingDatasetUsDescription =>
      'Downloads the global OSMNames file but only imports United States places. The download is still large, but the database import is much faster than the full planet.';

  @override
  String get geocodingDatasetCa => 'Canada';

  @override
  String get geocodingDatasetCaDescription =>
      'Downloads the global OSMNames file but only imports Canadian places.';

  @override
  String get geocodingDatasetMx => 'Mexico';

  @override
  String get geocodingDatasetGb => 'United Kingdom';

  @override
  String get geocodingDatasetDe => 'Germany';

  @override
  String get geocodingDatasetFr => 'France';

  @override
  String get geocodingDatasetEs => 'Spain';

  @override
  String get geocodingDatasetIt => 'Italy';

  @override
  String get geocodingDatasetNl => 'Netherlands';

  @override
  String get geocodingDatasetAu => 'Australia';

  @override
  String get geocodingDatasetNz => 'New Zealand';

  @override
  String get geocodingDatasetJp => 'Japan';

  @override
  String get geocodingDatasetBr => 'Brazil';

  @override
  String get geocodingDatasetIn => 'India';

  @override
  String get geocodingDatasetCustom => 'Custom URL…';

  @override
  String get geocodingDatasetCustomDescription =>
      'Provide your own OSMNames .tsv.gz URL.';

  @override
  String get mapRadialMarker => 'Marker';

  @override
  String get mapRadialLine => 'Line';

  @override
  String get mapRadialCircle => 'Circle';

  @override
  String get mapRadialRectCenter => 'Rect center';

  @override
  String get mapRadialRectCorners => 'Rect corners';

  @override
  String get mapRadialCopyCoordinates => 'Copy coordinates';

  @override
  String get mapCoordinatesCopied => 'Coordinates copied to clipboard.';

  @override
  String get mapMarkerShareUrlLabel => 'Link';

  @override
  String get mapMarkerCopyUrlTooltip => 'Copy marker link';

  @override
  String get mapMarkerUrlCopied => 'Marker link copied to clipboard.';

  @override
  String get mapMarkerIdLabel => 'Marker ID';

  @override
  String get mapMarkerCopyIdTooltip => 'Copy marker ID';

  @override
  String get mapMarkerIdCopied => 'Marker ID copied to clipboard.';

  @override
  String get mapRelativeAngleLabel => 'Rel°';

  @override
  String get sortName => 'Name';

  @override
  String get sortHue => 'Hue';

  @override
  String get sortIcon => 'Icon';

  @override
  String get sortVisibility => 'Visibility';

  @override
  String get sortType => 'Type';

  @override
  String get sortGroupVisible => 'Visible';

  @override
  String get sortGroupHidden => 'Hidden';

  @override
  String get sortGroupOther => 'Other';

  @override
  String get sidebarSortMarkers => 'Sort markers';

  @override
  String get sidebarSortZones => 'Sort zones';

  @override
  String get rectangleSizeDimensions => 'Dimensions';

  @override
  String get rectangleSizeArea => 'Area';

  @override
  String get rectangleSizeNone => 'None';

  @override
  String get rectangleSizeDimensionsShort => 'W×H';

  @override
  String get rectangleModeCenter => 'Center rectangle';

  @override
  String get rectangleModeCorners => 'Corner rectangle';

  @override
  String get mapObjectTypeRectangle => 'Rectangle';

  @override
  String get searchSubtitleCoordinates => 'Coordinates';

  @override
  String get searchSubtitleMarker => 'Marker';

  @override
  String searchSubtitleZone(String type) {
    return 'Zone ($type)';
  }

  @override
  String searchHint(String example) {
    return 'Search places, markers, zones, or lat, lng (e.g. $example)';
  }

  @override
  String get sortGroupDigits => '0-9';

  @override
  String get markerIconPlace => 'Place';

  @override
  String get markerIconHome => 'Home';

  @override
  String get markerIconHouse => 'House';

  @override
  String get markerIconApartment => 'Apartment';

  @override
  String get markerIconWork => 'Work';

  @override
  String get markerIconSchool => 'School';

  @override
  String get markerIconStore => 'Store';

  @override
  String get markerIconFood => 'Food';

  @override
  String get markerIconCafe => 'Cafe';

  @override
  String get markerIconHotel => 'Hotel';

  @override
  String get markerIconChurch => 'Church';

  @override
  String get markerIconMosque => 'Mosque';

  @override
  String get markerIconCommunity => 'Community';

  @override
  String get markerIconMedical => 'Medical';

  @override
  String get markerIconVehicle => 'Vehicle';

  @override
  String get markerIconBike => 'Bike';

  @override
  String get markerIconTrail => 'Trail';

  @override
  String get markerIconPark => 'Park';

  @override
  String get markerIconMonument => 'Monument';

  @override
  String get markerIconGeocache => 'Geocache';

  @override
  String get markerIconFlag => 'Flag';

  @override
  String get markerIconStar => 'Star';

  @override
  String get markerIconFavorite => 'Favorite';

  @override
  String get markerIconWarning => 'Warning';

  @override
  String get markerIconInfo => 'Info';

  @override
  String get markerIconLocation => 'Location';

  @override
  String get markerIconPhoto => 'Photo';

  @override
  String get markerIconPets => 'Pets';

  @override
  String get markerIconMan => 'Man';

  @override
  String get markerIconWoman => 'Woman';

  @override
  String get markerIconBoy => 'Boy';

  @override
  String get markerIconGirl => 'Girl';

  @override
  String get markerIconCat => 'Cat';

  @override
  String get markerIconDog => 'Dog';

  @override
  String get markerIconRadioTower => 'Radio tower';

  @override
  String get markerIconRadioRepeater => 'Radio repeater';

  @override
  String get markerIconWater => 'Water';

  @override
  String get markerIconSupplyCache => 'Supply cache';

  @override
  String get markerIconRetreat => 'Retreat';

  @override
  String get markerIconCamp => 'Camp';

  @override
  String get markerIconFuel => 'Fuel';

  @override
  String get markerIconGate => 'Gate';

  @override
  String get markerIconCrossing => 'Crossing';

  @override
  String get markerIconLookout => 'Lookout';

  @override
  String get markerIconPower => 'Power';

  @override
  String get markerIconPowerPlant => 'Power plant';

  @override
  String get markerIconNuclearPowerPlant => 'Nuclear power plant';

  @override
  String get markerIconNuclearWeaponsFacility => 'Nuclear weapons facility';

  @override
  String get markerIconGarden => 'Garden';

  @override
  String get markerIconStaging => 'Staging';

  @override
  String get markerIconHazard => 'Hazard';

  @override
  String get markerIconRestricted => 'Restricted';

  @override
  String get markerIconRally => 'Rally point';

  @override
  String get markerIconWorkshop => 'Workshop';

  @override
  String get markerIconBoat => 'Boat';

  @override
  String get markerIconPort => 'Port';

  @override
  String get markerIconDock => 'Lake dock';

  @override
  String get markerIconFerry => 'Ferry';

  @override
  String get markerIconYacht => 'Yacht';

  @override
  String get markerIconSailboat => 'Sailboat';

  @override
  String get markerIconRiverBoat => 'River boat';

  @override
  String get markerIconAirstrip => 'Airstrip / Airport';

  @override
  String get markerIconDefense => 'Defense';

  @override
  String get markerIconArmyBase => 'Army base';

  @override
  String get markerIconNavyBase => 'Navy base';

  @override
  String get markerIconMarineCorpsBase => 'Marine Corps base';

  @override
  String get markerIconAirForceBase => 'Air Force base';

  @override
  String get markerIconSpaceForceBase => 'Space Force base';

  @override
  String get markerIconCoastGuardBase => 'Coast Guard base';

  @override
  String get markerIconHunting => 'Hunting';

  @override
  String get markerIconFishing => 'Fishing';

  @override
  String get markerIconCave => 'Cave';

  @override
  String get markerIconDeadZone => 'Dead zone';

  @override
  String get markerIconEvacRoute => 'Evac route';

  @override
  String get markerIconLivestock => 'Livestock';

  @override
  String get markerIconPharmacy => 'Pharmacy';

  @override
  String get settingsRestApiTitle => 'REST API access';

  @override
  String get settingsRestApiDescription =>
      'Protect the /api REST endpoints with named API keys. Create a separate key for each app or device so you can remove one without affecting the others.';

  @override
  String get settingsRestApiStatusLabel => 'Protection';

  @override
  String get settingsRestApiStatusEnabled => 'Enabled';

  @override
  String get settingsRestApiStatusDisabled => 'Disabled';

  @override
  String get settingsRestApiKeysTitle => 'API keys';

  @override
  String get settingsRestApiKeysEmpty =>
      'No API keys yet. Create one for each app or device that calls the REST API.';

  @override
  String get settingsRestApiCreateAction => 'Create API key';

  @override
  String get settingsRestApiCreateNameLabel => 'Application name';

  @override
  String get settingsRestApiCreateNameHint =>
      'e.g. GPS tracker, Home automation';

  @override
  String get settingsRestApiDeleteAction => 'Remove';

  @override
  String get settingsRestApiDeleteConfirmTitle => 'Remove API key?';

  @override
  String settingsRestApiDeleteConfirmMessage(String name) {
    return 'The key \"$name\" will stop working immediately. Other keys are unaffected.';
  }

  @override
  String get settingsRestApiDeleted => 'API key removed.';

  @override
  String get settingsRestApiEnvKeyNote =>
      'An environment API key is also configured on the server. It cannot be removed from this screen.';

  @override
  String get settingsRestApiClearAction => 'Remove all keys';

  @override
  String get settingsRestApiClearConfirmTitle => 'Remove all API keys?';

  @override
  String get settingsRestApiClearConfirmMessage =>
      'Every stored API key will be deleted. The REST API will be open again unless an environment key is configured.';

  @override
  String get settingsRestApiCleared => 'All stored API keys removed.';

  @override
  String get settingsRestApiGeneratedTitle => 'New API key';

  @override
  String settingsRestApiGeneratedFor(String name) {
    return 'Created for $name.';
  }

  @override
  String get settingsRestApiGeneratedMessage =>
      'Copy this key now. It is shown only once. Use it as X-API-Key or Authorization: Bearer <key>.';

  @override
  String get settingsRestApiCopyAction => 'Copy key';

  @override
  String get settingsRestApiCopied => 'API key copied.';

  @override
  String settingsRestApiLoadFailed(String error) {
    return 'Could not load REST API settings: $error';
  }

  @override
  String get settingsRestApiClientKeyTitle => 'Key on this device';

  @override
  String get settingsRestApiClientKeyDescription =>
      'Store the API key here so this app can call REST fallbacks (backup restore, settings sync, etc.).';

  @override
  String get settingsRestApiClientKeyLabel => 'API key';

  @override
  String get settingsRestApiSaveClientKeyAction => 'Save key on this device';

  @override
  String get settingsRestApiKeySaved => 'API key saved on this device.';
}
