import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// Application name shown in the window title.
  ///
  /// In en, this message translates to:
  /// **'Wayfinder'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTabGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsTabGeneral;

  /// No description provided for @settingsTabMapTiles.
  ///
  /// In en, this message translates to:
  /// **'Map tiles'**
  String get settingsTabMapTiles;

  /// No description provided for @settingsTabMarkerIcons.
  ///
  /// In en, this message translates to:
  /// **'Marker icons'**
  String get settingsTabMarkerIcons;

  /// No description provided for @settingsTabGeocoding.
  ///
  /// In en, this message translates to:
  /// **'Geocoding'**
  String get settingsTabGeocoding;

  /// No description provided for @settingsTabBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsTabBackup;

  /// No description provided for @settingsTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsTabAbout;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Wayfinder'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Read-only build and connection details for this client. Use the git commit to confirm whether the latest build is running.'**
  String get settingsAboutDescription;

  /// No description provided for @settingsAboutOpenManual.
  ///
  /// In en, this message translates to:
  /// **'Open user manual'**
  String get settingsAboutOpenManual;

  /// No description provided for @settingsAboutLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading app info…'**
  String get settingsAboutLoading;

  /// No description provided for @settingsAboutLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load app info: {error}'**
  String settingsAboutLoadFailed(String error);

  /// No description provided for @settingsAboutAppSection.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settingsAboutAppSection;

  /// No description provided for @settingsAboutConnectionSection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsAboutConnectionSection;

  /// No description provided for @settingsAboutDeploymentSection.
  ///
  /// In en, this message translates to:
  /// **'Deployment'**
  String get settingsAboutDeploymentSection;

  /// No description provided for @settingsAboutDockerImageId.
  ///
  /// In en, this message translates to:
  /// **'Docker image ID'**
  String get settingsAboutDockerImageId;

  /// No description provided for @settingsAboutDockerImageIdUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available — recreate the container after pulling so the image ID is recorded at startup.'**
  String get settingsAboutDockerImageIdUnavailable;

  /// No description provided for @settingsAboutDockerImageRef.
  ///
  /// In en, this message translates to:
  /// **'Docker image reference'**
  String get settingsAboutDockerImageRef;

  /// No description provided for @settingsAboutContainerStarted.
  ///
  /// In en, this message translates to:
  /// **'Container started'**
  String get settingsAboutContainerStarted;

  /// No description provided for @settingsAboutDockerImageIdHint.
  ///
  /// In en, this message translates to:
  /// **'The Docker image ID changes whenever you pull a new build. It should start with {imageIdPrefix} and match the IMAGE ID column from docker compose images or docker image inspect.'**
  String settingsAboutDockerImageIdHint(String imageIdPrefix);

  /// No description provided for @settingsAboutDockerImageIdHintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'After docker compose pull, run docker compose up -d --force-recreate so the container records the current image ID here. The ID changes on every new image build even when the tag stays :latest.'**
  String get settingsAboutDockerImageIdHintUnavailable;

  /// No description provided for @settingsAboutAppName.
  ///
  /// In en, this message translates to:
  /// **'App name'**
  String get settingsAboutAppName;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsAboutVersion;

  /// No description provided for @settingsAboutGitCommit.
  ///
  /// In en, this message translates to:
  /// **'Git commit'**
  String get settingsAboutGitCommit;

  /// No description provided for @settingsAboutGitCommitUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available (local dev build)'**
  String get settingsAboutGitCommitUnavailable;

  /// No description provided for @settingsAboutBuildTime.
  ///
  /// In en, this message translates to:
  /// **'Built'**
  String get settingsAboutBuildTime;

  /// No description provided for @settingsAboutPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get settingsAboutPlatform;

  /// No description provided for @settingsAboutPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get settingsAboutPackage;

  /// No description provided for @settingsAboutApiServer.
  ///
  /// In en, this message translates to:
  /// **'API server'**
  String get settingsAboutApiServer;

  /// No description provided for @settingsAboutWebServer.
  ///
  /// In en, this message translates to:
  /// **'Web server'**
  String get settingsAboutWebServer;

  /// No description provided for @settingsAboutGeocodingServer.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server'**
  String get settingsAboutGeocodingServer;

  /// No description provided for @settingsAboutGeocodingServerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get settingsAboutGeocodingServerNotConfigured;

  /// No description provided for @settingsAboutCommitHint.
  ///
  /// In en, this message translates to:
  /// **'Deployed builds include a git commit (for example {commit}). Compare it to the latest commit on main or the image tag you pulled.'**
  String settingsAboutCommitHint(String commit);

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get actionLater;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionReloadNow.
  ///
  /// In en, this message translates to:
  /// **'Reload now'**
  String get actionReloadNow;

  /// No description provided for @actionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get actionSaving;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @actionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// No description provided for @actionRemoveAll.
  ///
  /// In en, this message translates to:
  /// **'Remove all'**
  String get actionRemoveAll;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get actionOpenSettings;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get actionSignOut;

  /// No description provided for @actionUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get actionUploading;

  /// No description provided for @actionExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get actionExporting;

  /// No description provided for @actionImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get actionImporting;

  /// No description provided for @actionRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get actionRestoring;

  /// No description provided for @actionAborting.
  ///
  /// In en, this message translates to:
  /// **'Aborting…'**
  String get actionAborting;

  /// No description provided for @statusLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get statusLoading;

  /// No description provided for @statusWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get statusWorking;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsAppearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a color theme for the app. Military themes use olive, tan, and forest green tones. Stored on the server so every browser uses the same theme.'**
  String get settingsAppearanceDescription;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout the app. Stored on the server so every browser uses the same language.'**
  String get settingsLanguageDescription;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @settingsThemeStyle.
  ///
  /// In en, this message translates to:
  /// **'Theme style'**
  String get settingsThemeStyle;

  /// No description provided for @settingsBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get settingsBrightness;

  /// No description provided for @settingsMapHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Map home'**
  String get settingsMapHomeTitle;

  /// No description provided for @settingsMapHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Coordinates and zoom for the home button on the map. Stored on the server so all clients share the same home location. Also used as the starting view when no previous map position is saved.'**
  String get settingsMapHomeDescription;

  /// No description provided for @settingsLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get settingsLatitude;

  /// No description provided for @settingsLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get settingsLongitude;

  /// No description provided for @settingsZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get settingsZoom;

  /// No description provided for @settingsZoomHelper.
  ///
  /// In en, this message translates to:
  /// **'0–{maxZoom}'**
  String settingsZoomHelper(String maxZoom);

  /// No description provided for @settingsSaveHome.
  ///
  /// In en, this message translates to:
  /// **'Save home'**
  String get settingsSaveHome;

  /// No description provided for @settingsUseCurrentMapView.
  ///
  /// In en, this message translates to:
  /// **'Use current map view'**
  String get settingsUseCurrentMapView;

  /// No description provided for @settingsResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get settingsResetToDefault;

  /// No description provided for @settingsServerConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Server connection'**
  String get settingsServerConnectionTitle;

  /// No description provided for @settingsServerConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Wayfinder API server URL, including host and port. The web server URL (REST API and PMTiles) is derived automatically (API port + 2). Restart the app after changing this.'**
  String get settingsServerConnectionDescription;

  /// No description provided for @settingsServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get settingsServerUrl;

  /// No description provided for @settingsCurrentWebServer.
  ///
  /// In en, this message translates to:
  /// **'Current web server: {webUrl}'**
  String settingsCurrentWebServer(String webUrl);

  /// No description provided for @settingsSaveServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Save server URL'**
  String get settingsSaveServerUrl;

  /// No description provided for @settingsMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get settingsMeasurementsTitle;

  /// No description provided for @settingsMeasurementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how line distances are displayed on the map. Stored on the server so every browser uses the same units.'**
  String get settingsMeasurementsDescription;

  /// No description provided for @settingsAnglesTitle.
  ///
  /// In en, this message translates to:
  /// **'Angles'**
  String get settingsAnglesTitle;

  /// No description provided for @settingsAnglesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how relative angles are displayed on the map and in bearing plots. Stored on the server so every browser uses the same format.'**
  String get settingsAnglesDescription;

  /// No description provided for @lineArrowDensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrow frequency'**
  String get lineArrowDensityLabel;

  /// No description provided for @lineArrowDensitySparse.
  ///
  /// In en, this message translates to:
  /// **'Sparse'**
  String get lineArrowDensitySparse;

  /// No description provided for @lineArrowDensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lineArrowDensityLight;

  /// No description provided for @lineArrowDensityBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get lineArrowDensityBalanced;

  /// No description provided for @lineArrowDensityFrequent.
  ///
  /// In en, this message translates to:
  /// **'Frequent'**
  String get lineArrowDensityFrequent;

  /// No description provided for @lineArrowDensityDense.
  ///
  /// In en, this message translates to:
  /// **'Dense'**
  String get lineArrowDensityDense;

  /// No description provided for @settingsCirclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get settingsCirclesTitle;

  /// No description provided for @settingsCirclesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the default size label shown on new circular zones. Stored on the server so every browser uses the same default.'**
  String get settingsCirclesDescription;

  /// No description provided for @settingsMapDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Map display'**
  String get settingsMapDisplayTitle;

  /// No description provided for @settingsMapDisplayDescription.
  ///
  /// In en, this message translates to:
  /// **'Map overlays stored on the server.'**
  String get settingsMapDisplayDescription;

  /// No description provided for @settingsMapCompassRoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Show compass rose'**
  String get settingsMapCompassRoseTitle;

  /// No description provided for @settingsMapCompassRoseDescription.
  ///
  /// In en, this message translates to:
  /// **'Displays a north-oriented compass in the upper-left corner of the map.'**
  String get settingsMapCompassRoseDescription;

  /// No description provided for @settingsMapMgrsGridTitle.
  ///
  /// In en, this message translates to:
  /// **'Show MGRS grid'**
  String get settingsMapMgrsGridTitle;

  /// No description provided for @settingsMapMgrsGridDescription.
  ///
  /// In en, this message translates to:
  /// **'Overlays true MGRS (UTM-based) grid lines. Spacing follows zoom. Zone seams and slight curvature on the Web Mercator map are expected — MGRS squares are not lat/lng rectangles.'**
  String get settingsMapMgrsGridDescription;

  /// No description provided for @settingsMapZoomRangeWarning.
  ///
  /// In en, this message translates to:
  /// **'Changing the zoom range can slow the map, increase memory use, or show stretched tiles when your offline data does not include detail at those levels. Only raise the maximum if your map archives support it.'**
  String get settingsMapZoomRangeWarning;

  /// No description provided for @settingsMapMinZoom.
  ///
  /// In en, this message translates to:
  /// **'Minimum zoom'**
  String get settingsMapMinZoom;

  /// No description provided for @settingsMapMaxZoom.
  ///
  /// In en, this message translates to:
  /// **'Maximum zoom'**
  String get settingsMapMaxZoom;

  /// No description provided for @settingsMapZoomLimitHelper.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max}'**
  String settingsMapZoomLimitHelper(String min, String max);

  /// No description provided for @settingsMapZoomRangeSave.
  ///
  /// In en, this message translates to:
  /// **'Save zoom range'**
  String get settingsMapZoomRangeSave;

  /// No description provided for @settingsMapZoomRangeSaved.
  ///
  /// In en, this message translates to:
  /// **'Map zoom range saved.'**
  String get settingsMapZoomRangeSaved;

  /// No description provided for @settingsMapZoomRangeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid minimum and maximum zoom values.'**
  String get settingsMapZoomRangeInvalid;

  /// No description provided for @settingsMapZoomRangeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save map zoom range: {error}'**
  String settingsMapZoomRangeSaveFailed(String error);

  /// No description provided for @settingsMapDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Map debugging'**
  String get settingsMapDebugTitle;

  /// No description provided for @settingsMapDebugDescription.
  ///
  /// In en, this message translates to:
  /// **'Visual aids stored in this browser only.'**
  String get settingsMapDebugDescription;

  /// No description provided for @settingsMapMarkerSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Map marker size'**
  String get settingsMapMarkerSizeTitle;

  /// No description provided for @settingsMapMarkerSizeDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust how large markers appear on the map. Included in server backups.'**
  String get settingsMapMarkerSizeDescription;

  /// No description provided for @settingsMapMarkerSizeValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String settingsMapMarkerSizeValue(int percent);

  /// No description provided for @settingsMapMarkerSizeMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get settingsMapMarkerSizeMinLabel;

  /// No description provided for @settingsMapMarkerSizeMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Larger'**
  String get settingsMapMarkerSizeMaxLabel;

  /// No description provided for @settingsMapViewportDebugBorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Show map viewport border'**
  String get settingsMapViewportDebugBorderTitle;

  /// No description provided for @settingsMapViewportDebugBorderDescription.
  ///
  /// In en, this message translates to:
  /// **'Draws a red outline around the map canvas with archive, zoom, and center-tile details.'**
  String get settingsMapViewportDebugBorderDescription;

  /// No description provided for @settingsMapTileBorderDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Show tile borders'**
  String get settingsMapTileBorderDebugTitle;

  /// No description provided for @settingsMapTileBorderDebugDescription.
  ///
  /// In en, this message translates to:
  /// **'Draws green borders around each map tile. Requires the viewport debug overlay above.'**
  String get settingsMapTileBorderDebugDescription;

  /// No description provided for @mapDebugOverlayCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy debug info'**
  String get mapDebugOverlayCopyTooltip;

  /// No description provided for @mapDebugOverlayCopied.
  ///
  /// In en, this message translates to:
  /// **'Debug info copied to clipboard.'**
  String get mapDebugOverlayCopied;

  /// No description provided for @mapDebugOverlayCopyFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy blocked — select and copy manually'**
  String get mapDebugOverlayCopyFailedTitle;

  /// No description provided for @settingsHomeLocationSaved.
  ///
  /// In en, this message translates to:
  /// **'Home location saved.'**
  String get settingsHomeLocationSaved;

  /// No description provided for @settingsHomeLocationReset.
  ///
  /// In en, this message translates to:
  /// **'Home location reset to default.'**
  String get settingsHomeLocationReset;

  /// No description provided for @settingsOpenMapFirst.
  ///
  /// In en, this message translates to:
  /// **'Open the map first to capture its view.'**
  String get settingsOpenMapFirst;

  /// No description provided for @settingsHomeLocationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid numbers for latitude, longitude, and zoom.'**
  String get settingsHomeLocationInvalid;

  /// No description provided for @settingsHomeLocationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save home location: {error}'**
  String settingsHomeLocationSaveFailed(String error);

  /// No description provided for @settingsRestartRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart required'**
  String get settingsRestartRequiredTitle;

  /// No description provided for @settingsRestartRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Server URL saved.\n\nAPI: {apiUrl}\nWeb: {webUrl}\n\nRestart the app to connect to the new server.'**
  String settingsRestartRequiredMessage(String apiUrl, String webUrl);

  /// No description provided for @settingsServerUrlReset.
  ///
  /// In en, this message translates to:
  /// **'Server URL reset to default. Restart the app to apply.'**
  String get settingsServerUrlReset;

  /// No description provided for @settingsServerUrlSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save server URL: {error}'**
  String settingsServerUrlSaveFailed(String error);

  /// No description provided for @themePreviewPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get themePreviewPrimary;

  /// No description provided for @themePreviewSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get themePreviewSecondary;

  /// No description provided for @themePreviewSurface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get themePreviewSurface;

  /// No description provided for @themePreviewAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get themePreviewAccent;

  /// No description provided for @themePreviewButton.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get themePreviewButton;

  /// No description provided for @themePreviewOutline.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get themePreviewOutline;

  /// No description provided for @themeFamilyStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get themeFamilyStandard;

  /// No description provided for @themeFamilyMilitary.
  ///
  /// In en, this message translates to:
  /// **'Military'**
  String get themeFamilyMilitary;

  /// No description provided for @themeBrightnessLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeBrightnessLight;

  /// No description provided for @themeBrightnessDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeBrightnessDark;

  /// No description provided for @themeChoiceMilitaryLight.
  ///
  /// In en, this message translates to:
  /// **'Military light'**
  String get themeChoiceMilitaryLight;

  /// No description provided for @themeChoiceMilitaryDark.
  ///
  /// In en, this message translates to:
  /// **'Military dark'**
  String get themeChoiceMilitaryDark;

  /// No description provided for @measurementMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get measurementMetric;

  /// No description provided for @measurementImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get measurementImperial;

  /// No description provided for @measurementNautical.
  ///
  /// In en, this message translates to:
  /// **'Nautical'**
  String get measurementNautical;

  /// No description provided for @measurementMetricShort.
  ///
  /// In en, this message translates to:
  /// **'m/km'**
  String get measurementMetricShort;

  /// No description provided for @measurementImperialShort.
  ///
  /// In en, this message translates to:
  /// **'ft/mi'**
  String get measurementImperialShort;

  /// No description provided for @measurementNauticalShort.
  ///
  /// In en, this message translates to:
  /// **'nm'**
  String get measurementNauticalShort;

  /// No description provided for @angleFormatDecimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal degrees'**
  String get angleFormatDecimal;

  /// No description provided for @angleFormatDms.
  ///
  /// In en, this message translates to:
  /// **'Degrees, minutes, seconds'**
  String get angleFormatDms;

  /// No description provided for @angleFormatDecimalShort.
  ///
  /// In en, this message translates to:
  /// **'DD'**
  String get angleFormatDecimalShort;

  /// No description provided for @angleFormatDmsShort.
  ///
  /// In en, this message translates to:
  /// **'DMS'**
  String get angleFormatDmsShort;

  /// No description provided for @circleSizeRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get circleSizeRadius;

  /// No description provided for @circleSizeDiameter.
  ///
  /// In en, this message translates to:
  /// **'Diameter'**
  String get circleSizeDiameter;

  /// No description provided for @circleSizeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get circleSizeNone;

  /// No description provided for @circleSizeToggleRadius.
  ///
  /// In en, this message translates to:
  /// **'Showing radius on map · tap for diameter'**
  String get circleSizeToggleRadius;

  /// No description provided for @circleSizeToggleDiameter.
  ///
  /// In en, this message translates to:
  /// **'Showing diameter on map · tap for none'**
  String get circleSizeToggleDiameter;

  /// No description provided for @circleSizeToggleNone.
  ///
  /// In en, this message translates to:
  /// **'Size hidden on map · tap for radius'**
  String get circleSizeToggleNone;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Map data backup'**
  String get backupTitle;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or restore all layers, markers, zones, and custom marker icons. Backups are saved as a .zip file containing backup.json plus marker-icons/*.svg files. Legacy .json backups can still be restored.'**
  String get backupDescription;

  /// No description provided for @backupExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export map data (.zip)'**
  String get backupExportButton;

  /// No description provided for @backupRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get backupRestoreButton;

  /// No description provided for @backupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Map data backup saved.'**
  String get backupExportSuccess;

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore map data?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces all layers, markers, zones, and custom marker icons on the server with the selected backup file. This cannot be undone.'**
  String get backupRestoreConfirmMessage;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {layers} layer(s), {markers} marker(s), and {zones} zone(s).'**
  String backupRestoreSuccess(int layers, int markers, int zones);

  /// No description provided for @backupRestoreSuccessWithIcons.
  ///
  /// In en, this message translates to:
  /// **'Restored {layers} layer(s), {markers} marker(s), {zones} zone(s), and {icons} custom icon(s).'**
  String backupRestoreSuccessWithIcons(
    int layers,
    int markers,
    int zones,
    int icons,
  );

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String backupRestoreFailed(String error);

  /// No description provided for @geoExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'GPX / KML / GeoJSON'**
  String get geoExchangeTitle;

  /// No description provided for @geoExchangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Import waypoints and tracks from GPX, KML, or GeoJSON (adds markers and lines without replacing existing data). Export markers as waypoints and lines/tracks as paths.'**
  String get geoExchangeDescription;

  /// No description provided for @geoExchangeImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import geographic file'**
  String get geoExchangeImportButton;

  /// No description provided for @geoExchangeExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export geographic file'**
  String get geoExchangeExportButton;

  /// No description provided for @geoExchangeExportFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get geoExchangeExportFormatTitle;

  /// No description provided for @geoExchangeImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {markers} marker(s) and {lines} line(s).'**
  String geoExchangeImportSuccess(int markers, int lines);

  /// No description provided for @geoExchangeImportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No waypoints or tracks found in that file.'**
  String get geoExchangeImportEmpty;

  /// No description provided for @geoExchangeImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String geoExchangeImportFailed(String error);

  /// No description provided for @geoExchangeExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Geographic export saved.'**
  String get geoExchangeExportSuccess;

  /// No description provided for @geoExchangeExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export — add markers or lines first.'**
  String get geoExchangeExportEmpty;

  /// No description provided for @geoExchangeExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String geoExchangeExportFailed(String error);

  /// No description provided for @geoExchangeFormatGpx.
  ///
  /// In en, this message translates to:
  /// **'GPX'**
  String get geoExchangeFormatGpx;

  /// No description provided for @geoExchangeFormatKml.
  ///
  /// In en, this message translates to:
  /// **'KML'**
  String get geoExchangeFormatKml;

  /// No description provided for @geoExchangeFormatGeojson.
  ///
  /// In en, this message translates to:
  /// **'GeoJSON'**
  String get geoExchangeFormatGeojson;

  /// No description provided for @mapTilesFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'PMTiles folder'**
  String get mapTilesFolderTitle;

  /// No description provided for @mapTilesFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Folder on the server containing .pmtiles archives. Stored in the database so every client uses the same map tile library after restart.'**
  String get mapTilesFolderDescription;

  /// No description provided for @mapTilesStoragePathLabel.
  ///
  /// In en, this message translates to:
  /// **'PMTiles storage path'**
  String get mapTilesStoragePathLabel;

  /// No description provided for @mapTilesStoragePathRequired.
  ///
  /// In en, this message translates to:
  /// **'PMTiles storage path is required.'**
  String get mapTilesStoragePathRequired;

  /// No description provided for @mapTilesSaveAndRescan.
  ///
  /// In en, this message translates to:
  /// **'Save and rescan folder'**
  String get mapTilesSaveAndRescan;

  /// No description provided for @mapTilesFolderSaved.
  ///
  /// In en, this message translates to:
  /// **'PMTiles folder saved. Resynced from {path}.'**
  String mapTilesFolderSaved(String path);

  /// No description provided for @mapTilesFolderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save PMTiles folder: {error}'**
  String mapTilesFolderSaveFailed(String error);

  /// No description provided for @mapTilesMapsTitle.
  ///
  /// In en, this message translates to:
  /// **'PMTiles Maps'**
  String get mapTilesMapsTitle;

  /// No description provided for @mapTilesMapsDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize offline map archives into groups and choose which ones are drawn on the map. Only the best-matching enabled archive is shown at once to keep the map responsive.'**
  String get mapTilesMapsDescription;

  /// No description provided for @mapTilesUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload .pmtiles file'**
  String get mapTilesUploadButton;

  /// No description provided for @mapTilesUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'PMTiles file uploaded: {name}'**
  String mapTilesUploadSuccess(String name);

  /// No description provided for @mapTilesUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String mapTilesUploadFailed(String error);

  /// No description provided for @mapTilesAllHidden.
  ///
  /// In en, this message translates to:
  /// **'All map tiles hidden from the map.'**
  String get mapTilesAllHidden;

  /// No description provided for @mapTilesNewGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'New tile group'**
  String get mapTilesNewGroupTitle;

  /// No description provided for @mapTilesGroupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get mapTilesGroupNameLabel;

  /// No description provided for @mapTilesGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mid-Atlantic states'**
  String get mapTilesGroupNameHint;

  /// No description provided for @mapTilesGroupCreated.
  ///
  /// In en, this message translates to:
  /// **'Created group \"{name}\".'**
  String mapTilesGroupCreated(String name);

  /// No description provided for @mapTilesGroupCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create group: {error}'**
  String mapTilesGroupCreateFailed(String error);

  /// No description provided for @mapTilesDeleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete tile group?'**
  String get mapTilesDeleteGroupTitle;

  /// No description provided for @mapTilesDeleteGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Files in this group will become ungrouped.'**
  String mapTilesDeleteGroupMessage(String name);

  /// No description provided for @mapTilesDeleteFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete PMTiles file?'**
  String get mapTilesDeleteFileTitle;

  /// No description provided for @mapTilesDeleteFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the server?'**
  String mapTilesDeleteFileMessage(String name);

  /// No description provided for @mapTilesFileDeleted.
  ///
  /// In en, this message translates to:
  /// **'PMTiles file deleted.'**
  String get mapTilesFileDeleted;

  /// No description provided for @mapTilesFilesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load files: {error}'**
  String mapTilesFilesLoadFailed(String error);

  /// No description provided for @mapTilesGroupsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups: {error}'**
  String mapTilesGroupsLoadFailed(String error);

  /// No description provided for @mapTilesNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No PMTiles files uploaded yet.'**
  String get mapTilesNoFiles;

  /// No description provided for @mapTilesShownOnMapCount.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} shown on map'**
  String mapTilesShownOnMapCount(int shown, int total);

  /// No description provided for @mapTilesUngrouped.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get mapTilesUngrouped;

  /// No description provided for @mapTilesNoFilesAssigned.
  ///
  /// In en, this message translates to:
  /// **'No files assigned'**
  String get mapTilesNoFilesAssigned;

  /// No description provided for @mapTilesShowUngroupedOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show ungrouped on map'**
  String get mapTilesShowUngroupedOnMap;

  /// No description provided for @mapTilesShowGroupOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show group on map'**
  String get mapTilesShowGroupOnMap;

  /// No description provided for @mapTilesDeleteGroupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get mapTilesDeleteGroupTooltip;

  /// No description provided for @mapTilesUngroupedEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Files not assigned to a group appear here.'**
  String get mapTilesUngroupedEmptyMessage;

  /// No description provided for @mapTilesGroupEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Assign files to this group from the menu on each tile.'**
  String get mapTilesGroupEmptyMessage;

  /// No description provided for @mapTilesNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups'**
  String get mapTilesNoGroups;

  /// No description provided for @mapTilesGroupCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String mapTilesGroupCount(num count);

  /// No description provided for @mapTilesManageGroupsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get mapTilesManageGroupsTooltip;

  /// No description provided for @mapTilesNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get mapTilesNewGroup;

  /// No description provided for @mapTilesShowAllOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show all on map'**
  String get mapTilesShowAllOnMap;

  /// No description provided for @mapTilesHideAllFromMap.
  ///
  /// In en, this message translates to:
  /// **'Hide all from map'**
  String get mapTilesHideAllFromMap;

  /// No description provided for @markerIconsTitle.
  ///
  /// In en, this message translates to:
  /// **'Marker icons'**
  String get markerIconsTitle;

  /// No description provided for @markerIconsDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload SVG marker icons to the server. Clients load them at runtime so icons can be added or updated without redeploying the app. REST API authentication may be required for uploads — configure a key in Settings → About.'**
  String get markerIconsDescription;

  /// No description provided for @markerIconsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add custom icon'**
  String get markerIconsAddButton;

  /// No description provided for @markerIconsServerCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Server catalog'**
  String get markerIconsServerCatalogTitle;

  /// No description provided for @markerIconsNoServerEntries.
  ///
  /// In en, this message translates to:
  /// **'No server-managed icons yet. Add a custom icon or upload an SVG to override a built-in icon below.'**
  String get markerIconsNoServerEntries;

  /// No description provided for @markerIconsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load marker icons: {error}'**
  String markerIconsLoadFailed(String error);

  /// No description provided for @markerIconsEntryCustomSvg.
  ///
  /// In en, this message translates to:
  /// **'{key} • custom SVG'**
  String markerIconsEntryCustomSvg(String key);

  /// No description provided for @markerIconsEntryMaterialFallback.
  ///
  /// In en, this message translates to:
  /// **'{key} • material icon fallback'**
  String markerIconsEntryMaterialFallback(String key);

  /// No description provided for @markerIconsUploadSvgAction.
  ///
  /// In en, this message translates to:
  /// **'Upload SVG'**
  String get markerIconsUploadSvgAction;

  /// No description provided for @markerIconsEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get markerIconsEditAction;

  /// No description provided for @markerIconsBuiltInTitle.
  ///
  /// In en, this message translates to:
  /// **'Override built-in icons'**
  String get markerIconsBuiltInTitle;

  /// No description provided for @markerIconsBuiltInDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload an SVG for a built-in icon key to replace the bundled artwork on all connected clients.'**
  String get markerIconsBuiltInDescription;

  /// No description provided for @markerIconsBuiltInExpandTitle.
  ///
  /// In en, this message translates to:
  /// **'Built-in SVG icons'**
  String get markerIconsBuiltInExpandTitle;

  /// No description provided for @markerIconsBuiltInExpandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 icon} other{{count} icons}}'**
  String markerIconsBuiltInExpandSubtitle(int count);

  /// No description provided for @markerIconsUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'SVG uploaded for {key}'**
  String markerIconsUploadSuccess(String key);

  /// No description provided for @markerIconsUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'SVG upload failed: {error}'**
  String markerIconsUploadFailed(String error);

  /// No description provided for @markerIconsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add marker icon'**
  String get markerIconsCreateTitle;

  /// No description provided for @markerIconsCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Marker icon added: {label}'**
  String markerIconsCreateSuccess(String label);

  /// No description provided for @markerIconsCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add marker icon: {error}'**
  String markerIconsCreateFailed(String error);

  /// No description provided for @markerIconsUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Marker icon updated: {label}'**
  String markerIconsUpdateSuccess(String label);

  /// No description provided for @markerIconsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update marker icon: {error}'**
  String markerIconsUpdateFailed(String error);

  /// No description provided for @markerIconsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete marker icon?'**
  String get markerIconsDeleteTitle;

  /// No description provided for @markerIconsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{label}\" ({key}) from the server? Connected clients will fall back to the built-in icon if one exists.'**
  String markerIconsDeleteMessage(String label, String key);

  /// No description provided for @markerIconsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Marker icon deleted.'**
  String get markerIconsDeleteSuccess;

  /// No description provided for @markerIconsDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete marker icon: {error}'**
  String markerIconsDeleteFailed(String error);

  /// No description provided for @markerIconsKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon key'**
  String get markerIconsKeyLabel;

  /// No description provided for @markerIconsKeyHint.
  ///
  /// In en, this message translates to:
  /// **'custom_drone'**
  String get markerIconsKeyHint;

  /// No description provided for @markerIconsKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Icon key is required.'**
  String get markerIconsKeyRequired;

  /// No description provided for @markerIconsKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, digits, and underscores (max 64).'**
  String get markerIconsKeyInvalid;

  /// No description provided for @markerIconsLabelField.
  ///
  /// In en, this message translates to:
  /// **'Display label'**
  String get markerIconsLabelField;

  /// No description provided for @markerIconsLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Display label is required.'**
  String get markerIconsLabelRequired;

  /// No description provided for @markerIconsColoredAssetLabel.
  ///
  /// In en, this message translates to:
  /// **'Preserve SVG colors'**
  String get markerIconsColoredAssetLabel;

  /// No description provided for @markerIconsColoredAssetHelp.
  ///
  /// In en, this message translates to:
  /// **'Keep original fill and stroke colors instead of tinting with the marker color.'**
  String get markerIconsColoredAssetHelp;

  /// No description provided for @markerIconsGlyphScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon scale: {value}'**
  String markerIconsGlyphScaleLabel(String value);

  /// No description provided for @markerIconsPickSvgOptional.
  ///
  /// In en, this message translates to:
  /// **'Choose SVG (optional)'**
  String get markerIconsPickSvgOptional;

  /// No description provided for @markerIconsPickSvgSelected.
  ///
  /// In en, this message translates to:
  /// **'SVG: {name}'**
  String markerIconsPickSvgSelected(String name);

  /// No description provided for @markerIconsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit marker icon'**
  String get markerIconsEditTitle;

  /// No description provided for @markerIconsCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get markerIconsCategoryLabel;

  /// No description provided for @markerIconBackgroundColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Icon background'**
  String get markerIconBackgroundColorTitle;

  /// No description provided for @markerIconBackgroundColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the fill color behind this icon on the map. Transparent SVG artwork sits on this background — adjust it for better contrast with your map tiles.'**
  String get markerIconBackgroundColorDescription;

  /// No description provided for @markerIconBackgroundColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get markerIconBackgroundColorLabel;

  /// No description provided for @markerIconCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get markerIconCategoryGeneral;

  /// No description provided for @markerIconCategoryPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places & buildings'**
  String get markerIconCategoryPlaces;

  /// No description provided for @markerIconCategoryTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get markerIconCategoryTransportation;

  /// No description provided for @markerIconCategoryPeopleAnimals.
  ///
  /// In en, this message translates to:
  /// **'People & animals'**
  String get markerIconCategoryPeopleAnimals;

  /// No description provided for @markerIconCategoryInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Infrastructure'**
  String get markerIconCategoryInfrastructure;

  /// No description provided for @markerIconCategoryMilitary.
  ///
  /// In en, this message translates to:
  /// **'Military & defense'**
  String get markerIconCategoryMilitary;

  /// No description provided for @markerIconCategoryEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency & medical'**
  String get markerIconCategoryEmergency;

  /// No description provided for @markerIconCategorySanitation.
  ///
  /// In en, this message translates to:
  /// **'Sanitation & hygiene'**
  String get markerIconCategorySanitation;

  /// No description provided for @markerIconCategoryNaturalDisasters.
  ///
  /// In en, this message translates to:
  /// **'Weather and natural disasters'**
  String get markerIconCategoryNaturalDisasters;

  /// No description provided for @markerIconCategoryShelterPreparedness.
  ///
  /// In en, this message translates to:
  /// **'Shelter & preparedness'**
  String get markerIconCategoryShelterPreparedness;

  /// No description provided for @markerIconCategoryRecreation.
  ///
  /// In en, this message translates to:
  /// **'Hunting and foraging'**
  String get markerIconCategoryRecreation;

  /// No description provided for @markerIconCategoryAgriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get markerIconCategoryAgriculture;

  /// No description provided for @markerIconCategoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get markerIconCategoryCustom;

  /// No description provided for @markerIconCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Icon categories'**
  String get markerIconCategoriesTitle;

  /// No description provided for @markerIconCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Organize marker icons into categories. Categories appear in the icon picker and settings lists. Deleting a category moves its icons to Custom.'**
  String get markerIconCategoriesDescription;

  /// No description provided for @markerIconCategoriesExpandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 category} other{{count} categories}}'**
  String markerIconCategoriesExpandSubtitle(int count);

  /// No description provided for @markerIconCategoriesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get markerIconCategoriesAddButton;

  /// No description provided for @markerIconCategoriesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get markerIconCategoriesCreateTitle;

  /// No description provided for @markerIconCategoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get markerIconCategoriesEditTitle;

  /// No description provided for @markerIconCategoriesKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Category key'**
  String get markerIconCategoriesKeyLabel;

  /// No description provided for @markerIconCategoriesKeyHint.
  ///
  /// In en, this message translates to:
  /// **'my_category'**
  String get markerIconCategoriesKeyHint;

  /// No description provided for @markerIconCategoriesKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Category key is required.'**
  String get markerIconCategoriesKeyRequired;

  /// No description provided for @markerIconCategoriesKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, digits, and underscores (max 64).'**
  String get markerIconCategoriesKeyInvalid;

  /// No description provided for @markerIconCategoriesLabelField.
  ///
  /// In en, this message translates to:
  /// **'Display label'**
  String get markerIconCategoriesLabelField;

  /// No description provided for @markerIconCategoriesLabelRequired.
  ///
  /// In en, this message translates to:
  /// **'Display label is required.'**
  String get markerIconCategoriesLabelRequired;

  /// No description provided for @markerIconCategoriesCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added: {label}'**
  String markerIconCategoriesCreateSuccess(String label);

  /// No description provided for @markerIconCategoriesUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category updated: {label}'**
  String markerIconCategoriesUpdateSuccess(String label);

  /// No description provided for @markerIconCategoriesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get markerIconCategoriesDeleteTitle;

  /// No description provided for @markerIconCategoriesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{label}\" ({key})? Icons in this category will move to Custom.'**
  String markerIconCategoriesDeleteMessage(String label, String key);

  /// No description provided for @markerIconCategoriesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted.'**
  String get markerIconCategoriesDeleteSuccess;

  /// No description provided for @markerIconCategoriesCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add category: {error}'**
  String markerIconCategoriesCreateFailed(String error);

  /// No description provided for @markerIconCategoriesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update category: {error}'**
  String markerIconCategoriesUpdateFailed(String error);

  /// No description provided for @markerIconCategoriesDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete category: {error}'**
  String markerIconCategoriesDeleteFailed(String error);

  /// No description provided for @markerIconCategoriesProtectedHint.
  ///
  /// In en, this message translates to:
  /// **'Built-in fallback category (cannot delete)'**
  String get markerIconCategoriesProtectedHint;

  /// No description provided for @layerLabel.
  ///
  /// In en, this message translates to:
  /// **'Layer'**
  String get layerLabel;

  /// No description provided for @layerUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get layerUnassigned;

  /// No description provided for @layerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown layer'**
  String get layerUnknown;

  /// No description provided for @formNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get formNameLabel;

  /// No description provided for @formColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get formColorLabel;

  /// No description provided for @formNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get formNotesLabel;

  /// No description provided for @formNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add notes (saved as Markdown)...'**
  String get formNotesPlaceholder;

  /// No description provided for @formPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get formPreviewLabel;

  /// No description provided for @formShowNameOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show name on map'**
  String get formShowNameOnMap;

  /// No description provided for @formBorderColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Border color'**
  String get formBorderColorLabel;

  /// No description provided for @formFillColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Fill color'**
  String get formFillColorLabel;

  /// No description provided for @formUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get formUnitLabel;

  /// No description provided for @formFillOpacityHelp.
  ///
  /// In en, this message translates to:
  /// **'Adjust opacity to control fill transparency.'**
  String get formFillOpacityHelp;

  /// No description provided for @coordinatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinatesTitle;

  /// No description provided for @markerCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create marker'**
  String get markerCreateTitle;

  /// No description provided for @markerEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit marker'**
  String get markerEditTitle;

  /// No description provided for @markerDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New marker'**
  String get markerDefaultName;

  /// No description provided for @markerCoordinatesHelp.
  ///
  /// In en, this message translates to:
  /// **'Edit latitude and longitude to move the marker on the map.'**
  String get markerCoordinatesHelp;

  /// No description provided for @markerTrackingLabel.
  ///
  /// In en, this message translates to:
  /// **'Tracking marker'**
  String get markerTrackingLabel;

  /// No description provided for @markerTrackingHelp.
  ///
  /// In en, this message translates to:
  /// **'Record movement history as a trail on the map.'**
  String get markerTrackingHelp;

  /// No description provided for @markerTrackingStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get markerTrackingStatusActive;

  /// No description provided for @weatherStationCurrentConditions.
  ///
  /// In en, this message translates to:
  /// **'Current conditions'**
  String get weatherStationCurrentConditions;

  /// No description provided for @weatherDisplayUnitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get weatherDisplayUnitsLabel;

  /// No description provided for @weatherNoData.
  ///
  /// In en, this message translates to:
  /// **'No weather readings yet. Weather data is stored on the server when received from APRS or other local integrations.'**
  String get weatherNoData;

  /// No description provided for @weatherFeelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get weatherFeelsLike;

  /// No description provided for @weatherHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get weatherHumidity;

  /// No description provided for @weatherWind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get weatherWind;

  /// No description provided for @weatherPrecipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get weatherPrecipitation;

  /// No description provided for @weatherPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get weatherPressure;

  /// No description provided for @weatherDewPoint.
  ///
  /// In en, this message translates to:
  /// **'Dew point'**
  String get weatherDewPoint;

  /// No description provided for @weatherLuminosity.
  ///
  /// In en, this message translates to:
  /// **'Luminosity'**
  String get weatherLuminosity;

  /// No description provided for @weatherSolarRadiation.
  ///
  /// In en, this message translates to:
  /// **'Solar radiation'**
  String get weatherSolarRadiation;

  /// No description provided for @weatherUvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV index'**
  String get weatherUvIndex;

  /// No description provided for @weatherSnowfall.
  ///
  /// In en, this message translates to:
  /// **'Snowfall'**
  String get weatherSnowfall;

  /// No description provided for @weatherWaterLevel.
  ///
  /// In en, this message translates to:
  /// **'Water level'**
  String get weatherWaterLevel;

  /// No description provided for @weatherSoilTemperature.
  ///
  /// In en, this message translates to:
  /// **'Soil temperature'**
  String get weatherSoilTemperature;

  /// No description provided for @weatherSoilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil moisture'**
  String get weatherSoilMoisture;

  /// No description provided for @weatherLeafWetness.
  ///
  /// In en, this message translates to:
  /// **'Leaf wetness'**
  String get weatherLeafWetness;

  /// No description provided for @weatherIndoorTemperature.
  ///
  /// In en, this message translates to:
  /// **'Indoor temperature'**
  String get weatherIndoorTemperature;

  /// No description provided for @weatherIndoorHumidity.
  ///
  /// In en, this message translates to:
  /// **'Indoor humidity'**
  String get weatherIndoorHumidity;

  /// No description provided for @weatherBatteryVoltage.
  ///
  /// In en, this message translates to:
  /// **'Battery voltage'**
  String get weatherBatteryVoltage;

  /// No description provided for @weatherWindRun.
  ///
  /// In en, this message translates to:
  /// **'Wind run'**
  String get weatherWindRun;

  /// No description provided for @weatherStationStatus.
  ///
  /// In en, this message translates to:
  /// **'Station status'**
  String get weatherStationStatus;

  /// No description provided for @weatherSensorHealth.
  ///
  /// In en, this message translates to:
  /// **'Sensor health'**
  String get weatherSensorHealth;

  /// No description provided for @weatherHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent readings'**
  String get weatherHistoryTitle;

  /// No description provided for @weatherSource.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String weatherSource(String source);

  /// No description provided for @weatherUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String weatherUpdatedAt(String time);

  /// No description provided for @weatherConditionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherConditionClear;

  /// No description provided for @weatherConditionPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherConditionPartlyCloudy;

  /// No description provided for @weatherConditionOvercast.
  ///
  /// In en, this message translates to:
  /// **'Overcast'**
  String get weatherConditionOvercast;

  /// No description provided for @weatherConditionFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherConditionFog;

  /// No description provided for @weatherConditionDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherConditionDrizzle;

  /// No description provided for @weatherConditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherConditionRain;

  /// No description provided for @weatherConditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherConditionSnow;

  /// No description provided for @weatherConditionShowers.
  ///
  /// In en, this message translates to:
  /// **'Showers'**
  String get weatherConditionShowers;

  /// No description provided for @weatherConditionThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherConditionThunderstorm;

  /// No description provided for @weatherConditionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weatherConditionUnknown;

  /// No description provided for @markerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Work, Trailhead'**
  String get markerNameHint;

  /// No description provided for @markerElevationLabel.
  ///
  /// In en, this message translates to:
  /// **'Elevation (m)'**
  String get markerElevationLabel;

  /// No description provided for @markerIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get markerIconLabel;

  /// No description provided for @markerIconHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon for the map pin, such as Home for your house.'**
  String get markerIconHelp;

  /// No description provided for @markerSaveSearchedCoordinatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Save searched coordinates'**
  String get markerSaveSearchedCoordinatesTitle;

  /// No description provided for @markerSaveSearchedCoordinatesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save marker'**
  String get markerSaveSearchedCoordinatesConfirm;

  /// No description provided for @lineCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create line'**
  String get lineCreateTitle;

  /// No description provided for @lineEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get lineEditTitle;

  /// No description provided for @lineDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New line'**
  String get lineDefaultName;

  /// No description provided for @lineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Route to camp, Property boundary'**
  String get lineNameHint;

  /// No description provided for @lineDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get lineDistanceLabel;

  /// No description provided for @lineStartPointLabel.
  ///
  /// In en, this message translates to:
  /// **'Start point'**
  String get lineStartPointLabel;

  /// No description provided for @lineEndPointLabel.
  ///
  /// In en, this message translates to:
  /// **'End point'**
  String get lineEndPointLabel;

  /// No description provided for @lineStyleLabel.
  ///
  /// In en, this message translates to:
  /// **'Line style'**
  String get lineStyleLabel;

  /// No description provided for @lineBorderSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get lineBorderSolid;

  /// No description provided for @lineBorderDashed.
  ///
  /// In en, this message translates to:
  /// **'Dashed'**
  String get lineBorderDashed;

  /// No description provided for @lineDirectionArrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Direction arrows'**
  String get lineDirectionArrowsTitle;

  /// No description provided for @lineDirectionArrowsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arrows point from the first point toward the second.'**
  String get lineDirectionArrowsSubtitle;

  /// No description provided for @circleCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create circle'**
  String get circleCreateTitle;

  /// No description provided for @circleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit circle'**
  String get circleEditTitle;

  /// No description provided for @trackEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit track'**
  String get trackEditTitle;

  /// No description provided for @trackTransportationModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get trackTransportationModeLabel;

  /// No description provided for @trackTransportationModeOnFoot.
  ///
  /// In en, this message translates to:
  /// **'On foot'**
  String get trackTransportationModeOnFoot;

  /// No description provided for @trackTransportationModeHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get trackTransportationModeHorse;

  /// No description provided for @trackTransportationModeBike.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get trackTransportationModeBike;

  /// No description provided for @trackTransportationModeMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get trackTransportationModeMotorcycle;

  /// No description provided for @trackTransportationModeAtv.
  ///
  /// In en, this message translates to:
  /// **'ATV'**
  String get trackTransportationModeAtv;

  /// No description provided for @trackTransportationModeLandVehicle.
  ///
  /// In en, this message translates to:
  /// **'Land vehicle'**
  String get trackTransportationModeLandVehicle;

  /// No description provided for @trackTransportationModeTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get trackTransportationModeTruck;

  /// No description provided for @trackTransportationModeBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get trackTransportationModeBus;

  /// No description provided for @trackTransportationModeRv.
  ///
  /// In en, this message translates to:
  /// **'Recreational vehicle'**
  String get trackTransportationModeRv;

  /// No description provided for @trackTransportationModeTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trackTransportationModeTrain;

  /// No description provided for @trackTransportationModeAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get trackTransportationModeAmbulance;

  /// No description provided for @trackTransportationModeFireTruck.
  ///
  /// In en, this message translates to:
  /// **'Fire truck'**
  String get trackTransportationModeFireTruck;

  /// No description provided for @trackTransportationModeFarmVehicle.
  ///
  /// In en, this message translates to:
  /// **'Farm vehicle'**
  String get trackTransportationModeFarmVehicle;

  /// No description provided for @trackTransportationModeCanoe.
  ///
  /// In en, this message translates to:
  /// **'Canoe'**
  String get trackTransportationModeCanoe;

  /// No description provided for @trackTransportationModeWatercraft.
  ///
  /// In en, this message translates to:
  /// **'Watercraft'**
  String get trackTransportationModeWatercraft;

  /// No description provided for @trackTransportationModeSailboat.
  ///
  /// In en, this message translates to:
  /// **'Sailboat'**
  String get trackTransportationModeSailboat;

  /// No description provided for @trackTransportationModeAircraft.
  ///
  /// In en, this message translates to:
  /// **'Aircraft'**
  String get trackTransportationModeAircraft;

  /// No description provided for @trackTransportationModeHelicopter.
  ///
  /// In en, this message translates to:
  /// **'Helicopter'**
  String get trackTransportationModeHelicopter;

  /// No description provided for @trackTransportationModeGlider.
  ///
  /// In en, this message translates to:
  /// **'Glider'**
  String get trackTransportationModeGlider;

  /// No description provided for @trackTransportationModeBalloon.
  ///
  /// In en, this message translates to:
  /// **'Balloon'**
  String get trackTransportationModeBalloon;

  /// No description provided for @trackShowFootstepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Show trail on map'**
  String get trackShowFootstepsLabel;

  /// No description provided for @trackShowFootstepsHelp.
  ///
  /// In en, this message translates to:
  /// **'Show transportation icons along the movement trail.'**
  String get trackShowFootstepsHelp;

  /// No description provided for @circleDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New circle'**
  String get circleDefaultName;

  /// No description provided for @circleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Search area, Property boundary'**
  String get circleNameHint;

  /// No description provided for @circleMeasurementsLabel.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get circleMeasurementsLabel;

  /// No description provided for @circleCenterMoveHelp.
  ///
  /// In en, this message translates to:
  /// **'Edit latitude and longitude to move the center, for example to match a marker.'**
  String get circleCenterMoveHelp;

  /// No description provided for @circleInvalidSize.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid size of at least 1 m radius.'**
  String get circleInvalidSize;

  /// No description provided for @circleCenterLabel.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get circleCenterLabel;

  /// No description provided for @circleSizeLabelOnMap.
  ///
  /// In en, this message translates to:
  /// **'Size label on map'**
  String get circleSizeLabelOnMap;

  /// No description provided for @circleCenterMarkerLabel.
  ///
  /// In en, this message translates to:
  /// **'Center marker'**
  String get circleCenterMarkerLabel;

  /// No description provided for @rectangleCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create rectangle'**
  String get rectangleCreateTitle;

  /// No description provided for @rectangleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit rectangle'**
  String get rectangleEditTitle;

  /// No description provided for @rectangleDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New rectangle'**
  String get rectangleDefaultName;

  /// No description provided for @rectangleCornerALabel.
  ///
  /// In en, this message translates to:
  /// **'Corner A'**
  String get rectangleCornerALabel;

  /// No description provided for @rectangleCornerBLabel.
  ///
  /// In en, this message translates to:
  /// **'Corner B'**
  String get rectangleCornerBLabel;

  /// No description provided for @rectangleCenterMoveHelp.
  ///
  /// In en, this message translates to:
  /// **'Moving the center shifts the whole rectangle on the map.'**
  String get rectangleCenterMoveHelp;

  /// No description provided for @mapHomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get mapHomeTooltip;

  /// No description provided for @mapSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get mapSettingsTooltip;

  /// No description provided for @mapManualTooltip.
  ///
  /// In en, this message translates to:
  /// **'User manual'**
  String get mapManualTooltip;

  /// No description provided for @mapDeviceLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapDeviceLocationTooltip;

  /// No description provided for @mapDeviceLocationFollowingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Following your location (pan to stop)'**
  String get mapDeviceLocationFollowingTooltip;

  /// No description provided for @mapDeviceLocationStopTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location (long-press to hide)'**
  String get mapDeviceLocationStopTooltip;

  /// No description provided for @mapDeviceLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on this device.'**
  String get mapDeviceLocationServiceDisabled;

  /// No description provided for @mapDeviceLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied.'**
  String get mapDeviceLocationPermissionDenied;

  /// No description provided for @mapDeviceLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission is blocked. Enable it in system or browser settings.'**
  String get mapDeviceLocationPermissionDeniedForever;

  /// No description provided for @mapDeviceLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. On the web, use HTTPS or localhost.'**
  String get mapDeviceLocationUnavailable;

  /// No description provided for @mapDeviceLocationSelectedMarker.
  ///
  /// In en, this message translates to:
  /// **'Selected marker'**
  String get mapDeviceLocationSelectedMarker;

  /// No description provided for @mapDeviceLocationSelectMarkerHint.
  ///
  /// In en, this message translates to:
  /// **'Select a marker for distance and bearing'**
  String get mapDeviceLocationSelectMarkerHint;

  /// No description provided for @mapDeviceLocationToMarker.
  ///
  /// In en, this message translates to:
  /// **'To {name}: {range}'**
  String mapDeviceLocationToMarker(String name, String range);

  /// No description provided for @mapMgrsGridShowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show MGRS grid'**
  String get mapMgrsGridShowTooltip;

  /// No description provided for @mapMgrsGridHideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide MGRS grid'**
  String get mapMgrsGridHideTooltip;

  /// No description provided for @userManualTitle.
  ///
  /// In en, this message translates to:
  /// **'User Manual'**
  String get userManualTitle;

  /// No description provided for @userManualContentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get userManualContentsTitle;

  /// No description provided for @userManualLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the user manual: {error}'**
  String userManualLoadFailed(String error);

  /// No description provided for @userManualEmpty.
  ///
  /// In en, this message translates to:
  /// **'The user manual is empty.'**
  String get userManualEmpty;

  /// No description provided for @mapShowObjectsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show map objects'**
  String get mapShowObjectsTooltip;

  /// No description provided for @mapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map: {error}'**
  String mapLoadFailed(String error);

  /// No description provided for @mapNoOfflineMapTitle.
  ///
  /// In en, this message translates to:
  /// **'No offline map installed or visible'**
  String get mapNoOfflineMapTitle;

  /// No description provided for @mapNoOfflineMapMessage.
  ///
  /// In en, this message translates to:
  /// **'Upload a .pmtiles file in Settings, or turn on visibility for tiles already on the server.'**
  String get mapNoOfflineMapMessage;

  /// No description provided for @mapObjectDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Map object'**
  String get mapObjectDetailsTitle;

  /// No description provided for @mapObjectDetailsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading details…'**
  String get mapObjectDetailsLoading;

  /// No description provided for @mapObjectDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'This object could not be found.'**
  String get mapObjectDetailsNotFound;

  /// No description provided for @mapObjectDetailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get mapObjectDetailType;

  /// No description provided for @mapObjectTypeMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get mapObjectTypeMarker;

  /// No description provided for @mapObjectTypeLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get mapObjectTypeLine;

  /// No description provided for @mapObjectTypeTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get mapObjectTypeTrack;

  /// No description provided for @mapObjectTypeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get mapObjectTypeCircle;

  /// No description provided for @mapObjectDetailCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get mapObjectDetailCoordinates;

  /// No description provided for @mapObjectDetailMgrs.
  ///
  /// In en, this message translates to:
  /// **'MGRS'**
  String get mapObjectDetailMgrs;

  /// No description provided for @mapObjectDetailMgrsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable (outside MGRS coverage)'**
  String get mapObjectDetailMgrsUnavailable;

  /// No description provided for @mapObjectDetailElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get mapObjectDetailElevation;

  /// No description provided for @mapObjectDetailVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get mapObjectDetailVisibility;

  /// No description provided for @mapObjectVisibilityVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get mapObjectVisibilityVisible;

  /// No description provided for @mapObjectVisibilityHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get mapObjectVisibilityHidden;

  /// No description provided for @mapObjectDetailLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get mapObjectDetailLength;

  /// No description provided for @mapObjectDetailPointCount.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get mapObjectDetailPointCount;

  /// No description provided for @mapObjectDetailStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mapObjectDetailStart;

  /// No description provided for @mapObjectDetailEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get mapObjectDetailEnd;

  /// No description provided for @mapObjectDetailRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get mapObjectDetailRadius;

  /// No description provided for @mapObjectDetailDiameter.
  ///
  /// In en, this message translates to:
  /// **'Diameter'**
  String get mapObjectDetailDiameter;

  /// No description provided for @mapObjectDetailCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get mapObjectDetailCenter;

  /// No description provided for @mapObjectDetailMapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map label'**
  String get mapObjectDetailMapLabel;

  /// No description provided for @mapObjectMapLabelNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get mapObjectMapLabelNone;

  /// No description provided for @mapObjectDetailDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get mapObjectDetailDimensions;

  /// No description provided for @mapObjectDetailArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get mapObjectDetailArea;

  /// No description provided for @mapObjectsErrorServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'The Wayfinder server could not be reached. Start the server to sync markers and zones.'**
  String get mapObjectsErrorServerUnreachable;

  /// No description provided for @mapObjectsErrorSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to load your map objects.'**
  String get mapObjectsErrorSignInRequired;

  /// No description provided for @mapObjectsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading map objects. Check your connection and try again.'**
  String get mapObjectsErrorGeneric;

  /// No description provided for @mapObjectsErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading map objects. Please try again.'**
  String get mapObjectsErrorRetry;

  /// No description provided for @layersErrorTableMissing.
  ///
  /// In en, this message translates to:
  /// **'The map layers database table is missing. Restart the Wayfinder server with migrations applied.'**
  String get layersErrorTableMissing;

  /// No description provided for @layersErrorEndpointUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Restart the Wayfinder server from the latest code.'**
  String get layersErrorEndpointUnavailable;

  /// No description provided for @layersErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading layers. Please try again.'**
  String get layersErrorGeneric;

  /// No description provided for @sidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Map Objects'**
  String get sidebarTitle;

  /// No description provided for @sidebarCollapsePanel.
  ///
  /// In en, this message translates to:
  /// **'Collapse panel'**
  String get sidebarCollapsePanel;

  /// No description provided for @sidebarExpandPanel.
  ///
  /// In en, this message translates to:
  /// **'Expand panel'**
  String get sidebarExpandPanel;

  /// No description provided for @sidebarLayerOrderHint.
  ///
  /// In en, this message translates to:
  /// **'Top layers draw above lower ones. Use ▼ to expand or collapse layer contents.'**
  String get sidebarLayerOrderHint;

  /// No description provided for @sidebarLayersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Layers unavailable'**
  String get sidebarLayersUnavailable;

  /// No description provided for @sidebarMarkersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Markers unavailable'**
  String get sidebarMarkersUnavailable;

  /// No description provided for @sidebarZonesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Zones unavailable'**
  String get sidebarZonesUnavailable;

  /// No description provided for @sidebarAddLayer.
  ///
  /// In en, this message translates to:
  /// **'Add layer'**
  String get sidebarAddLayer;

  /// No description provided for @sidebarKeepOneLayer.
  ///
  /// In en, this message translates to:
  /// **'You must keep at least one layer.'**
  String get sidebarKeepOneLayer;

  /// No description provided for @sidebarNewLayerTitle.
  ///
  /// In en, this message translates to:
  /// **'New layer'**
  String get sidebarNewLayerTitle;

  /// No description provided for @sidebarRenameLayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename layer'**
  String get sidebarRenameLayerTitle;

  /// No description provided for @sidebarLayerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Layer name'**
  String get sidebarLayerNameLabel;

  /// No description provided for @sidebarDeleteLayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete layer?'**
  String get sidebarDeleteLayerTitle;

  /// No description provided for @sidebarDeleteLayerMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Its markers and zones will move to another layer.'**
  String sidebarDeleteLayerMessage(String name);

  /// No description provided for @sidebarCollapseLayer.
  ///
  /// In en, this message translates to:
  /// **'Collapse layer'**
  String get sidebarCollapseLayer;

  /// No description provided for @sidebarExpandLayer.
  ///
  /// In en, this message translates to:
  /// **'Expand layer'**
  String get sidebarExpandLayer;

  /// No description provided for @sidebarHideLayer.
  ///
  /// In en, this message translates to:
  /// **'Hide layer'**
  String get sidebarHideLayer;

  /// No description provided for @sidebarShowLayer.
  ///
  /// In en, this message translates to:
  /// **'Show layer'**
  String get sidebarShowLayer;

  /// No description provided for @sidebarObjectCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 object} other{{count} objects}}'**
  String sidebarObjectCount(num count);

  /// No description provided for @sidebarSelectedForNewObjects.
  ///
  /// In en, this message translates to:
  /// **'· selected for new objects'**
  String get sidebarSelectedForNewObjects;

  /// No description provided for @sidebarMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get sidebarMoveUp;

  /// No description provided for @sidebarMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get sidebarMoveDown;

  /// No description provided for @sidebarTabMarkers.
  ///
  /// In en, this message translates to:
  /// **'Markers'**
  String get sidebarTabMarkers;

  /// No description provided for @sidebarTabZones.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get sidebarTabZones;

  /// No description provided for @sidebarViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get sidebarViewList;

  /// No description provided for @sidebarViewTree.
  ///
  /// In en, this message translates to:
  /// **'Tree'**
  String get sidebarViewTree;

  /// No description provided for @sidebarNoMatchingMarkers.
  ///
  /// In en, this message translates to:
  /// **'No matching markers'**
  String get sidebarNoMatchingMarkers;

  /// No description provided for @sidebarNoMatchingZones.
  ///
  /// In en, this message translates to:
  /// **'No matching zones'**
  String get sidebarNoMatchingZones;

  /// No description provided for @sidebarTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get sidebarTryDifferentSearch;

  /// No description provided for @sidebarNoMarkersOnLayer.
  ///
  /// In en, this message translates to:
  /// **'No markers on this layer'**
  String get sidebarNoMarkersOnLayer;

  /// No description provided for @sidebarAddMarkerHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press the map to add a marker.'**
  String get sidebarAddMarkerHint;

  /// No description provided for @sidebarNoZonesOnLayer.
  ///
  /// In en, this message translates to:
  /// **'No zones on this layer'**
  String get sidebarNoZonesOnLayer;

  /// No description provided for @sidebarAddZoneHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press the map and choose Line to draw one.'**
  String get sidebarAddZoneHint;

  /// No description provided for @sidebarHideMarker.
  ///
  /// In en, this message translates to:
  /// **'Hide marker'**
  String get sidebarHideMarker;

  /// No description provided for @sidebarShowMarker.
  ///
  /// In en, this message translates to:
  /// **'Show marker'**
  String get sidebarShowMarker;

  /// No description provided for @sidebarEditMarker.
  ///
  /// In en, this message translates to:
  /// **'Edit marker'**
  String get sidebarEditMarker;

  /// No description provided for @sidebarDeleteMarker.
  ///
  /// In en, this message translates to:
  /// **'Delete marker'**
  String get sidebarDeleteMarker;

  /// No description provided for @sidebarHideNameOnMap.
  ///
  /// In en, this message translates to:
  /// **'Hide name on map'**
  String get sidebarHideNameOnMap;

  /// No description provided for @sidebarShowNameOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show name on map'**
  String get sidebarShowNameOnMap;

  /// No description provided for @sidebarHideDistanceOnMap.
  ///
  /// In en, this message translates to:
  /// **'Hide distance on map'**
  String get sidebarHideDistanceOnMap;

  /// No description provided for @sidebarShowDistanceOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show distance on map'**
  String get sidebarShowDistanceOnMap;

  /// No description provided for @sidebarHideLine.
  ///
  /// In en, this message translates to:
  /// **'Hide line'**
  String get sidebarHideLine;

  /// No description provided for @sidebarShowLine.
  ///
  /// In en, this message translates to:
  /// **'Show line'**
  String get sidebarShowLine;

  /// No description provided for @sidebarEditLine.
  ///
  /// In en, this message translates to:
  /// **'Edit line'**
  String get sidebarEditLine;

  /// No description provided for @sidebarEditTrack.
  ///
  /// In en, this message translates to:
  /// **'Edit track'**
  String get sidebarEditTrack;

  /// No description provided for @sidebarDeleteTrack.
  ///
  /// In en, this message translates to:
  /// **'Delete track'**
  String get sidebarDeleteTrack;

  /// No description provided for @sidebarShowTrack.
  ///
  /// In en, this message translates to:
  /// **'Show track'**
  String get sidebarShowTrack;

  /// No description provided for @sidebarHideTrack.
  ///
  /// In en, this message translates to:
  /// **'Hide track'**
  String get sidebarHideTrack;

  /// No description provided for @sidebarDeleteLine.
  ///
  /// In en, this message translates to:
  /// **'Delete line'**
  String get sidebarDeleteLine;

  /// No description provided for @sidebarHideCircle.
  ///
  /// In en, this message translates to:
  /// **'Hide circle'**
  String get sidebarHideCircle;

  /// No description provided for @sidebarShowCircle.
  ///
  /// In en, this message translates to:
  /// **'Show circle'**
  String get sidebarShowCircle;

  /// No description provided for @sidebarEditCircle.
  ///
  /// In en, this message translates to:
  /// **'Edit circle'**
  String get sidebarEditCircle;

  /// No description provided for @sidebarDeleteCircle.
  ///
  /// In en, this message translates to:
  /// **'Delete circle'**
  String get sidebarDeleteCircle;

  /// No description provided for @sidebarHideRectangle.
  ///
  /// In en, this message translates to:
  /// **'Hide rectangle'**
  String get sidebarHideRectangle;

  /// No description provided for @sidebarShowRectangle.
  ///
  /// In en, this message translates to:
  /// **'Show rectangle'**
  String get sidebarShowRectangle;

  /// No description provided for @sidebarEditRectangle.
  ///
  /// In en, this message translates to:
  /// **'Edit rectangle'**
  String get sidebarEditRectangle;

  /// No description provided for @sidebarDeleteRectangle.
  ///
  /// In en, this message translates to:
  /// **'Delete rectangle'**
  String get sidebarDeleteRectangle;

  /// No description provided for @sidebarHideZone.
  ///
  /// In en, this message translates to:
  /// **'Hide zone'**
  String get sidebarHideZone;

  /// No description provided for @sidebarShowZone.
  ///
  /// In en, this message translates to:
  /// **'Show zone'**
  String get sidebarShowZone;

  /// No description provided for @sidebarDeleteZone.
  ///
  /// In en, this message translates to:
  /// **'Delete zone'**
  String get sidebarDeleteZone;

  /// No description provided for @searchReadinessReadySnackBar.
  ///
  /// In en, this message translates to:
  /// **'Full search is ready — places and addresses.'**
  String get searchReadinessReadySnackBar;

  /// No description provided for @searchReadinessCheckingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Checking search readiness…'**
  String get searchReadinessCheckingTooltip;

  /// No description provided for @searchReadinessUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search readiness unavailable'**
  String get searchReadinessUnavailableTooltip;

  /// No description provided for @searchReadinessFullReadyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Full search ready'**
  String get searchReadinessFullReadyTooltip;

  /// No description provided for @searchReadinessBuildingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Building search indexes…'**
  String get searchReadinessBuildingTooltip;

  /// No description provided for @searchReadinessNotReadyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Full search not ready'**
  String get searchReadinessNotReadyTooltip;

  /// No description provided for @searchReadinessGeocodingNotConfiguredTooltip.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server not configured'**
  String get searchReadinessGeocodingNotConfiguredTooltip;

  /// No description provided for @searchReadinessGeocodingUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server unavailable'**
  String get searchReadinessGeocodingUnavailableTooltip;

  /// No description provided for @searchReadinessImportInProgressTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import in progress: {phase}'**
  String searchReadinessImportInProgressTooltip(String phase);

  /// No description provided for @searchReadinessImportPlacesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Place search data import'**
  String get searchReadinessImportPlacesDialogTitle;

  /// No description provided for @searchReadinessImportAddressesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Street address data import'**
  String get searchReadinessImportAddressesDialogTitle;

  /// No description provided for @searchReadinessFullReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Full search ready'**
  String get searchReadinessFullReadyTitle;

  /// No description provided for @searchReadinessPlacesReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Place search ready'**
  String get searchReadinessPlacesReadyTitle;

  /// No description provided for @searchReadinessAddressReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Address search ready'**
  String get searchReadinessAddressReadyTitle;

  /// No description provided for @searchReadinessWaitingForDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for geocoding data'**
  String get searchReadinessWaitingForDataTitle;

  /// No description provided for @searchReadinessNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search not ready yet'**
  String get searchReadinessNotReadyTitle;

  /// No description provided for @searchReadinessIndexesBuilt.
  ///
  /// In en, this message translates to:
  /// **'Search indexes: {ready} of {total}'**
  String searchReadinessIndexesBuilt(int ready, int total);

  /// No description provided for @searchReadinessCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking search status…'**
  String get searchReadinessCheckingStatus;

  /// No description provided for @searchReadinessFullReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'You can search for places and street addresses from the map search bar.'**
  String get searchReadinessFullReadyMessage;

  /// No description provided for @searchReadinessPlacesOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'You can search for place names from the map search bar. Import street address data in Settings → Geocoding to search addresses.'**
  String get searchReadinessPlacesOnlyMessage;

  /// No description provided for @searchReadinessAddressOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'You can search for street addresses from the map search bar. Import place data in Settings → Geocoding to search place names.'**
  String get searchReadinessAddressOnlyMessage;

  /// No description provided for @searchReadinessWaitingForDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Search indexes are ready. Import the missing datasets in Settings → Geocoding to enable search.'**
  String get searchReadinessWaitingForDataMessage;

  /// No description provided for @searchReadinessRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search requirements'**
  String get searchReadinessRequirementsTitle;

  /// No description provided for @searchReadinessRequirementPlacesData.
  ///
  /// In en, this message translates to:
  /// **'Place data imported'**
  String get searchReadinessRequirementPlacesData;

  /// No description provided for @searchReadinessRequirementAddressData.
  ///
  /// In en, this message translates to:
  /// **'Street address data imported'**
  String get searchReadinessRequirementAddressData;

  /// No description provided for @searchReadinessRequirementIndexes.
  ///
  /// In en, this message translates to:
  /// **'Search indexes built'**
  String get searchReadinessRequirementIndexes;

  /// No description provided for @searchReadinessRequirementReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get searchReadinessRequirementReady;

  /// No description provided for @searchReadinessRequirementMissing.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get searchReadinessRequirementMissing;

  /// No description provided for @searchReadinessPartialReadyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Partial search ready'**
  String get searchReadinessPartialReadyTooltip;

  /// No description provided for @searchReadinessPlacesOnlyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Place search ready'**
  String get searchReadinessPlacesOnlyTooltip;

  /// No description provided for @searchReadinessPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String searchReadinessPercentComplete(int percent);

  /// No description provided for @searchReadinessEta.
  ///
  /// In en, this message translates to:
  /// **'Estimated time remaining: {eta}'**
  String searchReadinessEta(String eta);

  /// No description provided for @searchReadinessCurrentIndex.
  ///
  /// In en, this message translates to:
  /// **'Current index: {name}'**
  String searchReadinessCurrentIndex(String name);

  /// No description provided for @searchReadinessServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server to check search status.'**
  String get searchReadinessServerUnreachable;

  /// No description provided for @mapTilesReadyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Map tiles ready'**
  String get mapTilesReadyTooltip;

  /// No description provided for @mapTilesLoadingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Map tiles loading'**
  String get mapTilesLoadingTooltip;

  /// No description provided for @mapTilesNotReadyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Map tiles not ready'**
  String get mapTilesNotReadyTooltip;

  /// No description provided for @mapTilesLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading map tiles'**
  String get mapTilesLoadingTitle;

  /// No description provided for @mapTilesCatalogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map tile catalog.'**
  String get mapTilesCatalogLoadFailed;

  /// No description provided for @mapTilesOpeningLayer.
  ///
  /// In en, this message translates to:
  /// **'Opening: {name}'**
  String mapTilesOpeningLayer(String name);

  /// No description provided for @mapTilesLargeArchiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Large .pmtiles archives can take several minutes to open before tiles appear. Panning and zooming will fetch tiles as the map becomes ready.'**
  String get mapTilesLargeArchiveHelp;

  /// No description provided for @mapTilesLayersPrepared.
  ///
  /// In en, this message translates to:
  /// **'Layers prepared: {loaded} of {enabled}'**
  String mapTilesLayersPrepared(int loaded, int enabled);

  /// No description provided for @mapTilesActiveLayer.
  ///
  /// In en, this message translates to:
  /// **'Active layer: {name}'**
  String mapTilesActiveLayer(String name);

  /// No description provided for @mapTilesReadyHelp.
  ///
  /// In en, this message translates to:
  /// **'Tiles for the current map view should be visible. If the map is still blank, try zooming to the layer coverage area.'**
  String get mapTilesReadyHelp;

  /// No description provided for @mapTilesOpeningProgress.
  ///
  /// In en, this message translates to:
  /// **'Opening {name}…'**
  String mapTilesOpeningProgress(String name);

  /// No description provided for @greetingsConnected.
  ///
  /// In en, this message translates to:
  /// **'You are connected'**
  String get greetingsConnected;

  /// No description provided for @greetingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get greetingsNameHint;

  /// No description provided for @greetingsSendToServer.
  ///
  /// In en, this message translates to:
  /// **'Send to Server'**
  String get greetingsSendToServer;

  /// No description provided for @greetingsNoResponse.
  ///
  /// In en, this message translates to:
  /// **'No server response yet.'**
  String get greetingsNoResponse;

  /// No description provided for @authSuccess.
  ///
  /// In en, this message translates to:
  /// **'User authenticated.'**
  String get authSuccess;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed: {error}'**
  String authFailed(String error);

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String couldNotOpenLink(String url);

  /// No description provided for @geocodingAbortImport.
  ///
  /// In en, this message translates to:
  /// **'Abort import'**
  String get geocodingAbortImport;

  /// No description provided for @geocodingTitle.
  ///
  /// In en, this message translates to:
  /// **'Geocoding'**
  String get geocodingTitle;

  /// No description provided for @geocodingDescription.
  ///
  /// In en, this message translates to:
  /// **'Download OSMNames data to the geocoding server for offline search. Place names and street addresses are imported separately.'**
  String get geocodingDescription;

  /// No description provided for @geocodingServerConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server'**
  String get geocodingServerConnectionTitle;

  /// No description provided for @geocodingServerConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Separate from your main Wayfinder server. Run the geocoding stack on another machine when imports need a large database.'**
  String get geocodingServerConnectionDescription;

  /// No description provided for @geocodingServerUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server web URL'**
  String get geocodingServerUrlLabel;

  /// No description provided for @geocodingSaveServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Save geocoding server URL'**
  String get geocodingSaveServerUrl;

  /// No description provided for @geocodingServerNotConfiguredMessage.
  ///
  /// In en, this message translates to:
  /// **'Configure a geocoding server URL to enable place and address search. Restart the app after saving.'**
  String get geocodingServerNotConfiguredMessage;

  /// No description provided for @geocodingServerUrlSavedRestart.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server URL saved. Restart the app to connect.'**
  String get geocodingServerUrlSavedRestart;

  /// No description provided for @geocodingServerUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'Geocoding server URL saved.'**
  String get geocodingServerUrlSaved;

  /// No description provided for @geocodingPlacesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Place names (geonames.tsv)'**
  String get geocodingPlacesSectionTitle;

  /// No description provided for @geocodingDownloadedDatasetsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloaded datasets (OSMNames)'**
  String get geocodingDownloadedDatasetsSectionTitle;

  /// No description provided for @geocodingDownloadedDatasetsSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Large planet or regional imports from OSMNames. Custom locations above work without importing these.'**
  String get geocodingDownloadedDatasetsSectionDescription;

  /// No description provided for @geocodingPlaceDatasetLabel.
  ///
  /// In en, this message translates to:
  /// **'Place dataset'**
  String get geocodingPlaceDatasetLabel;

  /// No description provided for @geocodingCustomPlaceUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom place data URL'**
  String get geocodingCustomPlaceUrlLabel;

  /// No description provided for @geocodingStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String geocodingStatusLabel(String status);

  /// No description provided for @geocodingLastSelection.
  ///
  /// In en, this message translates to:
  /// **'Last selection: {dataset}'**
  String geocodingLastSelection(String dataset);

  /// No description provided for @geocodingLastImport.
  ///
  /// In en, this message translates to:
  /// **'Last import: {dateTime}'**
  String geocodingLastImport(String dateTime);

  /// No description provided for @geocodingPlacesArchiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Archive place data as a JSON file, restore from a previous export, or remove all records from the server.'**
  String get geocodingPlacesArchiveDescription;

  /// No description provided for @geocodingPlaceImportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Place import in progress…'**
  String get geocodingPlaceImportInProgress;

  /// No description provided for @geocodingDownloadImportPlaces.
  ///
  /// In en, this message translates to:
  /// **'Download and import places'**
  String get geocodingDownloadImportPlaces;

  /// No description provided for @geocodingAddressesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Street addresses (housenumbers.tsv)'**
  String get geocodingAddressesSectionTitle;

  /// No description provided for @geocodingHousenumbersUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Housenumbers data URL'**
  String get geocodingHousenumbersUrlLabel;

  /// No description provided for @geocodingAddressesArchiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Archive address data as a separate JSON file, restore from a previous export, or remove all records from the server.'**
  String get geocodingAddressesArchiveDescription;

  /// No description provided for @geocodingAddressImportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Address import in progress…'**
  String get geocodingAddressImportInProgress;

  /// No description provided for @geocodingDownloadImportHousenumbers.
  ///
  /// In en, this message translates to:
  /// **'Download and import housenumbers'**
  String get geocodingDownloadImportHousenumbers;

  /// No description provided for @geocodingContributionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom locations'**
  String get geocodingContributionsSectionTitle;

  /// No description provided for @geocodingContributionsSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Add place names and coordinates that are not in OSMNames. These are stored separately from downloaded datasets and appear in search.'**
  String get geocodingContributionsSectionDescription;

  /// No description provided for @geocodingContributionsConfigureServerHint.
  ///
  /// In en, this message translates to:
  /// **'Save a geocoding server URL above, then restart the app, to add and list custom locations.'**
  String get geocodingContributionsConfigureServerHint;

  /// No description provided for @geocodingServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the geocoding server. Check that it is running and that {url} is reachable from your browser.'**
  String geocodingServerUnreachable(String url);

  /// No description provided for @geocodingContributionFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a location'**
  String get geocodingContributionFormTitle;

  /// No description provided for @geocodingContributionFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get geocodingContributionFormEditTitle;

  /// No description provided for @geocodingContributionSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get geocodingContributionSaveAction;

  /// No description provided for @geocodingContributionClearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get geocodingContributionClearForm;

  /// No description provided for @geocodingContributionsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved locations'**
  String get geocodingContributionsListTitle;

  /// No description provided for @geocodingContributionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom locations yet. Tap Add location to create one.'**
  String get geocodingContributionsEmpty;

  /// No description provided for @geocodingContributionsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load custom locations. Update the geocoding server to the latest version.'**
  String get geocodingContributionsLoadFailed;

  /// No description provided for @geocodingContributionsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get geocodingContributionsFilterAll;

  /// No description provided for @geocodingContributionsFilterYours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get geocodingContributionsFilterYours;

  /// No description provided for @geocodingContributionsFilterCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get geocodingContributionsFilterCommunity;

  /// No description provided for @geocodingContributionsSourceYours.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get geocodingContributionsSourceYours;

  /// No description provided for @geocodingContributionsSourceCommunity.
  ///
  /// In en, this message translates to:
  /// **'From crowdsource'**
  String get geocodingContributionsSourceCommunity;

  /// No description provided for @geocodingContributionAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get geocodingContributionAddTitle;

  /// No description provided for @geocodingContributionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit location'**
  String get geocodingContributionEditTitle;

  /// No description provided for @geocodingContributionAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get geocodingContributionAddAction;

  /// No description provided for @geocodingContributionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get geocodingContributionNameLabel;

  /// No description provided for @geocodingContributionLatitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get geocodingContributionLatitudeLabel;

  /// No description provided for @geocodingContributionLongitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get geocodingContributionLongitudeLabel;

  /// No description provided for @geocodingContributionNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get geocodingContributionNotesLabel;

  /// No description provided for @geocodingContributionCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country (optional)'**
  String get geocodingContributionCountryLabel;

  /// No description provided for @geocodingContributionCountryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get geocodingContributionCountryNone;

  /// No description provided for @geocodingContributionInvalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter valid latitude and longitude values.'**
  String get geocodingContributionInvalidCoordinates;

  /// No description provided for @geocodingContributionSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved.'**
  String get geocodingContributionSaved;

  /// No description provided for @geocodingContributionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Location removed.'**
  String get geocodingContributionDeleted;

  /// No description provided for @geocodingContributionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove location?'**
  String get geocodingContributionDeleteTitle;

  /// No description provided for @geocodingContributionDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from custom geocoding data?'**
  String geocodingContributionDeleteMessage(String name);

  /// No description provided for @geocodingContributionImportedBadge.
  ///
  /// In en, this message translates to:
  /// **'community'**
  String get geocodingContributionImportedBadge;

  /// No description provided for @geocodingContributionsArchiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or import custom locations as a separate JSON file, or remove all custom records from the server.'**
  String get geocodingContributionsArchiveDescription;

  /// No description provided for @geocodingContributionDataExported.
  ///
  /// In en, this message translates to:
  /// **'Custom location data exported.'**
  String get geocodingContributionDataExported;

  /// No description provided for @geocodingImportContributionArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Import custom locations?'**
  String get geocodingImportContributionArchiveTitle;

  /// No description provided for @geocodingImportContributionArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Merge locations from the selected file into the server. Existing entries with the same name and coordinates are updated.'**
  String get geocodingImportContributionArchiveMessage;

  /// No description provided for @geocodingContributionArchiveImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} custom locations.'**
  String geocodingContributionArchiveImported(int count);

  /// No description provided for @geocodingRemoveAllContributionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all custom locations?'**
  String get geocodingRemoveAllContributionsTitle;

  /// No description provided for @geocodingRemoveAllContributionsMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes every custom location from the geocoding server. Downloaded OSMNames data is not affected.'**
  String get geocodingRemoveAllContributionsMessage;

  /// No description provided for @geocodingContributionsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} custom locations.'**
  String geocodingContributionsRemoved(int count);

  /// No description provided for @geocodingRowLabelContributions.
  ///
  /// In en, this message translates to:
  /// **'locations'**
  String get geocodingRowLabelContributions;

  /// No description provided for @geocodingCrowdsourceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Crowdsource geocoding'**
  String get geocodingCrowdsourceSectionTitle;

  /// No description provided for @geocodingCrowdsourceSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Import anonymous community locations from a public git repository, or submit your local locations without sharing any personal information.'**
  String get geocodingCrowdsourceSectionDescription;

  /// No description provided for @geocodingCrowdsourceUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Crowdsource data URL'**
  String get geocodingCrowdsourceUrlLabel;

  /// No description provided for @geocodingCrowdsourceUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a crowdsource data URL.'**
  String get geocodingCrowdsourceUrlRequired;

  /// No description provided for @geocodingCrowdsourceSaveUrl.
  ///
  /// In en, this message translates to:
  /// **'Save crowdsource URL'**
  String get geocodingCrowdsourceSaveUrl;

  /// No description provided for @geocodingCrowdsourceUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'Crowdsource URL saved.'**
  String get geocodingCrowdsourceUrlSaved;

  /// No description provided for @geocodingCrowdsourceImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import crowdsource data'**
  String get geocodingCrowdsourceImportAction;

  /// No description provided for @geocodingCrowdsourceSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Submit to crowdsource'**
  String get geocodingCrowdsourceSubmitAction;

  /// No description provided for @geocodingCrowdsourceSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit anonymously?'**
  String get geocodingCrowdsourceSubmitTitle;

  /// No description provided for @geocodingCrowdsourceSubmitMessage.
  ///
  /// In en, this message translates to:
  /// **'Only location names and coordinates are shared. No account information or personal identifiers are included.'**
  String get geocodingCrowdsourceSubmitMessage;

  /// No description provided for @geocodingCrowdsourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} crowdsource locations.'**
  String geocodingCrowdsourceImported(int count);

  /// No description provided for @geocodingCrowdsourceSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted {count} anonymous locations to the crowdsource repository.'**
  String geocodingCrowdsourceSubmitted(int count);

  /// No description provided for @geocodingCrowdsourceBundleSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved an anonymous bundle with {count} locations. Submit it to the crowdsource repository manually.'**
  String geocodingCrowdsourceBundleSaved(int count);

  /// No description provided for @geocodingSettingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load geocoding settings: {error}'**
  String geocodingSettingsLoadFailed(String error);

  /// No description provided for @geocodingStatusNotImported.
  ///
  /// In en, this message translates to:
  /// **'Not imported'**
  String get geocodingStatusNotImported;

  /// No description provided for @geocodingStatusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get geocodingStatusDownloading;

  /// No description provided for @geocodingStatusImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get geocodingStatusImporting;

  /// No description provided for @geocodingStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready ({count} {label})'**
  String geocodingStatusReady(String count, String label);

  /// No description provided for @geocodingStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get geocodingStatusFailed;

  /// No description provided for @geocodingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get geocodingStatusCancelled;

  /// No description provided for @geocodingCustomUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom URL'**
  String get geocodingCustomUrlLabel;

  /// No description provided for @geocodingRowLabelPlaces.
  ///
  /// In en, this message translates to:
  /// **'places'**
  String get geocodingRowLabelPlaces;

  /// No description provided for @geocodingRowLabelAddresses.
  ///
  /// In en, this message translates to:
  /// **'addresses'**
  String get geocodingRowLabelAddresses;

  /// No description provided for @geocodingRowLabelRows.
  ///
  /// In en, this message translates to:
  /// **'rows'**
  String get geocodingRowLabelRows;

  /// No description provided for @geocodingImportProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · {count} {rowLabel} imported'**
  String geocodingImportProgress(String percent, String count, String rowLabel);

  /// No description provided for @geocodingImportPhaseDownloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading dataset'**
  String get geocodingImportPhaseDownloadingTitle;

  /// No description provided for @geocodingImportPhaseDownloadingDetail.
  ///
  /// In en, this message translates to:
  /// **'Fetching the compressed place-name file from the internet.'**
  String get geocodingImportPhaseDownloadingDetail;

  /// No description provided for @geocodingImportPhaseImportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading place names'**
  String get geocodingImportPhaseImportingTitle;

  /// No description provided for @geocodingImportPhaseImportingDetail.
  ///
  /// In en, this message translates to:
  /// **'Saving places to the server as they are read from the file.'**
  String get geocodingImportPhaseImportingDetail;

  /// No description provided for @geocodingImportPhaseImportingAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading street addresses'**
  String get geocodingImportPhaseImportingAddressesTitle;

  /// No description provided for @geocodingImportPhaseImportingAddressesDetail.
  ///
  /// In en, this message translates to:
  /// **'Saving addresses to the server as they are read from the file.'**
  String get geocodingImportPhaseImportingAddressesDetail;

  /// No description provided for @geocodingImportPhaseFinalizingTitle.
  ///
  /// In en, this message translates to:
  /// **'Wrapping up'**
  String get geocodingImportPhaseFinalizingTitle;

  /// No description provided for @geocodingImportPhaseFinalizingDetail.
  ///
  /// In en, this message translates to:
  /// **'Saving the last batch before the final step.'**
  String get geocodingImportPhaseFinalizingDetail;

  /// No description provided for @geocodingImportPhaseCommittingTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get geocodingImportPhaseCommittingTitle;

  /// No description provided for @geocodingImportPhaseCommittingDetail.
  ///
  /// In en, this message translates to:
  /// **'All {count} {rowLabel} have been read. The server is now saving them for search. This can take one to three hours and the progress bar may pause here.'**
  String geocodingImportPhaseCommittingDetail(String count, String rowLabel);

  /// No description provided for @geocodingImportDoNotRestartTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the server running'**
  String get geocodingImportDoNotRestartTitle;

  /// No description provided for @geocodingImportDoNotRestartMessage.
  ///
  /// In en, this message translates to:
  /// **'Do not restart or stop the server during this step. If you do, the import will be cancelled and you\'ll need to start over from the beginning.'**
  String get geocodingImportDoNotRestartMessage;

  /// No description provided for @geocodingSourceUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Geocoding source URL is required.'**
  String get geocodingSourceUrlRequired;

  /// No description provided for @geocodingPlanetImportStarted.
  ///
  /// In en, this message translates to:
  /// **'Full planet place import started. This can take many hours.'**
  String get geocodingPlanetImportStarted;

  /// No description provided for @geocodingPlaceImportStarted.
  ///
  /// In en, this message translates to:
  /// **'Place-name import started.'**
  String get geocodingPlaceImportStarted;

  /// No description provided for @geocodingPlaceImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Place import failed: {error}'**
  String geocodingPlaceImportFailed(String error);

  /// No description provided for @geocodingPlaceImportAbortRequested.
  ///
  /// In en, this message translates to:
  /// **'Place import abort requested. Existing data will be kept.'**
  String get geocodingPlaceImportAbortRequested;

  /// No description provided for @geocodingAbortFailed.
  ///
  /// In en, this message translates to:
  /// **'Abort failed: {error}'**
  String geocodingAbortFailed(String error);

  /// No description provided for @geocodingHousenumbersUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Housenumbers source URL is required.'**
  String get geocodingHousenumbersUrlRequired;

  /// No description provided for @geocodingHousenumbersImportStarted.
  ///
  /// In en, this message translates to:
  /// **'Housenumbers import started. This can take many hours.'**
  String get geocodingHousenumbersImportStarted;

  /// No description provided for @geocodingHousenumbersImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Housenumbers import failed: {error}'**
  String geocodingHousenumbersImportFailed(String error);

  /// No description provided for @geocodingAddressImportAbortRequested.
  ///
  /// In en, this message translates to:
  /// **'Address import abort requested. Existing data will be kept.'**
  String get geocodingAddressImportAbortRequested;

  /// No description provided for @geocodingPlaceDataExported.
  ///
  /// In en, this message translates to:
  /// **'Place data exported.'**
  String get geocodingPlaceDataExported;

  /// No description provided for @geocodingImportPlaceArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Import place archive?'**
  String get geocodingImportPlaceArchiveTitle;

  /// No description provided for @geocodingImportPlaceArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces all place-name records on the server with the selected archive file.'**
  String get geocodingImportPlaceArchiveMessage;

  /// No description provided for @geocodingPlaceArchiveImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} place record(s).'**
  String geocodingPlaceArchiveImported(int count);

  /// No description provided for @geocodingImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String geocodingImportFailed(String error);

  /// No description provided for @geocodingRemoveAllPlacesTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all place records?'**
  String get geocodingRemoveAllPlacesTitle;

  /// No description provided for @geocodingRemoveAllPlacesMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every place-name record from the server. This cannot be undone.'**
  String get geocodingRemoveAllPlacesMessage;

  /// No description provided for @geocodingPlacesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} place record(s).'**
  String geocodingPlacesRemoved(int count);

  /// No description provided for @geocodingRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Remove failed: {error}'**
  String geocodingRemoveFailed(String error);

  /// No description provided for @geocodingHousenumberDataExported.
  ///
  /// In en, this message translates to:
  /// **'Housenumber data exported.'**
  String get geocodingHousenumberDataExported;

  /// No description provided for @geocodingImportHousenumberArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Import housenumber archive?'**
  String get geocodingImportHousenumberArchiveTitle;

  /// No description provided for @geocodingImportHousenumberArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces all street-address records on the server with the selected archive file.'**
  String get geocodingImportHousenumberArchiveMessage;

  /// No description provided for @geocodingHousenumberArchiveImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} address record(s).'**
  String geocodingHousenumberArchiveImported(int count);

  /// No description provided for @geocodingRemoveAllAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all address records?'**
  String get geocodingRemoveAllAddressesTitle;

  /// No description provided for @geocodingRemoveAllAddressesMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every housenumber record from the server. This cannot be undone.'**
  String get geocodingRemoveAllAddressesMessage;

  /// No description provided for @geocodingAddressesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} address record(s).'**
  String geocodingAddressesRemoved(int count);

  /// No description provided for @geocodingPlanetImportWarning.
  ///
  /// In en, this message translates to:
  /// **'The full planet import downloads about 1.4 GB and can take many hours to finish. For most users, start with the sample dataset or import a single country instead.'**
  String get geocodingPlanetImportWarning;

  /// No description provided for @geocodingCountryImportDownloadNote.
  ///
  /// In en, this message translates to:
  /// **'Country imports still download the global OSMNames file (~1.4 GB), but only the selected country is loaded into the database, so import finishes much sooner than the full planet.'**
  String get geocodingCountryImportDownloadNote;

  /// No description provided for @geocodingHousenumbersImportWarning.
  ///
  /// In en, this message translates to:
  /// **'The housenumbers file is separate from place names and is also about 1.4 GB compressed. Import can take many hours and loads street addresses (house number + street) worldwide. Place-name search and address search work independently.'**
  String get geocodingHousenumbersImportWarning;

  /// No description provided for @geocodingDatasetSample.
  ///
  /// In en, this message translates to:
  /// **'Sample (100k places)'**
  String get geocodingDatasetSample;

  /// No description provided for @geocodingDatasetSampleDescription.
  ///
  /// In en, this message translates to:
  /// **'A small preview dataset. Best for testing search in a few minutes.'**
  String get geocodingDatasetSampleDescription;

  /// No description provided for @geocodingDatasetPlanet.
  ///
  /// In en, this message translates to:
  /// **'Full planet (~23M places)'**
  String get geocodingDatasetPlanet;

  /// No description provided for @geocodingDatasetPlanetDescription.
  ///
  /// In en, this message translates to:
  /// **'Imports every place in the OSMNames planet file. The download is about 1.4 GB compressed and the import can take many hours depending on your server hardware and network speed.'**
  String get geocodingDatasetPlanetDescription;

  /// No description provided for @geocodingDatasetUs.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get geocodingDatasetUs;

  /// No description provided for @geocodingDatasetUsDescription.
  ///
  /// In en, this message translates to:
  /// **'Downloads the global OSMNames file but only imports United States places. The download is still large, but the database import is much faster than the full planet.'**
  String get geocodingDatasetUsDescription;

  /// No description provided for @geocodingDatasetCa.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get geocodingDatasetCa;

  /// No description provided for @geocodingDatasetCaDescription.
  ///
  /// In en, this message translates to:
  /// **'Downloads the global OSMNames file but only imports Canadian places.'**
  String get geocodingDatasetCaDescription;

  /// No description provided for @geocodingDatasetMx.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get geocodingDatasetMx;

  /// No description provided for @geocodingDatasetGb.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get geocodingDatasetGb;

  /// No description provided for @geocodingDatasetDe.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get geocodingDatasetDe;

  /// No description provided for @geocodingDatasetFr.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get geocodingDatasetFr;

  /// No description provided for @geocodingDatasetEs.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get geocodingDatasetEs;

  /// No description provided for @geocodingDatasetIt.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get geocodingDatasetIt;

  /// No description provided for @geocodingDatasetNl.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get geocodingDatasetNl;

  /// No description provided for @geocodingDatasetAu.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get geocodingDatasetAu;

  /// No description provided for @geocodingDatasetNz.
  ///
  /// In en, this message translates to:
  /// **'New Zealand'**
  String get geocodingDatasetNz;

  /// No description provided for @geocodingDatasetJp.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get geocodingDatasetJp;

  /// No description provided for @geocodingDatasetBr.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get geocodingDatasetBr;

  /// No description provided for @geocodingDatasetIn.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get geocodingDatasetIn;

  /// No description provided for @geocodingDatasetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom URL…'**
  String get geocodingDatasetCustom;

  /// No description provided for @geocodingDatasetCustomDescription.
  ///
  /// In en, this message translates to:
  /// **'Provide your own OSMNames .tsv.gz URL.'**
  String get geocodingDatasetCustomDescription;

  /// No description provided for @mapRadialMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get mapRadialMarker;

  /// No description provided for @mapRadialLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get mapRadialLine;

  /// No description provided for @mapRadialCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get mapRadialCircle;

  /// No description provided for @mapRadialRectCenter.
  ///
  /// In en, this message translates to:
  /// **'Rect center'**
  String get mapRadialRectCenter;

  /// No description provided for @mapRadialRectCorners.
  ///
  /// In en, this message translates to:
  /// **'Rect corners'**
  String get mapRadialRectCorners;

  /// No description provided for @mapRadialCopyCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Copy coordinates'**
  String get mapRadialCopyCoordinates;

  /// No description provided for @mapRadialAddToGeocoding.
  ///
  /// In en, this message translates to:
  /// **'Add to search'**
  String get mapRadialAddToGeocoding;

  /// No description provided for @mapAddToGeocodingSearch.
  ///
  /// In en, this message translates to:
  /// **'Add to geocoding search'**
  String get mapAddToGeocodingSearch;

  /// No description provided for @mapCoordinatesCopied.
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied to clipboard.'**
  String get mapCoordinatesCopied;

  /// No description provided for @mapMgrsCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy MGRS'**
  String get mapMgrsCopyTooltip;

  /// No description provided for @mapMgrsCopied.
  ///
  /// In en, this message translates to:
  /// **'MGRS copied to clipboard.'**
  String get mapMgrsCopied;

  /// No description provided for @mapMarkerShareUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get mapMarkerShareUrlLabel;

  /// No description provided for @mapMarkerCopyUrlTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy marker link'**
  String get mapMarkerCopyUrlTooltip;

  /// No description provided for @mapMarkerUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Marker link copied to clipboard.'**
  String get mapMarkerUrlCopied;

  /// No description provided for @mapMarkerIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Marker ID'**
  String get mapMarkerIdLabel;

  /// No description provided for @mapMarkerCopyIdTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy marker ID'**
  String get mapMarkerCopyIdTooltip;

  /// No description provided for @mapMarkerIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Marker ID copied to clipboard.'**
  String get mapMarkerIdCopied;

  /// No description provided for @mapRelativeAngleLabel.
  ///
  /// In en, this message translates to:
  /// **'Rel°'**
  String get mapRelativeAngleLabel;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get sortHue;

  /// No description provided for @sortIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get sortIcon;

  /// No description provided for @sortVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get sortVisibility;

  /// No description provided for @sortType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sortType;

  /// No description provided for @sortGroupVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get sortGroupVisible;

  /// No description provided for @sortGroupHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get sortGroupHidden;

  /// No description provided for @sortGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sortGroupOther;

  /// No description provided for @sidebarSortMarkers.
  ///
  /// In en, this message translates to:
  /// **'Sort markers'**
  String get sidebarSortMarkers;

  /// No description provided for @sidebarSortZones.
  ///
  /// In en, this message translates to:
  /// **'Sort zones'**
  String get sidebarSortZones;

  /// No description provided for @rectangleSizeDimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get rectangleSizeDimensions;

  /// No description provided for @rectangleSizeArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get rectangleSizeArea;

  /// No description provided for @rectangleSizeNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get rectangleSizeNone;

  /// No description provided for @rectangleSizeDimensionsShort.
  ///
  /// In en, this message translates to:
  /// **'W×H'**
  String get rectangleSizeDimensionsShort;

  /// No description provided for @rectangleModeCenter.
  ///
  /// In en, this message translates to:
  /// **'Center rectangle'**
  String get rectangleModeCenter;

  /// No description provided for @rectangleModeCorners.
  ///
  /// In en, this message translates to:
  /// **'Corner rectangle'**
  String get rectangleModeCorners;

  /// No description provided for @mapObjectTypeRectangle.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get mapObjectTypeRectangle;

  /// No description provided for @searchSubtitleCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get searchSubtitleCoordinates;

  /// No description provided for @searchSubtitleMgrs.
  ///
  /// In en, this message translates to:
  /// **'MGRS'**
  String get searchSubtitleMgrs;

  /// No description provided for @searchSubtitleMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get searchSubtitleMarker;

  /// No description provided for @searchSubtitleZone.
  ///
  /// In en, this message translates to:
  /// **'Zone ({type})'**
  String searchSubtitleZone(String type);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, markers, zones, lat/lng, or MGRS (e.g. {example})'**
  String searchHint(String example);

  /// No description provided for @sortGroupDigits.
  ///
  /// In en, this message translates to:
  /// **'0-9'**
  String get sortGroupDigits;

  /// No description provided for @markerIconPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get markerIconPlace;

  /// No description provided for @markerIconHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get markerIconHome;

  /// No description provided for @markerIconHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get markerIconHouse;

  /// No description provided for @markerIconApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get markerIconApartment;

  /// No description provided for @markerIconCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get markerIconCity;

  /// No description provided for @markerIconTown.
  ///
  /// In en, this message translates to:
  /// **'Town'**
  String get markerIconTown;

  /// No description provided for @markerIconWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get markerIconWork;

  /// No description provided for @markerIconSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get markerIconSchool;

  /// No description provided for @markerIconStore.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get markerIconStore;

  /// No description provided for @markerIconFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get markerIconFood;

  /// No description provided for @markerIconCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get markerIconCafe;

  /// No description provided for @markerIconHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get markerIconHotel;

  /// No description provided for @markerIconChurch.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get markerIconChurch;

  /// No description provided for @markerIconMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get markerIconMosque;

  /// No description provided for @markerIconCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get markerIconCommunity;

  /// No description provided for @markerIconMedical.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get markerIconMedical;

  /// No description provided for @markerIconVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get markerIconVehicle;

  /// No description provided for @markerIconBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get markerIconBike;

  /// No description provided for @markerIconTrail.
  ///
  /// In en, this message translates to:
  /// **'Trail'**
  String get markerIconTrail;

  /// No description provided for @markerIconPark.
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get markerIconPark;

  /// No description provided for @markerIconMonument.
  ///
  /// In en, this message translates to:
  /// **'Monument'**
  String get markerIconMonument;

  /// No description provided for @markerIconGeocache.
  ///
  /// In en, this message translates to:
  /// **'Geocache'**
  String get markerIconGeocache;

  /// No description provided for @markerIconFlag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get markerIconFlag;

  /// No description provided for @markerIconStar.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get markerIconStar;

  /// No description provided for @markerIconFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get markerIconFavorite;

  /// No description provided for @markerIconWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get markerIconWarning;

  /// No description provided for @markerIconInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get markerIconInfo;

  /// No description provided for @markerIconLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get markerIconLocation;

  /// No description provided for @markerIconPhoto.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get markerIconPhoto;

  /// No description provided for @markerIconPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get markerIconPets;

  /// No description provided for @markerIconMan.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get markerIconMan;

  /// No description provided for @markerIconWoman.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get markerIconWoman;

  /// No description provided for @markerIconBoy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get markerIconBoy;

  /// No description provided for @markerIconGirl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get markerIconGirl;

  /// No description provided for @markerIconCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get markerIconCat;

  /// No description provided for @markerIconDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get markerIconDog;

  /// No description provided for @markerIconRadioTower.
  ///
  /// In en, this message translates to:
  /// **'Radio tower'**
  String get markerIconRadioTower;

  /// No description provided for @markerIconCellTower.
  ///
  /// In en, this message translates to:
  /// **'Cell tower'**
  String get markerIconCellTower;

  /// No description provided for @markerIconRadioStation.
  ///
  /// In en, this message translates to:
  /// **'Radio station'**
  String get markerIconRadioStation;

  /// No description provided for @markerIconRadioRepeater.
  ///
  /// In en, this message translates to:
  /// **'Radio repeater'**
  String get markerIconRadioRepeater;

  /// No description provided for @markerIconMeshNetworkNode.
  ///
  /// In en, this message translates to:
  /// **'Mesh node'**
  String get markerIconMeshNetworkNode;

  /// No description provided for @markerIconWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get markerIconWater;

  /// No description provided for @markerIconSupplyCache.
  ///
  /// In en, this message translates to:
  /// **'Supply cache'**
  String get markerIconSupplyCache;

  /// No description provided for @markerIconRetreat.
  ///
  /// In en, this message translates to:
  /// **'Retreat'**
  String get markerIconRetreat;

  /// No description provided for @markerIconCamp.
  ///
  /// In en, this message translates to:
  /// **'Camp'**
  String get markerIconCamp;

  /// No description provided for @markerIconFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get markerIconFuel;

  /// No description provided for @markerIconGate.
  ///
  /// In en, this message translates to:
  /// **'Gate'**
  String get markerIconGate;

  /// No description provided for @markerIconCrossing.
  ///
  /// In en, this message translates to:
  /// **'Crossing'**
  String get markerIconCrossing;

  /// No description provided for @markerIconLookout.
  ///
  /// In en, this message translates to:
  /// **'Lookout'**
  String get markerIconLookout;

  /// No description provided for @markerIconPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get markerIconPower;

  /// No description provided for @markerIconPowerPlant.
  ///
  /// In en, this message translates to:
  /// **'Power plant'**
  String get markerIconPowerPlant;

  /// No description provided for @markerIconNuclear.
  ///
  /// In en, this message translates to:
  /// **'Nuclear'**
  String get markerIconNuclear;

  /// No description provided for @markerIconNuclearPowerPlant.
  ///
  /// In en, this message translates to:
  /// **'Nuclear power plant'**
  String get markerIconNuclearPowerPlant;

  /// No description provided for @markerIconNuclearWeaponsFacility.
  ///
  /// In en, this message translates to:
  /// **'Nuclear weapons facility'**
  String get markerIconNuclearWeaponsFacility;

  /// No description provided for @markerIconGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get markerIconGarden;

  /// No description provided for @markerIconStaging.
  ///
  /// In en, this message translates to:
  /// **'Staging'**
  String get markerIconStaging;

  /// No description provided for @markerIconHazard.
  ///
  /// In en, this message translates to:
  /// **'Hazard'**
  String get markerIconHazard;

  /// No description provided for @markerIconRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get markerIconRestricted;

  /// No description provided for @markerIconRally.
  ///
  /// In en, this message translates to:
  /// **'Rally point'**
  String get markerIconRally;

  /// No description provided for @markerIconWorkshop.
  ///
  /// In en, this message translates to:
  /// **'Workshop'**
  String get markerIconWorkshop;

  /// No description provided for @markerIconBoat.
  ///
  /// In en, this message translates to:
  /// **'Boat'**
  String get markerIconBoat;

  /// No description provided for @markerIconPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get markerIconPort;

  /// No description provided for @markerIconDock.
  ///
  /// In en, this message translates to:
  /// **'Dock'**
  String get markerIconDock;

  /// No description provided for @markerIconFerry.
  ///
  /// In en, this message translates to:
  /// **'Ferry'**
  String get markerIconFerry;

  /// No description provided for @markerIconYacht.
  ///
  /// In en, this message translates to:
  /// **'Yacht'**
  String get markerIconYacht;

  /// No description provided for @markerIconSailboat.
  ///
  /// In en, this message translates to:
  /// **'Sailboat'**
  String get markerIconSailboat;

  /// No description provided for @markerIconRiverBoat.
  ///
  /// In en, this message translates to:
  /// **'River boat'**
  String get markerIconRiverBoat;

  /// No description provided for @markerIconAirstrip.
  ///
  /// In en, this message translates to:
  /// **'Airstrip / Airport'**
  String get markerIconAirstrip;

  /// No description provided for @markerIconDefense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get markerIconDefense;

  /// No description provided for @markerIconArmyBase.
  ///
  /// In en, this message translates to:
  /// **'Army base'**
  String get markerIconArmyBase;

  /// No description provided for @markerIconNavyBase.
  ///
  /// In en, this message translates to:
  /// **'Navy base'**
  String get markerIconNavyBase;

  /// No description provided for @markerIconMarineCorpsBase.
  ///
  /// In en, this message translates to:
  /// **'Marine Corps base'**
  String get markerIconMarineCorpsBase;

  /// No description provided for @markerIconAirForceBase.
  ///
  /// In en, this message translates to:
  /// **'Air Force base'**
  String get markerIconAirForceBase;

  /// No description provided for @markerIconSpaceForceBase.
  ///
  /// In en, this message translates to:
  /// **'Space Force base'**
  String get markerIconSpaceForceBase;

  /// No description provided for @markerIconCoastGuardBase.
  ///
  /// In en, this message translates to:
  /// **'Coast Guard base'**
  String get markerIconCoastGuardBase;

  /// No description provided for @markerIconHunting.
  ///
  /// In en, this message translates to:
  /// **'Hunting'**
  String get markerIconHunting;

  /// No description provided for @markerIconFishing.
  ///
  /// In en, this message translates to:
  /// **'Fishing'**
  String get markerIconFishing;

  /// No description provided for @markerIconForaging.
  ///
  /// In en, this message translates to:
  /// **'Foraging'**
  String get markerIconForaging;

  /// No description provided for @markerIconCave.
  ///
  /// In en, this message translates to:
  /// **'Cave'**
  String get markerIconCave;

  /// No description provided for @markerIconDeadZone.
  ///
  /// In en, this message translates to:
  /// **'Dead zone'**
  String get markerIconDeadZone;

  /// No description provided for @markerIconEvacRoute.
  ///
  /// In en, this message translates to:
  /// **'Evac route'**
  String get markerIconEvacRoute;

  /// No description provided for @markerIconLivestock.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get markerIconLivestock;

  /// No description provided for @markerIconPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get markerIconPharmacy;

  /// No description provided for @markerIconClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get markerIconClinic;

  /// No description provided for @markerIconDentist.
  ///
  /// In en, this message translates to:
  /// **'Dentist'**
  String get markerIconDentist;

  /// No description provided for @markerIconDoctorsOffice.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s office'**
  String get markerIconDoctorsOffice;

  /// No description provided for @markerIconEyeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Eye doctor'**
  String get markerIconEyeDoctor;

  /// No description provided for @markerIconOnFoot.
  ///
  /// In en, this message translates to:
  /// **'On foot'**
  String get markerIconOnFoot;

  /// No description provided for @markerIconHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get markerIconHorse;

  /// No description provided for @markerIconMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get markerIconMotorcycle;

  /// No description provided for @markerIconAtv.
  ///
  /// In en, this message translates to:
  /// **'ATV'**
  String get markerIconAtv;

  /// No description provided for @markerIconTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get markerIconTruck;

  /// No description provided for @markerIconBus.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get markerIconBus;

  /// No description provided for @markerIconRv.
  ///
  /// In en, this message translates to:
  /// **'RV'**
  String get markerIconRv;

  /// No description provided for @markerIconTrain.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get markerIconTrain;

  /// No description provided for @markerIconAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get markerIconAmbulance;

  /// No description provided for @markerIconFireTruck.
  ///
  /// In en, this message translates to:
  /// **'Fire truck'**
  String get markerIconFireTruck;

  /// No description provided for @markerIconFarmVehicle.
  ///
  /// In en, this message translates to:
  /// **'Farm vehicle'**
  String get markerIconFarmVehicle;

  /// No description provided for @markerIconCanoe.
  ///
  /// In en, this message translates to:
  /// **'Canoe'**
  String get markerIconCanoe;

  /// No description provided for @markerIconHelicopter.
  ///
  /// In en, this message translates to:
  /// **'Helicopter'**
  String get markerIconHelicopter;

  /// No description provided for @markerIconAirplane.
  ///
  /// In en, this message translates to:
  /// **'Airplane'**
  String get markerIconAirplane;

  /// No description provided for @markerIconGlider.
  ///
  /// In en, this message translates to:
  /// **'Glider'**
  String get markerIconGlider;

  /// No description provided for @markerIconBalloon.
  ///
  /// In en, this message translates to:
  /// **'Balloon'**
  String get markerIconBalloon;

  /// No description provided for @markerIconFalloutShelter.
  ///
  /// In en, this message translates to:
  /// **'Fallout shelter'**
  String get markerIconFalloutShelter;

  /// No description provided for @markerIconStormShelter.
  ///
  /// In en, this message translates to:
  /// **'Storm shelter'**
  String get markerIconStormShelter;

  /// No description provided for @markerIconBunker.
  ///
  /// In en, this message translates to:
  /// **'Bunker'**
  String get markerIconBunker;

  /// No description provided for @markerIconWaterWell.
  ///
  /// In en, this message translates to:
  /// **'Water well'**
  String get markerIconWaterWell;

  /// No description provided for @markerIconCistern.
  ///
  /// In en, this message translates to:
  /// **'Cistern'**
  String get markerIconCistern;

  /// No description provided for @markerIconRootCellar.
  ///
  /// In en, this message translates to:
  /// **'Root cellar'**
  String get markerIconRootCellar;

  /// No description provided for @markerIconGreenhouse.
  ///
  /// In en, this message translates to:
  /// **'Greenhouse'**
  String get markerIconGreenhouse;

  /// No description provided for @markerIconFuelDepot.
  ///
  /// In en, this message translates to:
  /// **'Fuel depot'**
  String get markerIconFuelDepot;

  /// No description provided for @markerIconTruckStop.
  ///
  /// In en, this message translates to:
  /// **'Truck stop'**
  String get markerIconTruckStop;

  /// No description provided for @markerIconRestStop.
  ///
  /// In en, this message translates to:
  /// **'Rest stop'**
  String get markerIconRestStop;

  /// No description provided for @markerIconEvChargingStation.
  ///
  /// In en, this message translates to:
  /// **'EV charging station'**
  String get markerIconEvChargingStation;

  /// No description provided for @markerIconWindTurbine.
  ///
  /// In en, this message translates to:
  /// **'Wind turbine'**
  String get markerIconWindTurbine;

  /// No description provided for @markerIconHamShack.
  ///
  /// In en, this message translates to:
  /// **'Ham shack'**
  String get markerIconHamShack;

  /// No description provided for @markerIconSecurityPost.
  ///
  /// In en, this message translates to:
  /// **'Security post'**
  String get markerIconSecurityPost;

  /// No description provided for @markerIconMedicalCache.
  ///
  /// In en, this message translates to:
  /// **'Medical cache'**
  String get markerIconMedicalCache;

  /// No description provided for @markerIconFirewoodCache.
  ///
  /// In en, this message translates to:
  /// **'Firewood cache'**
  String get markerIconFirewoodCache;

  /// No description provided for @markerIconGrainSilo.
  ///
  /// In en, this message translates to:
  /// **'Grain silo'**
  String get markerIconGrainSilo;

  /// No description provided for @markerIconSafeRoom.
  ///
  /// In en, this message translates to:
  /// **'Safe room'**
  String get markerIconSafeRoom;

  /// No description provided for @markerIconDeconStation.
  ///
  /// In en, this message translates to:
  /// **'Decon station'**
  String get markerIconDeconStation;

  /// No description provided for @markerIconPublicRestroom.
  ///
  /// In en, this message translates to:
  /// **'Public restroom'**
  String get markerIconPublicRestroom;

  /// No description provided for @markerIconOuthouse.
  ///
  /// In en, this message translates to:
  /// **'Outhouse'**
  String get markerIconOuthouse;

  /// No description provided for @markerIconLatrine.
  ///
  /// In en, this message translates to:
  /// **'Latrine'**
  String get markerIconLatrine;

  /// No description provided for @markerIconCompostingToilet.
  ///
  /// In en, this message translates to:
  /// **'Composting toilet'**
  String get markerIconCompostingToilet;

  /// No description provided for @markerIconHandWashStation.
  ///
  /// In en, this message translates to:
  /// **'Hand wash station'**
  String get markerIconHandWashStation;

  /// No description provided for @markerIconSepticTank.
  ///
  /// In en, this message translates to:
  /// **'Septic tank'**
  String get markerIconSepticTank;

  /// No description provided for @markerIconPortableToilet.
  ///
  /// In en, this message translates to:
  /// **'Portable toilet'**
  String get markerIconPortableToilet;

  /// No description provided for @markerIconAmmoCache.
  ///
  /// In en, this message translates to:
  /// **'Ammo cache'**
  String get markerIconAmmoCache;

  /// No description provided for @markerIconPoliceDepartment.
  ///
  /// In en, this message translates to:
  /// **'Police department'**
  String get markerIconPoliceDepartment;

  /// No description provided for @markerIconPostOffice.
  ///
  /// In en, this message translates to:
  /// **'Post office'**
  String get markerIconPostOffice;

  /// No description provided for @markerIconArmory.
  ///
  /// In en, this message translates to:
  /// **'Armory'**
  String get markerIconArmory;

  /// No description provided for @markerIconPrison.
  ///
  /// In en, this message translates to:
  /// **'Prison'**
  String get markerIconPrison;

  /// No description provided for @markerIconJail.
  ///
  /// In en, this message translates to:
  /// **'Jail'**
  String get markerIconJail;

  /// No description provided for @markerIconCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get markerIconCollege;

  /// No description provided for @markerIconFireStation.
  ///
  /// In en, this message translates to:
  /// **'Fire station'**
  String get markerIconFireStation;

  /// No description provided for @markerIconCourthouse.
  ///
  /// In en, this message translates to:
  /// **'Courthouse'**
  String get markerIconCourthouse;

  /// No description provided for @markerIconLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get markerIconLibrary;

  /// No description provided for @markerIconBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get markerIconBank;

  /// No description provided for @markerIconCemetery.
  ///
  /// In en, this message translates to:
  /// **'Cemetery'**
  String get markerIconCemetery;

  /// No description provided for @markerIconWildfire.
  ///
  /// In en, this message translates to:
  /// **'Wildfire'**
  String get markerIconWildfire;

  /// No description provided for @markerIconTornado.
  ///
  /// In en, this message translates to:
  /// **'Tornado'**
  String get markerIconTornado;

  /// No description provided for @markerIconHurricane.
  ///
  /// In en, this message translates to:
  /// **'Hurricane'**
  String get markerIconHurricane;

  /// No description provided for @markerIconFlood.
  ///
  /// In en, this message translates to:
  /// **'Flood'**
  String get markerIconFlood;

  /// No description provided for @markerIconStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get markerIconStorm;

  /// No description provided for @markerIconEarthquake.
  ///
  /// In en, this message translates to:
  /// **'Earthquake'**
  String get markerIconEarthquake;

  /// No description provided for @markerIconVolcano.
  ///
  /// In en, this message translates to:
  /// **'Volcano'**
  String get markerIconVolcano;

  /// No description provided for @markerIconTsunami.
  ///
  /// In en, this message translates to:
  /// **'Tsunami'**
  String get markerIconTsunami;

  /// No description provided for @markerIconLandslide.
  ///
  /// In en, this message translates to:
  /// **'Landslide'**
  String get markerIconLandslide;

  /// No description provided for @markerIconDrought.
  ///
  /// In en, this message translates to:
  /// **'Drought'**
  String get markerIconDrought;

  /// No description provided for @markerIconBlizzard.
  ///
  /// In en, this message translates to:
  /// **'Blizzard'**
  String get markerIconBlizzard;

  /// No description provided for @markerIconHail.
  ///
  /// In en, this message translates to:
  /// **'Hail'**
  String get markerIconHail;

  /// No description provided for @markerIconSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get markerIconSnow;

  /// No description provided for @markerIconIcyRoad.
  ///
  /// In en, this message translates to:
  /// **'Icy road'**
  String get markerIconIcyRoad;

  /// No description provided for @markerIconTreeDown.
  ///
  /// In en, this message translates to:
  /// **'Tree down'**
  String get markerIconTreeDown;

  /// No description provided for @markerIconPowerLineDown.
  ///
  /// In en, this message translates to:
  /// **'Power line down'**
  String get markerIconPowerLineDown;

  /// No description provided for @markerIconHighWind.
  ///
  /// In en, this message translates to:
  /// **'High wind'**
  String get markerIconHighWind;

  /// No description provided for @markerIconIceStorm.
  ///
  /// In en, this message translates to:
  /// **'Ice storm'**
  String get markerIconIceStorm;

  /// No description provided for @markerIconRoadBlocked.
  ///
  /// In en, this message translates to:
  /// **'Road blocked'**
  String get markerIconRoadBlocked;

  /// No description provided for @markerIconPowerOutage.
  ///
  /// In en, this message translates to:
  /// **'Power outage'**
  String get markerIconPowerOutage;

  /// No description provided for @markerIconWeatherStation.
  ///
  /// In en, this message translates to:
  /// **'Weather station'**
  String get markerIconWeatherStation;

  /// No description provided for @settingsRestApiTitle.
  ///
  /// In en, this message translates to:
  /// **'REST API access'**
  String get settingsRestApiTitle;

  /// No description provided for @settingsRestApiDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect the /api REST endpoints with named API keys. Create a separate key for each app or device so you can remove one without affecting the others.'**
  String get settingsRestApiDescription;

  /// No description provided for @settingsRestApiStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get settingsRestApiStatusLabel;

  /// No description provided for @settingsRestApiStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsRestApiStatusEnabled;

  /// No description provided for @settingsRestApiStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsRestApiStatusDisabled;

  /// No description provided for @settingsRestApiKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'API keys'**
  String get settingsRestApiKeysTitle;

  /// No description provided for @settingsRestApiKeysEmpty.
  ///
  /// In en, this message translates to:
  /// **'No API keys yet. Create one for each app or device that calls the REST API.'**
  String get settingsRestApiKeysEmpty;

  /// No description provided for @settingsRestApiCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create API key'**
  String get settingsRestApiCreateAction;

  /// No description provided for @settingsRestApiCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Application name'**
  String get settingsRestApiCreateNameLabel;

  /// No description provided for @settingsRestApiCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GPS tracker, Home automation'**
  String get settingsRestApiCreateNameHint;

  /// No description provided for @settingsRestApiDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get settingsRestApiDeleteAction;

  /// No description provided for @settingsRestApiDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove API key?'**
  String get settingsRestApiDeleteConfirmTitle;

  /// No description provided for @settingsRestApiDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The key \"{name}\" will stop working immediately. Other keys are unaffected.'**
  String settingsRestApiDeleteConfirmMessage(String name);

  /// No description provided for @settingsRestApiDeleted.
  ///
  /// In en, this message translates to:
  /// **'API key removed.'**
  String get settingsRestApiDeleted;

  /// No description provided for @settingsRestApiEnvKeyNote.
  ///
  /// In en, this message translates to:
  /// **'An environment API key is also configured on the server. It cannot be removed from this screen.'**
  String get settingsRestApiEnvKeyNote;

  /// No description provided for @settingsRestApiClearAction.
  ///
  /// In en, this message translates to:
  /// **'Remove all keys'**
  String get settingsRestApiClearAction;

  /// No description provided for @settingsRestApiClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all API keys?'**
  String get settingsRestApiClearConfirmTitle;

  /// No description provided for @settingsRestApiClearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Every stored API key will be deleted. The REST API will be open again unless an environment key is configured.'**
  String get settingsRestApiClearConfirmMessage;

  /// No description provided for @settingsRestApiCleared.
  ///
  /// In en, this message translates to:
  /// **'All stored API keys removed.'**
  String get settingsRestApiCleared;

  /// No description provided for @settingsRestApiGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'New API key'**
  String get settingsRestApiGeneratedTitle;

  /// No description provided for @settingsRestApiGeneratedFor.
  ///
  /// In en, this message translates to:
  /// **'Created for {name}.'**
  String settingsRestApiGeneratedFor(String name);

  /// No description provided for @settingsRestApiGeneratedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy this key now. It is shown only once. Use it as X-API-Key or Authorization: Bearer <key>.'**
  String get settingsRestApiGeneratedMessage;

  /// No description provided for @settingsRestApiCopyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy key'**
  String get settingsRestApiCopyAction;

  /// No description provided for @settingsRestApiCopied.
  ///
  /// In en, this message translates to:
  /// **'API key copied.'**
  String get settingsRestApiCopied;

  /// No description provided for @settingsRestApiLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load REST API settings: {error}'**
  String settingsRestApiLoadFailed(String error);

  /// No description provided for @settingsRestApiClientKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Key on this device'**
  String get settingsRestApiClientKeyTitle;

  /// No description provided for @settingsRestApiClientKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Store the API key here so this app can call REST fallbacks (backup restore, settings sync, etc.).'**
  String get settingsRestApiClientKeyDescription;

  /// No description provided for @settingsRestApiClientKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get settingsRestApiClientKeyLabel;

  /// No description provided for @settingsRestApiSaveClientKeyAction.
  ///
  /// In en, this message translates to:
  /// **'Save key on this device'**
  String get settingsRestApiSaveClientKeyAction;

  /// No description provided for @settingsRestApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved on this device.'**
  String get settingsRestApiKeySaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
