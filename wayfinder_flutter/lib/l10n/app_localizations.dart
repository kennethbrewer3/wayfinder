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

  /// No description provided for @settingsLineArrowsTitle.
  ///
  /// In en, this message translates to:
  /// **'Line direction arrows'**
  String get settingsLineArrowsTitle;

  /// No description provided for @settingsLineArrowsDescription.
  ///
  /// In en, this message translates to:
  /// **'Control how often direction arrows appear along lines on the map. Stored on the server so every browser uses the same spacing.'**
  String get settingsLineArrowsDescription;

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
  /// **'Export or restore all layers, markers, and zones. You can also back up with curl: GET /api/map-data'**
  String get backupDescription;

  /// No description provided for @backupExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export map data (.json)'**
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
  /// **'This replaces all layers, markers, and zones on the server with the selected backup file. This cannot be undone.'**
  String get backupRestoreConfirmMessage;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {layers} layer(s), {markers} marker(s), and {zones} zone(s).'**
  String backupRestoreSuccess(int layers, int markers, int zones);

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String backupRestoreFailed(String error);

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

  /// No description provided for @searchReadinessFullReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Full search ready'**
  String get searchReadinessFullReadyTitle;

  /// No description provided for @searchReadinessAddressReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Address search ready'**
  String get searchReadinessAddressReadyTitle;

  /// No description provided for @searchReadinessNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search not ready yet'**
  String get searchReadinessNotReadyTitle;

  /// No description provided for @searchReadinessIndexesBuilt.
  ///
  /// In en, this message translates to:
  /// **'Indexes built: {ready} of {total}'**
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

  /// No description provided for @searchReadinessAddressOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Street address search is ready. Place-name search is still being prepared.'**
  String get searchReadinessAddressOnlyMessage;

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
  /// **'Download OSMNames data to the server for offline search. Place names and street addresses are imported separately.'**
  String get geocodingDescription;

  /// No description provided for @geocodingPlacesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Place names (geonames.tsv)'**
  String get geocodingPlacesSectionTitle;

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
  /// **'Search places, markers, zones, or lat, lng (e.g. {example})'**
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
  /// **'Medical'**
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
  /// **'Photo'**
  String get markerIconPhoto;

  /// No description provided for @markerIconPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get markerIconPets;

  /// No description provided for @markerIconRadioTower.
  ///
  /// In en, this message translates to:
  /// **'Radio tower'**
  String get markerIconRadioTower;

  /// No description provided for @markerIconRadioRepeater.
  ///
  /// In en, this message translates to:
  /// **'Radio repeater'**
  String get markerIconRadioRepeater;
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
