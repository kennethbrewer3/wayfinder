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

  /// No description provided for @settingsTabThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get settingsTabThemes;

  /// No description provided for @settingsTabGeocoding.
  ///
  /// In en, this message translates to:
  /// **'Geocoding'**
  String get settingsTabGeocoding;

  /// No description provided for @settingsTabRouting.
  ///
  /// In en, this message translates to:
  /// **'Routing'**
  String get settingsTabRouting;

  /// No description provided for @settingsTabTides.
  ///
  /// In en, this message translates to:
  /// **'Tides'**
  String get settingsTabTides;

  /// No description provided for @settingsTabSeasonalOverlays.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get settingsTabSeasonalOverlays;

  /// No description provided for @settingsTabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users & roles'**
  String get settingsTabUsers;

  /// No description provided for @settingsTabTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get settingsTabTrash;

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

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @mapObjectDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get mapObjectDeletedSnackbar;

  /// No description provided for @mapObjectDeletedNamedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'“{name}” moved to trash'**
  String mapObjectDeletedNamedSnackbar(String name);

  /// No description provided for @mapObjectCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get mapObjectCreatedBy;

  /// No description provided for @mapObjectUpdatedBy.
  ///
  /// In en, this message translates to:
  /// **'Last edited by'**
  String get mapObjectUpdatedBy;

  /// No description provided for @mapObjectAttributionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get mapObjectAttributionUnknown;

  /// No description provided for @mapObjectTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get mapObjectTrashTitle;

  /// No description provided for @mapObjectTrashHelp.
  ///
  /// In en, this message translates to:
  /// **'Soft-deleted markers and zones can be restored or permanently removed. Permanent delete cannot be undone.'**
  String get mapObjectTrashHelp;

  /// No description provided for @mapObjectTrashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty.'**
  String get mapObjectTrashEmpty;

  /// No description provided for @mapObjectTrashLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load trash: {error}'**
  String mapObjectTrashLoadFailed(String error);

  /// No description provided for @mapObjectTrashMarkersSection.
  ///
  /// In en, this message translates to:
  /// **'Markers'**
  String get mapObjectTrashMarkersSection;

  /// No description provided for @mapObjectTrashZonesSection.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get mapObjectTrashZonesSection;

  /// No description provided for @mapObjectTrashRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get mapObjectTrashRestore;

  /// No description provided for @mapObjectTrashPurge.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get mapObjectTrashPurge;

  /// No description provided for @mapObjectTrashRestoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore all'**
  String get mapObjectTrashRestoreAll;

  /// No description provided for @mapObjectTrashPurgeAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all permanently'**
  String get mapObjectTrashPurgeAll;

  /// No description provided for @mapObjectTrashDeletedBy.
  ///
  /// In en, this message translates to:
  /// **'Deleted by {user}'**
  String mapObjectTrashDeletedBy(String user);

  /// No description provided for @mapObjectTrashPurgeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently?'**
  String get mapObjectTrashPurgeConfirmTitle;

  /// No description provided for @mapObjectTrashPurgeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” will be removed forever, including attachments.'**
  String mapObjectTrashPurgeConfirmBody(String name);

  /// No description provided for @mapObjectTrashPurgeAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all permanently?'**
  String get mapObjectTrashPurgeAllConfirmTitle;

  /// No description provided for @mapObjectTrashPurgeAllConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everything in trash will be removed forever, including attachments.'**
  String get mapObjectTrashPurgeAllConfirmBody;

  /// No description provided for @mapObjectTrashPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to restore or permanently delete items from trash.'**
  String get mapObjectTrashPermissionDenied;

  /// No description provided for @accessSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the username your TOC administrator created for you. No email is sent — this app is designed for offline use.'**
  String get accessSignInSubtitle;

  /// No description provided for @accessSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage users and roles.'**
  String get accessSignInRequired;

  /// No description provided for @accessSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accessSignInAction;

  /// No description provided for @accessSessionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load access session: {error}'**
  String accessSessionLoadFailed(String error);

  /// No description provided for @accessRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get accessRetry;

  /// No description provided for @accessConnectionHint.
  ///
  /// In en, this message translates to:
  /// **'If this device cannot reach localhost, enter your Wayfinder API and web server addresses below (LAN IP or hostname).'**
  String get accessConnectionHint;

  /// No description provided for @accessServerUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'API server URL for sign-in and live data (Serverpod). Do not use localhost on a phone.'**
  String get accessServerUrlHelp;

  /// No description provided for @accessServerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://wayfinder-api.example.com'**
  String get accessServerUrlHint;

  /// No description provided for @accessWebServerUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Web server URL for map tiles (PMTiles), REST, and file downloads. Often a different host than the API.'**
  String get accessWebServerUrlHelp;

  /// No description provided for @accessWebServerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://wayfinder-web.example.com'**
  String get accessWebServerUrlHint;

  /// No description provided for @accessServerUrlApplied.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {apiUrl}…'**
  String accessServerUrlApplied(String apiUrl);

  /// No description provided for @accessServerUrlsApplied.
  ///
  /// In en, this message translates to:
  /// **'Connecting…\nAPI: {apiUrl}\nWeb: {webUrl}'**
  String accessServerUrlsApplied(String apiUrl, String webUrl);

  /// No description provided for @accessApiServerConfigured.
  ///
  /// In en, this message translates to:
  /// **'API server: {apiUrl}'**
  String accessApiServerConfigured(String apiUrl);

  /// No description provided for @accessChangeApiServer.
  ///
  /// In en, this message translates to:
  /// **'Change API server'**
  String get accessChangeApiServer;

  /// No description provided for @accessSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accessSignOut;

  /// No description provided for @accessChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accessChangePassword;

  /// No description provided for @accessChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accessChangePasswordTitle;

  /// No description provided for @accessChangePasswordSave.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get accessChangePasswordSave;

  /// No description provided for @accessCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get accessCurrentPasswordLabel;

  /// No description provided for @accessNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get accessNewPasswordLabel;

  /// No description provided for @accessConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get accessConfirmPasswordLabel;

  /// No description provided for @accessChangePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get accessChangePasswordTooShort;

  /// No description provided for @accessChangePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match.'**
  String get accessChangePasswordMismatch;

  /// No description provided for @accessChangePasswordSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from the current password.'**
  String get accessChangePasswordSameAsCurrent;

  /// No description provided for @accessChangePasswordFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and a new password.'**
  String get accessChangePasswordFieldsRequired;

  /// No description provided for @accessChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get accessChangePasswordSuccess;

  /// No description provided for @accessChangePasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change password: {error}'**
  String accessChangePasswordFailed(String error);

  /// No description provided for @accessSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get accessSignedIn;

  /// No description provided for @accessUnknownRole.
  ///
  /// In en, this message translates to:
  /// **'No role'**
  String get accessUnknownRole;

  /// No description provided for @accessUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get accessUsersTitle;

  /// No description provided for @accessUsersHelp.
  ///
  /// In en, this message translates to:
  /// **'Create TOC accounts and assign roles. Usernames are local login IDs — Wayfinder does not send email.'**
  String get accessUsersHelp;

  /// No description provided for @accessUsersPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage users or roles.'**
  String get accessUsersPermissionDenied;

  /// No description provided for @manageLayersPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage map layers or seasonal overlays.'**
  String get manageLayersPermissionDenied;

  /// No description provided for @accessUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users yet. Create an administrator or set WAYFINDER_BOOTSTRAP_ADMIN_EMAIL / PASSWORD (username + password).'**
  String get accessUsersEmpty;

  /// No description provided for @accessUsersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load users: {error}'**
  String accessUsersLoadFailed(String error);

  /// No description provided for @accessCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create user'**
  String get accessCreateUser;

  /// No description provided for @accessUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accessUsernameLabel;

  /// No description provided for @accessUsernameHelp.
  ///
  /// In en, this message translates to:
  /// **'Local login id for this TOC. No email is sent.'**
  String get accessUsernameHelp;

  /// No description provided for @accessEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accessEmailLabel;

  /// No description provided for @accessPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accessPasswordLabel;

  /// No description provided for @accessDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get accessDisplayNameLabel;

  /// No description provided for @accessRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get accessRoleLabel;

  /// No description provided for @accessChangeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get accessChangeRole;

  /// No description provided for @accessBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get accessBlockUser;

  /// No description provided for @accessUnblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get accessUnblockUser;

  /// No description provided for @accessResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get accessResetPassword;

  /// No description provided for @accessResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password for {email}'**
  String accessResetPasswordTitle(String email);

  /// No description provided for @accessResetPasswordSave.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get accessResetPasswordSave;

  /// No description provided for @accessResetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset for {email}.'**
  String accessResetPasswordSuccess(String email);

  /// No description provided for @accessResetPasswordFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reset password: {error}'**
  String accessResetPasswordFailed(String error);

  /// No description provided for @accessDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Remove user'**
  String get accessDeleteUser;

  /// No description provided for @accessDeleteUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove user?'**
  String get accessDeleteUserTitle;

  /// No description provided for @accessDeleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {email}? Their account and preferences will be deleted. This cannot be undone.'**
  String accessDeleteUserConfirm(String email);

  /// No description provided for @accessDeleteUserSuccess.
  ///
  /// In en, this message translates to:
  /// **'Removed {email}.'**
  String accessDeleteUserSuccess(String email);

  /// No description provided for @accessUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get accessUserBlocked;

  /// No description provided for @accessRolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get accessRolesTitle;

  /// No description provided for @accessRolesHelp.
  ///
  /// In en, this message translates to:
  /// **'Built-in Administrator, Editor, and Viewer roles are seeded automatically. Create custom roles and choose permissions.'**
  String get accessRolesHelp;

  /// No description provided for @accessRolesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No roles found.'**
  String get accessRolesEmpty;

  /// No description provided for @accessRolesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load roles: {error}'**
  String accessRolesLoadFailed(String error);

  /// No description provided for @accessCreateRole.
  ///
  /// In en, this message translates to:
  /// **'Create role'**
  String get accessCreateRole;

  /// No description provided for @accessEditRole.
  ///
  /// In en, this message translates to:
  /// **'Edit role'**
  String get accessEditRole;

  /// No description provided for @accessDeleteRole.
  ///
  /// In en, this message translates to:
  /// **'Delete role'**
  String get accessDeleteRole;

  /// No description provided for @accessRoleKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Role key'**
  String get accessRoleKeyLabel;

  /// No description provided for @accessRoleKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, numbers, and underscores.'**
  String get accessRoleKeyHelp;

  /// No description provided for @accessRoleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get accessRoleNameLabel;

  /// No description provided for @accessRoleDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get accessRoleDescriptionLabel;

  /// No description provided for @accessPermissionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get accessPermissionsLabel;

  /// No description provided for @accessRoleMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members} =1{1 member} other{{count} members}}'**
  String accessRoleMemberCount(int count);

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

  /// No description provided for @settingsAboutRoutingServer.
  ///
  /// In en, this message translates to:
  /// **'Routing server'**
  String get settingsAboutRoutingServer;

  /// No description provided for @settingsAboutRoutingServerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get settingsAboutRoutingServerNotConfigured;

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
  /// **'Choose a theme and toggle dark mode. Custom themes generate light and dark palettes from the same seed. Custom TOC themes are managed under Settings → Themes (manage_themes). Saved to your account so it follows you on any workstation.'**
  String get settingsAppearanceDescription;

  /// No description provided for @settingsAppearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsAppearanceTheme;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the dark palette for the selected theme. Built-in and custom themes both support light and dark.'**
  String get settingsDarkModeDescription;

  /// No description provided for @settingsThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get settingsThemesTitle;

  /// No description provided for @settingsThemesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and manage shared TOC themes. Anyone can select a theme; only users with manage_themes can create, edit, import, or export.'**
  String get settingsThemesDescription;

  /// No description provided for @settingsThemesPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You can select themes, but you do not have permission to create, edit, import, or export them.'**
  String get settingsThemesPermissionDenied;

  /// No description provided for @settingsThemesBuiltInTitle.
  ///
  /// In en, this message translates to:
  /// **'Built-in themes'**
  String get settingsThemesBuiltInTitle;

  /// No description provided for @settingsThemesBuiltInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Included with Wayfinder'**
  String get settingsThemesBuiltInSubtitle;

  /// No description provided for @settingsThemesCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom TOC themes'**
  String get settingsThemesCustomTitle;

  /// No description provided for @settingsThemesCustomEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom themes yet. Create one or import a JSON file.'**
  String get settingsThemesCustomEmpty;

  /// No description provided for @settingsThemesCustomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light and dark from seed'**
  String get settingsThemesCustomSubtitle;

  /// No description provided for @settingsThemesUseBuiltInHint.
  ///
  /// In en, this message translates to:
  /// **'Using a built-in theme'**
  String get settingsThemesUseBuiltInHint;

  /// No description provided for @settingsThemesNew.
  ///
  /// In en, this message translates to:
  /// **'New theme'**
  String get settingsThemesNew;

  /// No description provided for @settingsThemesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New theme'**
  String get settingsThemesNewTitle;

  /// No description provided for @settingsThemesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit theme'**
  String get settingsThemesEditTitle;

  /// No description provided for @settingsThemesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingsThemesEdit;

  /// No description provided for @settingsThemesDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get settingsThemesDuplicate;

  /// No description provided for @settingsThemesExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsThemesExport;

  /// No description provided for @settingsThemesImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsThemesImport;

  /// No description provided for @settingsThemesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsThemesDelete;

  /// No description provided for @settingsThemesUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get settingsThemesUse;

  /// No description provided for @settingsThemesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsThemesName;

  /// No description provided for @settingsThemesNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a theme name.'**
  String get settingsThemesNameRequired;

  /// No description provided for @settingsThemesSeedColor.
  ///
  /// In en, this message translates to:
  /// **'Seed color'**
  String get settingsThemesSeedColor;

  /// No description provided for @settingsThemesSeedColorHint.
  ///
  /// In en, this message translates to:
  /// **'Material generates both light and dark palettes from this color. Overrides below apply to the authoring brightness only.'**
  String get settingsThemesSeedColorHint;

  /// No description provided for @settingsThemesAuthoringBrightness.
  ///
  /// In en, this message translates to:
  /// **'Authoring brightness'**
  String get settingsThemesAuthoringBrightness;

  /// No description provided for @settingsThemesAuthoringBrightnessHint.
  ///
  /// In en, this message translates to:
  /// **'Edit overrides for this brightness. The opposite mode is generated automatically from the seed when you use Dark mode in Appearance.'**
  String get settingsThemesAuthoringBrightnessHint;

  /// No description provided for @settingsThemesOverridesTitle.
  ///
  /// In en, this message translates to:
  /// **'Color overrides'**
  String get settingsThemesOverridesTitle;

  /// No description provided for @settingsThemesOverridesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Applied only in the authoring brightness; the other mode uses the seed-generated palette.'**
  String get settingsThemesOverridesHint;

  /// No description provided for @settingsThemesOverrideFromSeed.
  ///
  /// In en, this message translates to:
  /// **'From seed'**
  String get settingsThemesOverrideFromSeed;

  /// No description provided for @settingsThemesClearOverride.
  ///
  /// In en, this message translates to:
  /// **'Clear override'**
  String get settingsThemesClearOverride;

  /// No description provided for @settingsThemesShowAllOverrides.
  ///
  /// In en, this message translates to:
  /// **'Show all color roles'**
  String get settingsThemesShowAllOverrides;

  /// No description provided for @settingsThemesShowFewerOverrides.
  ///
  /// In en, this message translates to:
  /// **'Show fewer color roles'**
  String get settingsThemesShowFewerOverrides;

  /// No description provided for @settingsThemesPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get settingsThemesPreview;

  /// No description provided for @settingsThemesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load themes: {error}'**
  String settingsThemesLoadFailed(String error);

  /// No description provided for @settingsThemesLoadFailedServerError.
  ///
  /// In en, this message translates to:
  /// **'The API server returned an error (HTTP 500) while listing custom themes.\n\nAPI: {apiUrl}\n\nCustom themes are loaded from the Wayfinder API (not the web/PMTiles URL). This usually means the API is outdated or missing the app_theme_definition database migration. Built-in themes above still work — update/redeploy the API and apply migrations, then retry.'**
  String settingsThemesLoadFailedServerError(String apiUrl);

  /// No description provided for @settingsThemesLoadFailedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Could not list custom themes. Sign in with an account that can view the map, then retry.\n\nAPI: {apiUrl}'**
  String settingsThemesLoadFailedSignIn(String apiUrl);

  /// No description provided for @settingsThemesLoadFailedUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the Wayfinder API to load custom themes.\n\nAPI: {apiUrl}\n\nOn a phone, confirm Settings → General uses your real API URL (not localhost) and that it is separate from the web/PMTiles URL.'**
  String settingsThemesLoadFailedUnreachable(String apiUrl);

  /// No description provided for @settingsThemesLoadFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not load custom themes.\n\nAPI: {apiUrl}\n\nDetails: {error}'**
  String settingsThemesLoadFailedGeneric(String apiUrl, String error);

  /// No description provided for @settingsThemesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get settingsThemesRetry;

  /// No description provided for @settingsThemesSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved theme “{name}”.'**
  String settingsThemesSaved(String name);

  /// No description provided for @settingsThemesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save theme: {error}'**
  String settingsThemesSaveFailed(String error);

  /// No description provided for @settingsThemesImported.
  ///
  /// In en, this message translates to:
  /// **'Imported theme “{name}”.'**
  String settingsThemesImported(String name);

  /// No description provided for @settingsThemesImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import theme: {error}'**
  String settingsThemesImportFailed(String error);

  /// No description provided for @settingsThemesExported.
  ///
  /// In en, this message translates to:
  /// **'Exported theme “{name}”.'**
  String settingsThemesExported(String name);

  /// No description provided for @settingsThemesExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export theme: {error}'**
  String settingsThemesExportFailed(String error);

  /// No description provided for @settingsThemesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete theme?'**
  String get settingsThemesDeleteTitle;

  /// No description provided for @settingsThemesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? Users who selected it will fall back to the standard light theme.'**
  String settingsThemesDeleteMessage(String name);

  /// No description provided for @settingsThemesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted theme “{name}”.'**
  String settingsThemesDeleted(String name);

  /// No description provided for @settingsThemesDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete theme: {error}'**
  String settingsThemesDeleteFailed(String error);

  /// No description provided for @settingsThemesCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} copy'**
  String settingsThemesCopyName(String name);

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout the app. Saved to your account so it follows you on any workstation.'**
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

  /// No description provided for @settingsMapHomePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change the shared map home location.'**
  String get settingsMapHomePermissionDenied;

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
  /// **'Enter both the Wayfinder API URL (sign-in / live data) and the web URL (map tiles, REST, files). They are often different hosts behind a reverse proxy.'**
  String get settingsServerConnectionDescription;

  /// No description provided for @settingsServerConnectionPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change this device\'s Wayfinder server URL.'**
  String get settingsServerConnectionPermissionDenied;

  /// No description provided for @settingsServerUrl.
  ///
  /// In en, this message translates to:
  /// **'API server URL'**
  String get settingsServerUrl;

  /// No description provided for @settingsWebServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Web server URL'**
  String get settingsWebServerUrl;

  /// No description provided for @settingsCurrentWebServer.
  ///
  /// In en, this message translates to:
  /// **'Current web server: {webUrl}'**
  String settingsCurrentWebServer(String webUrl);

  /// No description provided for @settingsSaveServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Save server URLs'**
  String get settingsSaveServerUrl;

  /// No description provided for @settingsEditServerUrls.
  ///
  /// In en, this message translates to:
  /// **'Edit server URLs'**
  String get settingsEditServerUrls;

  /// No description provided for @settingsGeocodingAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Map search (geocoding)'**
  String get settingsGeocodingAvailabilityTitle;

  /// No description provided for @settingsGeocodingAvailabilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Whether place and address search from the map bar is available for this device.'**
  String get settingsGeocodingAvailabilityDescription;

  /// No description provided for @settingsGeocodingOpenTab.
  ///
  /// In en, this message translates to:
  /// **'Geocoding settings'**
  String get settingsGeocodingOpenTab;

  /// No description provided for @settingsRoutingAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn-by-turn routing'**
  String get settingsRoutingAvailabilityTitle;

  /// No description provided for @settingsRoutingAvailabilityDescription.
  ///
  /// In en, this message translates to:
  /// **'Whether OSM A→B routing from this device can reach the optional routing server.'**
  String get settingsRoutingAvailabilityDescription;

  /// No description provided for @settingsRoutingOpenTab.
  ///
  /// In en, this message translates to:
  /// **'Routing settings'**
  String get settingsRoutingOpenTab;

  /// No description provided for @settingsMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get settingsMeasurementsTitle;

  /// No description provided for @settingsMeasurementsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how line distances are displayed on the map. Saved to your account so it follows you on any workstation.'**
  String get settingsMeasurementsDescription;

  /// No description provided for @settingsAnglesTitle.
  ///
  /// In en, this message translates to:
  /// **'Angles'**
  String get settingsAnglesTitle;

  /// No description provided for @settingsAnglesDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how relative angles are displayed on the map and in bearing plots. Saved to your account so it follows you on any workstation.'**
  String get settingsAnglesDescription;

  /// No description provided for @settingsBearingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bearings'**
  String get settingsBearingsTitle;

  /// No description provided for @settingsBearingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Show absolute bearings as true north (°T) or magnetic north (°M) using WMM2025 declination at your GPS or map center. The compass rose still marks true north; variation is shown underneath.'**
  String get settingsBearingsDescription;

  /// No description provided for @bearingReferenceTrue.
  ///
  /// In en, this message translates to:
  /// **'True north'**
  String get bearingReferenceTrue;

  /// No description provided for @bearingReferenceMagnetic.
  ///
  /// In en, this message translates to:
  /// **'Magnetic north'**
  String get bearingReferenceMagnetic;

  /// No description provided for @bearingReferenceTrueShort.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get bearingReferenceTrueShort;

  /// No description provided for @bearingReferenceMagneticShort.
  ///
  /// In en, this message translates to:
  /// **'Magnetic'**
  String get bearingReferenceMagneticShort;

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
  /// **'Choose the default size label shown on new circular zones. Saved to your account so it follows you on any workstation.'**
  String get settingsCirclesDescription;

  /// No description provided for @settingsMapEditingTitle.
  ///
  /// In en, this message translates to:
  /// **'Map editing'**
  String get settingsMapEditingTitle;

  /// No description provided for @settingsMapEditingDescription.
  ///
  /// In en, this message translates to:
  /// **'Snapping while editing polygon and seasonal overlay vertices. Soft snaps unlock if you keep dragging past the magnet.'**
  String get settingsMapEditingDescription;

  /// No description provided for @settingsPolygonSnapRightAnglesTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap to right angles (90°)'**
  String get settingsPolygonSnapRightAnglesTitle;

  /// No description provided for @settingsPolygonSnapRightAnglesDescription.
  ///
  /// In en, this message translates to:
  /// **'While dragging a vertex, soft-snap to square corners — including making adjacent corners 90° for cleaner rectangles.'**
  String get settingsPolygonSnapRightAnglesDescription;

  /// No description provided for @settingsPolygonSnap45AnglesTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap to 45° angles'**
  String get settingsPolygonSnap45AnglesTitle;

  /// No description provided for @settingsPolygonSnap45AnglesDescription.
  ///
  /// In en, this message translates to:
  /// **'Also soft-snap the dragged corner toward 45° and 135° angles.'**
  String get settingsPolygonSnap45AnglesDescription;

  /// No description provided for @settingsMapDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Map display'**
  String get settingsMapDisplayTitle;

  /// No description provided for @settingsMapDisplayDescription.
  ///
  /// In en, this message translates to:
  /// **'Compass rose, MGRS grid, and dark-mode map tiles for your account. Saved to your account so it follows you on any workstation.'**
  String get settingsMapDisplayDescription;

  /// No description provided for @settingsMapCompassRoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Show compass rose'**
  String get settingsMapCompassRoseTitle;

  /// No description provided for @settingsMapCompassRoseDescription.
  ///
  /// In en, this message translates to:
  /// **'Displays a compass in the bottom-left of the map (above the GPS status bar when shown). Double-tap resets rotation; long-press toggles true/magnetic north; ±5° buttons rotate the map. Variation uses WMM2025.'**
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

  /// No description provided for @settingsDarkMapTilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Darken map tiles in dark mode'**
  String get settingsDarkMapTilesTitle;

  /// No description provided for @settingsDarkMapTilesDescription.
  ///
  /// In en, this message translates to:
  /// **'When the app is in dark mode, apply a color filter to basemap tiles so they look darker. This is a simulated dark style on the existing tiles — not a separate dark cartography design. Turn off to keep map tiles looking as usual while the rest of the UI stays dark. Printable atlas PDFs always use normal tiles for paper readability.'**
  String get settingsDarkMapTilesDescription;

  /// No description provided for @settingsMapZoomRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Map zoom range'**
  String get settingsMapZoomRangeTitle;

  /// No description provided for @settingsMapZoomRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Shared minimum and maximum zoom for all clients. Stored on the server. Raising the maximum can hurt performance if offline tiles do not cover those levels.'**
  String get settingsMapZoomRangeDescription;

  /// No description provided for @settingsMapZoomRangePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change the shared map zoom range.'**
  String get settingsMapZoomRangePermissionDenied;

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
  /// **'Aids stored on this device only.'**
  String get settingsMapDebugDescription;

  /// No description provided for @settingsMapMarkerSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Map marker size'**
  String get settingsMapMarkerSizeTitle;

  /// No description provided for @settingsMapMarkerSizeDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust how large markers appear on the map. Saved to your account so it follows you on any workstation.'**
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

  /// No description provided for @settingsForceOfflinePackTitle.
  ///
  /// In en, this message translates to:
  /// **'Use offline pack while online'**
  String get settingsForceOfflinePackTitle;

  /// No description provided for @settingsForceOfflinePackDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the prepared offline / field pack even when the Wayfinder server is reachable. Lets you test pack behavior without cutting internet for other apps.'**
  String get settingsForceOfflinePackDescription;

  /// No description provided for @settingsForceOfflinePackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Prepare an offline pack from the map toolbar first.'**
  String get settingsForceOfflinePackUnavailable;

  /// No description provided for @settingsSimulatedGpsWalkDelayTitle.
  ///
  /// In en, this message translates to:
  /// **'Simulated GPS walk delay'**
  String get settingsSimulatedGpsWalkDelayTitle;

  /// No description provided for @settingsSimulatedGpsWalkDelayDescription.
  ///
  /// In en, this message translates to:
  /// **'Seconds between fake GPS steps when simulating a walk along a followed route. Applies the next time you start simulation.'**
  String get settingsSimulatedGpsWalkDelayDescription;

  /// No description provided for @settingsSimulatedGpsWalkDelayValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String settingsSimulatedGpsWalkDelayValue(String seconds);

  /// No description provided for @settingsSimulatedGpsWalkDelayMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get settingsSimulatedGpsWalkDelayMinLabel;

  /// No description provided for @settingsSimulatedGpsWalkDelayMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get settingsSimulatedGpsWalkDelayMaxLabel;

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

  /// No description provided for @settingsServerUrlAppliedTitle.
  ///
  /// In en, this message translates to:
  /// **'Server URL updated'**
  String get settingsServerUrlAppliedTitle;

  /// No description provided for @settingsServerUrlAppliedMessage.
  ///
  /// In en, this message translates to:
  /// **'Server URL saved and applied.\n\nAPI: {apiUrl}\nWeb: {webUrl}'**
  String settingsServerUrlAppliedMessage(String apiUrl, String webUrl);

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

  /// No description provided for @watchLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident / watch log'**
  String get watchLogTitle;

  /// No description provided for @watchLogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Timestamped events for after-action review. Planning notes only — not a live CAD or radio net.'**
  String get watchLogSubtitle;

  /// No description provided for @watchLogPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view the incident / watch log.'**
  String get watchLogPermissionDenied;

  /// No description provided for @watchLogAddPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to add or edit incident / watch log entries.'**
  String get watchLogAddPermissionDenied;

  /// No description provided for @watchLogObjectHint.
  ///
  /// In en, this message translates to:
  /// **'Entries linked to this map object.'**
  String get watchLogObjectHint;

  /// No description provided for @watchLogSidebarHint.
  ///
  /// In en, this message translates to:
  /// **'Newest first across all map objects'**
  String get watchLogSidebarHint;

  /// No description provided for @watchLogAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get watchLogAddEntry;

  /// No description provided for @watchLogAddEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add watch log entry'**
  String get watchLogAddEntryTitle;

  /// No description provided for @watchLogEditEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit watch log entry'**
  String get watchLogEditEntryTitle;

  /// No description provided for @watchLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No watch log entries yet.'**
  String get watchLogEmpty;

  /// No description provided for @watchLogEmptyForObject.
  ///
  /// In en, this message translates to:
  /// **'No entries linked to this object yet.'**
  String get watchLogEmptyForObject;

  /// No description provided for @watchLogMoreEntries.
  ///
  /// In en, this message translates to:
  /// **'{count} more…'**
  String watchLogMoreEntries(int count);

  /// No description provided for @watchLogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load watch log: {error}'**
  String watchLogLoadFailed(String error);

  /// No description provided for @watchLogOccurredAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Occurred at'**
  String get watchLogOccurredAtLabel;

  /// No description provided for @watchLogAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator / callsign'**
  String get watchLogAuthorLabel;

  /// No description provided for @watchLogAuthorHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get watchLogAuthorHint;

  /// No description provided for @watchLogSeverityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get watchLogSeverityLabel;

  /// No description provided for @watchLogSeverityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get watchLogSeverityInfo;

  /// No description provided for @watchLogSeverityNotice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get watchLogSeverityNotice;

  /// No description provided for @watchLogSeverityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get watchLogSeverityWarning;

  /// No description provided for @watchLogSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get watchLogSeverityCritical;

  /// No description provided for @watchLogTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get watchLogTextLabel;

  /// No description provided for @watchLogTextHint.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get watchLogTextHint;

  /// No description provided for @watchLogTextRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter event text.'**
  String get watchLogTextRequired;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Map data backup'**
  String get backupTitle;

  /// No description provided for @backupPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to export or restore map backups.'**
  String get backupPermissionDenied;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export or restore Wayfinder map data: layers, markers, zones, seasonal overlays, watch log entries, custom marker icons, marker photos, and app settings. Backups are a .zip with backup.json, marker-icons/*.svg, and marker-attachments/*. Tide packs and PMTiles are not included (transfer those from Tides / Map tiles, or use a field pack). Legacy .json backups can still be restored (photos require the .zip).'**
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
  /// **'This replaces all layers, markers, zones, seasonal overlays, watch log entries, and custom marker icons on the server with the selected backup file. This cannot be undone.'**
  String get backupRestoreConfirmMessage;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {layers} layer(s), {markers} marker(s), {zones} zone(s), {seasonalOverlays} seasonal overlay(s), and {watchLogEntries} watch log entr(y/ies).'**
  String backupRestoreSuccess(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
  );

  /// No description provided for @backupRestoreSuccessWithIcons.
  ///
  /// In en, this message translates to:
  /// **'Restored {layers} layer(s), {markers} marker(s), {zones} zone(s), {seasonalOverlays} seasonal overlay(s), {watchLogEntries} watch log entr(y/ies), and {icons} custom icon(s).'**
  String backupRestoreSuccessWithIcons(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int icons,
  );

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String backupRestoreFailed(String error);

  /// No description provided for @markerAttachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get markerAttachmentsTitle;

  /// No description provided for @markerAttachmentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. Add a JPEG, PNG, or WebP image.'**
  String get markerAttachmentsEmpty;

  /// No description provided for @markerAttachmentsEmptyReadOnly.
  ///
  /// In en, this message translates to:
  /// **'No photos on this marker.'**
  String get markerAttachmentsEmptyReadOnly;

  /// No description provided for @markerAttachmentAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get markerAttachmentAdd;

  /// No description provided for @markerAttachmentUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get markerAttachmentUploading;

  /// No description provided for @markerAttachmentUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo added.'**
  String get markerAttachmentUploadSuccess;

  /// No description provided for @markerAttachmentUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo upload failed: {error}'**
  String markerAttachmentUploadFailed(String error);

  /// No description provided for @markerAttachmentLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load photos: {error}'**
  String markerAttachmentLoadFailed(String error);

  /// No description provided for @markerAttachmentDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get markerAttachmentDeleteConfirmTitle;

  /// No description provided for @markerAttachmentDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{fileName}\" from this marker?'**
  String markerAttachmentDeleteConfirmMessage(String fileName);

  /// No description provided for @markerAttachmentDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete photo: {error}'**
  String markerAttachmentDeleteFailed(String error);

  /// No description provided for @kioskModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Kiosk / viewer mode'**
  String get kioskModeTitle;

  /// No description provided for @kioskModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn this laptop into a TOC viewer: hide Settings and create tools, block edits, and use a quieter battery-friendly poll. Use this on spare viewer laptops pointed at your Wayfinder server. For a spare server appliance that must reject all writes, set WAYFINDER_READ_ONLY=1 on the server.'**
  String get kioskModeDescription;

  /// No description provided for @kioskModeEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter kiosk mode'**
  String get kioskModeEnter;

  /// No description provided for @kioskModeExit.
  ///
  /// In en, this message translates to:
  /// **'Exit kiosk'**
  String get kioskModeExit;

  /// No description provided for @kioskModeEntered.
  ///
  /// In en, this message translates to:
  /// **'Kiosk mode on — this device is view-only.'**
  String get kioskModeEntered;

  /// No description provided for @kioskModeEnterConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter kiosk mode?'**
  String get kioskModeEnterConfirmTitle;

  /// No description provided for @kioskModeEnterConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings and map editing will be hidden on this device until you exit kiosk mode. Other devices are not affected.'**
  String get kioskModeEnterConfirmMessage;

  /// No description provided for @kioskModeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewer mode'**
  String get kioskModeBannerTitle;

  /// No description provided for @kioskModeBannerHint.
  ///
  /// In en, this message translates to:
  /// **'This laptop is view-only. Pan, zoom, search, and inspect map objects.'**
  String get kioskModeBannerHint;

  /// No description provided for @kioskModeBannerServerEnforced.
  ///
  /// In en, this message translates to:
  /// **'This Wayfinder server is read-only (WAYFINDER_READ_ONLY). Writes are blocked for every client.'**
  String get kioskModeBannerServerEnforced;

  /// No description provided for @kioskModeSettingsLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings are hidden while this device is in kiosk / viewer mode.'**
  String get kioskModeSettingsLockedMessage;

  /// No description provided for @kioskModeBackToMap.
  ///
  /// In en, this message translates to:
  /// **'Back to map'**
  String get kioskModeBackToMap;

  /// No description provided for @fieldPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Field pack'**
  String get fieldPackTitle;

  /// No description provided for @fieldPackDescription.
  ///
  /// In en, this message translates to:
  /// **'One archive for a spare server or laptop: map objects, custom marker icons, and the PMTiles regions you select. Closely related to offline packs, but meant for transferring a full Wayfinder instance rather than caching tiles on this device.'**
  String get fieldPackDescription;

  /// No description provided for @fieldPackExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export field pack'**
  String get fieldPackExportButton;

  /// No description provided for @fieldPackRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore field pack'**
  String get fieldPackRestoreButton;

  /// No description provided for @fieldPackSelectPmtilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Include PMTiles'**
  String get fieldPackSelectPmtilesTitle;

  /// No description provided for @fieldPackSelectPmtilesMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose which map tile archives to include. Large regional files can make the pack several GB.'**
  String get fieldPackSelectPmtilesMessage;

  /// No description provided for @fieldPackSelectPmtilesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No PMTiles are installed on this server. The pack will include map data and icons only.'**
  String get fieldPackSelectPmtilesEmpty;

  /// No description provided for @fieldPackSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get fieldPackSelectAll;

  /// No description provided for @fieldPackSelectNone.
  ///
  /// In en, this message translates to:
  /// **'Select none'**
  String get fieldPackSelectNone;

  /// No description provided for @fieldPackExportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get fieldPackExportConfirm;

  /// No description provided for @fieldPackExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Field pack saved.'**
  String get fieldPackExportSuccess;

  /// No description provided for @fieldPackExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Field pack export failed: {error}'**
  String fieldPackExportFailed(String error);

  /// No description provided for @fieldPackRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore field pack?'**
  String get fieldPackRestoreConfirmTitle;

  /// No description provided for @fieldPackRestoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces all map data and custom icons on the server, and installs the PMTiles archives from the pack (matching IDs are overwritten). This cannot be undone.'**
  String get fieldPackRestoreConfirmMessage;

  /// No description provided for @fieldPackRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {layers} layer(s), {markers} marker(s), {zones} zone(s), {seasonalOverlays} seasonal overlay(s), {watchLogEntries} watch log entr(y/ies), {icons} custom icon(s), and {pmtiles} PMTiles archive(s).'**
  String fieldPackRestoreSuccess(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int icons,
    int pmtiles,
  );

  /// No description provided for @fieldPackRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Field pack restore failed: {error}'**
  String fieldPackRestoreFailed(String error);

  /// No description provided for @geoExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'GPX / KML / GeoJSON'**
  String get geoExchangeTitle;

  /// No description provided for @geoExchangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Import waypoints and tracks from GPX, KML, or GeoJSON. When the map already has markers or zones, you can add to them, replace them, or cancel. Export markers as waypoints and lines/tracks as paths.'**
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

  /// No description provided for @geoExchangeImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import geographic data?'**
  String get geoExchangeImportConfirmTitle;

  /// No description provided for @geoExchangeImportConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The map already has {markers} marker(s) and {zones} zone(s). Choose Add to keep them and import alongside, Replace to delete all markers and zones first, or Cancel to abort.'**
  String geoExchangeImportConfirmMessage(int markers, int zones);

  /// No description provided for @geoExchangeImportAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to existing'**
  String get geoExchangeImportAdd;

  /// No description provided for @geoExchangeImportReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace existing'**
  String get geoExchangeImportReplace;

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

  /// No description provided for @mapAtlasTitle.
  ///
  /// In en, this message translates to:
  /// **'Printable map atlas'**
  String get mapAtlasTitle;

  /// No description provided for @mapAtlasDescription.
  ///
  /// In en, this message translates to:
  /// **'Export a multi-page PDF of the current map area (or all markers) with the enabled PMTiles basemap, lat/lng grid, markers, zones, scale bar, and north arrow. Sheets overlap slightly for field use.'**
  String get mapAtlasDescription;

  /// No description provided for @mapAtlasExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export printable atlas (PDF)'**
  String get mapAtlasExportButton;

  /// No description provided for @mapAtlasDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Export printable atlas'**
  String get mapAtlasDialogTitle;

  /// No description provided for @mapAtlasDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose coverage, page size, and how many sheets to print. Sheets include the enabled PMTiles basemap plus overlays. Each sheet has an approximate MGRS label for its center.'**
  String get mapAtlasDialogDescription;

  /// No description provided for @mapAtlasTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Atlas title'**
  String get mapAtlasTitleLabel;

  /// No description provided for @mapAtlasCoverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get mapAtlasCoverageLabel;

  /// No description provided for @mapAtlasCoverageMapView.
  ///
  /// In en, this message translates to:
  /// **'Current map view'**
  String get mapAtlasCoverageMapView;

  /// No description provided for @mapAtlasCoverageMarkers.
  ///
  /// In en, this message translates to:
  /// **'Fit all markers'**
  String get mapAtlasCoverageMarkers;

  /// No description provided for @mapAtlasGridLabel.
  ///
  /// In en, this message translates to:
  /// **'Sheet grid'**
  String get mapAtlasGridLabel;

  /// No description provided for @mapAtlasPageSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get mapAtlasPageSizeLabel;

  /// No description provided for @mapAtlasPageLetter.
  ///
  /// In en, this message translates to:
  /// **'US Letter landscape'**
  String get mapAtlasPageLetter;

  /// No description provided for @mapAtlasPageA4.
  ///
  /// In en, this message translates to:
  /// **'A4 landscape'**
  String get mapAtlasPageA4;

  /// No description provided for @mapAtlasIncludeMarkerIndex.
  ///
  /// In en, this message translates to:
  /// **'Include marker list on each sheet'**
  String get mapAtlasIncludeMarkerIndex;

  /// No description provided for @mapAtlasIncludeActiveRoute.
  ///
  /// In en, this message translates to:
  /// **'Draw active route on map sheets'**
  String get mapAtlasIncludeActiveRoute;

  /// No description provided for @mapAtlasIncludeDirectionsList.
  ///
  /// In en, this message translates to:
  /// **'Include turn-by-turn directions page'**
  String get mapAtlasIncludeDirectionsList;

  /// No description provided for @mapAtlasCoverageActiveRoute.
  ///
  /// In en, this message translates to:
  /// **'Fit active route'**
  String get mapAtlasCoverageActiveRoute;

  /// No description provided for @mapAtlasDirectionsStepColumn.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get mapAtlasDirectionsStepColumn;

  /// No description provided for @mapAtlasDirectionsInstructionColumn.
  ///
  /// In en, this message translates to:
  /// **'Instruction'**
  String get mapAtlasDirectionsInstructionColumn;

  /// No description provided for @mapAtlasDirectionsDistanceColumn.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get mapAtlasDirectionsDistanceColumn;

  /// No description provided for @mapAtlasSheetCountHint.
  ///
  /// In en, this message translates to:
  /// **'Sheets'**
  String get mapAtlasSheetCountHint;

  /// No description provided for @mapAtlasExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Printable atlas PDF saved.'**
  String get mapAtlasExportSuccess;

  /// No description provided for @mapAtlasExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Atlas export failed: {error}'**
  String mapAtlasExportFailed(String error);

  /// No description provided for @mapAtlasExportNoCoverage.
  ///
  /// In en, this message translates to:
  /// **'Could not determine atlas coverage. Open the map first, or add visible markers and choose Fit all markers.'**
  String get mapAtlasExportNoCoverage;

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
  /// **'Organize offline map archives into groups and choose which ones are drawn on the map. Only the best-matching enabled archive is shown at once to keep the map responsive. Elevation DEM packs (name includes dem, terrarium, terrain-rgb, or elevation) are used for spot height and path profiles — enable them here, but they are not drawn as the basemap.'**
  String get mapTilesMapsDescription;

  /// No description provided for @mapTilesPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to add, update, or organize map tiles.'**
  String get mapTilesPermissionDenied;

  /// No description provided for @mapTilesDemBadge.
  ///
  /// In en, this message translates to:
  /// **'Elevation DEM'**
  String get mapTilesDemBadge;

  /// No description provided for @mapTilesUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload .pmtiles file'**
  String get mapTilesUploadButton;

  /// No description provided for @mapTilesGetMapsButton.
  ///
  /// In en, this message translates to:
  /// **'Get maps'**
  String get mapTilesGetMapsButton;

  /// No description provided for @offlinePackPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for offline'**
  String get offlinePackPrepareTitle;

  /// No description provided for @offlinePackPrepareDescription.
  ///
  /// In en, this message translates to:
  /// **'Mirror selected layers and cache basemap tiles for the current map view. Keep several AOI packs (home, bug-out, hunting lease) and activate one without rebuilding.'**
  String get offlinePackPrepareDescription;

  /// No description provided for @offlinePackPrepareAction.
  ///
  /// In en, this message translates to:
  /// **'Update offline pack'**
  String get offlinePackPrepareAction;

  /// No description provided for @offlinePackPrepareNewAction.
  ///
  /// In en, this message translates to:
  /// **'Create offline pack'**
  String get offlinePackPrepareNewAction;

  /// No description provided for @offlinePackPrepareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Prepare for offline'**
  String get offlinePackPrepareTooltip;

  /// No description provided for @offlinePackPrepareTooltipReady.
  ///
  /// In en, this message translates to:
  /// **'Offline packs ready — tap to manage'**
  String get offlinePackPrepareTooltipReady;

  /// No description provided for @offlinePackNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Pack name'**
  String get offlinePackNameLabel;

  /// No description provided for @offlinePackNameHint.
  ///
  /// In en, this message translates to:
  /// **'Home, bug-out, hunting lease…'**
  String get offlinePackNameHint;

  /// No description provided for @offlinePackDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Offline pack'**
  String get offlinePackDefaultName;

  /// No description provided for @offlinePackTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Save as'**
  String get offlinePackTargetLabel;

  /// No description provided for @offlinePackTargetNew.
  ///
  /// In en, this message translates to:
  /// **'New pack (keep existing packs)'**
  String get offlinePackTargetNew;

  /// No description provided for @offlinePackTargetReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace “{name}”'**
  String offlinePackTargetReplace(String name);

  /// No description provided for @offlinePackSavedPacksLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved packs'**
  String get offlinePackSavedPacksLabel;

  /// No description provided for @offlinePackActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get offlinePackActiveLabel;

  /// No description provided for @offlinePackInactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap Activate to switch without rebuilding'**
  String get offlinePackInactiveLabel;

  /// No description provided for @offlinePackActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get offlinePackActivateAction;

  /// No description provided for @offlinePackSwitchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch offline pack'**
  String get offlinePackSwitchTooltip;

  /// No description provided for @offlinePackSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch offline pack'**
  String get offlinePackSwitchTitle;

  /// No description provided for @offlinePackSwitchDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose which AOI pack to use. Tiles stay cached — no rebuild needed.'**
  String get offlinePackSwitchDescription;

  /// No description provided for @offlinePackLayersLabel.
  ///
  /// In en, this message translates to:
  /// **'Layers to include'**
  String get offlinePackLayersLabel;

  /// No description provided for @offlinePackIncludeSeasonalOverlays.
  ///
  /// In en, this message translates to:
  /// **'Include seasonal overlays'**
  String get offlinePackIncludeSeasonalOverlays;

  /// No description provided for @offlinePackIncludeSeasonalOverlaysHint.
  ///
  /// In en, this message translates to:
  /// **'Pack all seasonal overlays for read-only viewing offline (separate from map layers).'**
  String get offlinePackIncludeSeasonalOverlaysHint;

  /// No description provided for @offlinePackSeasonalOverlaysNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'No seasonal overlays in this offline pack. Re-prepare with “Include seasonal overlays” while online.'**
  String get offlinePackSeasonalOverlaysNotIncluded;

  /// No description provided for @offlinePackNoLayers.
  ///
  /// In en, this message translates to:
  /// **'No map layers available.'**
  String get offlinePackNoLayers;

  /// No description provided for @offlinePackSelectLayersRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one layer.'**
  String get offlinePackSelectLayersRequired;

  /// No description provided for @offlinePackZoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Tile detail (z{minZoom}–z{maxZoom})'**
  String offlinePackZoomLabel(int minZoom, int maxZoom);

  /// No description provided for @offlinePackZoomRangeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Min zoom must be less than or equal to max zoom.'**
  String get offlinePackZoomRangeInvalid;

  /// No description provided for @offlinePackEstimate.
  ///
  /// In en, this message translates to:
  /// **'About {tileCount} tiles across {archiveCount} enabled basemap(s). Large ranges can take several minutes and use substantial storage on web.'**
  String offlinePackEstimate(int tileCount, int archiveCount);

  /// No description provided for @offlinePackExistingSummary.
  ///
  /// In en, this message translates to:
  /// **'Current pack “{name}”: {tileCount} tiles, {markerCount} markers.'**
  String offlinePackExistingSummary(
    String name,
    int tileCount,
    int markerCount,
  );

  /// No description provided for @offlinePackPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing offline pack…'**
  String get offlinePackPreparing;

  /// No description provided for @offlinePackClear.
  ///
  /// In en, this message translates to:
  /// **'Clear pack'**
  String get offlinePackClear;

  /// No description provided for @offlinePackSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} offline change(s) to the server.'**
  String offlinePackSynced(int count);

  /// No description provided for @offlineModeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline — {packName}'**
  String offlineModeBannerTitle(String packName);

  /// No description provided for @offlineModeBannerReadWriteHint.
  ///
  /// In en, this message translates to:
  /// **'Showing packed layers. You can add markers, change marker layers, delete unsynced markers, record GPS tracks, and add watch-log entries.'**
  String get offlineModeBannerReadWriteHint;

  /// No description provided for @offlineModeBannerForcedHint.
  ///
  /// In en, this message translates to:
  /// **'Forced offline pack (server still reachable). Turn off in Settings → General → Map debugging when finished testing.'**
  String get offlineModeBannerForcedHint;

  /// No description provided for @offlineDeleteUnsyncedMarker.
  ///
  /// In en, this message translates to:
  /// **'Delete unsynced marker'**
  String get offlineDeleteUnsyncedMarker;

  /// No description provided for @offlineDeleteSyncedMarkerDisabled.
  ///
  /// In en, this message translates to:
  /// **'Only unsynced offline markers can be deleted until the server returns'**
  String get offlineDeleteSyncedMarkerDisabled;

  /// No description provided for @offlineGeocodingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Geocoding contributions are unavailable while offline.'**
  String get offlineGeocodingUnavailable;

  /// No description provided for @offlineModeBannerPending.
  ///
  /// In en, this message translates to:
  /// **'{count} change(s) waiting to sync.'**
  String offlineModeBannerPending(int count);

  /// No description provided for @mapTilesGetMapsTitle.
  ///
  /// In en, this message translates to:
  /// **'Get maps'**
  String get mapTilesGetMapsTitle;

  /// No description provided for @mapTilesGetMapsDescription.
  ///
  /// In en, this message translates to:
  /// **'Download regional Protomaps basemaps from Project NOMAD, or a Terrarium DEM from Mapterhorn. The Wayfinder server fetches or extracts the file into its storage — keep this dialog open until the import finishes.'**
  String get mapTilesGetMapsDescription;

  /// No description provided for @mapTilesGetMapsBasemapDescription.
  ///
  /// In en, this message translates to:
  /// **'US state vector basemaps from Project NOMAD (typically a few hundred MB each). Search for your state, then Import — the server downloads it into Map tiles storage.'**
  String get mapTilesGetMapsBasemapDescription;

  /// No description provided for @mapTilesGetMapsDemDescription.
  ///
  /// In en, this message translates to:
  /// **'US-state Terrarium elevation packs (Mapterhorn). Import runs a regional extract on the Wayfinder server — keep this dialog open; large states can take several minutes. Prefer a state over the full-planet option at the bottom of the list.'**
  String get mapTilesGetMapsDemDescription;

  /// No description provided for @mapTilesGetMapsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search states…'**
  String get mapTilesGetMapsSearchHint;

  /// No description provided for @mapTilesGetMapsImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get mapTilesGetMapsImportAction;

  /// No description provided for @mapTilesGetMapsExtractAction.
  ///
  /// In en, this message translates to:
  /// **'Extract'**
  String get mapTilesGetMapsExtractAction;

  /// No description provided for @mapTilesGetMapsImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing {title}…'**
  String mapTilesGetMapsImporting(String title);

  /// No description provided for @mapTilesGetMapsExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting {title} on the server…'**
  String mapTilesGetMapsExtracting(String title);

  /// No description provided for @mapTilesGetMapsImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {title}.'**
  String mapTilesGetMapsImported(String title);

  /// No description provided for @mapTilesGetMapsCatalogFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load map catalog: {error}'**
  String mapTilesGetMapsCatalogFailed(String error);

  /// No description provided for @mapTilesGetMapsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No packs match your search.'**
  String get mapTilesGetMapsEmpty;

  /// No description provided for @mapTilesGetMapsSizeUnknown.
  ///
  /// In en, this message translates to:
  /// **'size unknown'**
  String get mapTilesGetMapsSizeUnknown;

  /// No description provided for @mapTilesGetMapsSizeRegional.
  ///
  /// In en, this message translates to:
  /// **'regional extract'**
  String get mapTilesGetMapsSizeRegional;

  /// No description provided for @mapTilesGetMapsBasemapBadge.
  ///
  /// In en, this message translates to:
  /// **'Basemap'**
  String get mapTilesGetMapsBasemapBadge;

  /// No description provided for @mapTilesUploadProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {sent} / {total}'**
  String mapTilesUploadProgress(String sent, String total);

  /// No description provided for @mapTilesUploadProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Large archives upload in chunks so server logs show progress. Keep this tab open until finished.'**
  String get mapTilesUploadProgressHint;

  /// No description provided for @elevationDemLabel.
  ///
  /// In en, this message translates to:
  /// **'DEM elevation'**
  String get elevationDemLabel;

  /// No description provided for @elevationDemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No DEM coverage at this point'**
  String get elevationDemUnavailable;

  /// No description provided for @elevationNoDemAvailable.
  ///
  /// In en, this message translates to:
  /// **'No elevation DEM is enabled. Upload a Terrarium or Terrain-RGB .pmtiles file named with dem/terrarium/elevation and enable it under Map tiles.'**
  String get elevationNoDemAvailable;

  /// No description provided for @elevationProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Elevation profile'**
  String get elevationProfileTitle;

  /// No description provided for @elevationProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Elevation profile'**
  String get elevationProfileButton;

  /// No description provided for @routeFollowButton.
  ///
  /// In en, this message translates to:
  /// **'Follow route'**
  String get routeFollowButton;

  /// No description provided for @routeFollowPrimaryButton.
  ///
  /// In en, this message translates to:
  /// **'Follow primary route'**
  String get routeFollowPrimaryButton;

  /// No description provided for @routeFollowStop.
  ///
  /// In en, this message translates to:
  /// **'Stop following'**
  String get routeFollowStop;

  /// No description provided for @routeFollowSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate walk along route'**
  String get routeFollowSimulate;

  /// No description provided for @routeFollowStopSimulate.
  ///
  /// In en, this message translates to:
  /// **'Stop simulated walk'**
  String get routeFollowStopSimulate;

  /// No description provided for @routeFollowStarted.
  ///
  /// In en, this message translates to:
  /// **'Following “{name}”. Stay near the path.'**
  String routeFollowStarted(String name);

  /// No description provided for @routeFollowGpsRequired.
  ///
  /// In en, this message translates to:
  /// **'Could not start GPS. Enable location and try again.'**
  String get routeFollowGpsRequired;

  /// No description provided for @routeFollowActive.
  ///
  /// In en, this message translates to:
  /// **'Following {name}'**
  String routeFollowActive(String name);

  /// No description provided for @routeFollowOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Off route · {distance}'**
  String routeFollowOffRoute(String distance);

  /// No description provided for @routeFollowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Route complete'**
  String get routeFollowCompleted;

  /// No description provided for @routeFollowRemaining.
  ///
  /// In en, this message translates to:
  /// **'{distance} left'**
  String routeFollowRemaining(String distance);

  /// No description provided for @routeFollowEta.
  ///
  /// In en, this message translates to:
  /// **'ETA {eta}'**
  String routeFollowEta(String eta);

  /// No description provided for @routeFollowTurnLeftIn.
  ///
  /// In en, this message translates to:
  /// **'In {distance}, turn left'**
  String routeFollowTurnLeftIn(String distance);

  /// No description provided for @routeFollowTurnRightIn.
  ///
  /// In en, this message translates to:
  /// **'In {distance}, turn right'**
  String routeFollowTurnRightIn(String distance);

  /// No description provided for @routeFollowTurnPortIn.
  ///
  /// In en, this message translates to:
  /// **'In {distance}, turn {degrees}° to port'**
  String routeFollowTurnPortIn(String distance, int degrees);

  /// No description provided for @routeFollowTurnStarboardIn.
  ///
  /// In en, this message translates to:
  /// **'In {distance}, turn {degrees}° to starboard'**
  String routeFollowTurnStarboardIn(String distance, int degrees);

  /// No description provided for @routeFollowNauticalModeEnable.
  ///
  /// In en, this message translates to:
  /// **'Nautical cues (port / starboard)'**
  String get routeFollowNauticalModeEnable;

  /// No description provided for @routeFollowNauticalModeDisable.
  ///
  /// In en, this message translates to:
  /// **'Standard cues (left / right)'**
  String get routeFollowNauticalModeDisable;

  /// No description provided for @routeFollowContinueFor.
  ///
  /// In en, this message translates to:
  /// **'Continue {distance}'**
  String routeFollowContinueFor(String distance);

  /// No description provided for @routeFollowArriveIn.
  ///
  /// In en, this message translates to:
  /// **'Arrive in {distance}'**
  String routeFollowArriveIn(String distance);

  /// No description provided for @elevationProfileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Could not sample elevations along this path.'**
  String get elevationProfileEmpty;

  /// No description provided for @elevationProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build elevation profile: {error}'**
  String elevationProfileFailed(String error);

  /// No description provided for @elevationProfileFlatHint.
  ///
  /// In en, this message translates to:
  /// **'Little elevation change along this path — the chart may look nearly flat.'**
  String get elevationProfileFlatHint;

  /// No description provided for @elevationProfileCombinedLegs.
  ///
  /// In en, this message translates to:
  /// **'Combined from {count} legs (check order; each leg may reverse to connect).'**
  String elevationProfileCombinedLegs(int count);

  /// No description provided for @elevationProfileSelectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} paths selected for elevation profile'**
  String elevationProfileSelectionCount(int count);

  /// No description provided for @elevationProfileClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get elevationProfileClearSelection;

  /// No description provided for @elevationProfileMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get elevationProfileMin;

  /// No description provided for @elevationProfileMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get elevationProfileMax;

  /// No description provided for @elevationProfileGain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get elevationProfileGain;

  /// No description provided for @elevationProfileLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get elevationProfileLoss;

  /// No description provided for @elevationClimbToMarker.
  ///
  /// In en, this message translates to:
  /// **'Climb to {name}: {delta}'**
  String elevationClimbToMarker(String name, String delta);

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

  /// No description provided for @mapTilesDownloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download archive'**
  String get mapTilesDownloadTooltip;

  /// No description provided for @mapTilesDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Downloading \"{name}\"…'**
  String mapTilesDownloadStarted(String name);

  /// No description provided for @mapTilesDownloadSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\".'**
  String mapTilesDownloadSaved(String name);

  /// No description provided for @mapTilesDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String mapTilesDownloadFailed(String error);

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

  /// No description provided for @markerIconsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage marker icon categories or custom marker icons.'**
  String get markerIconsPermissionDenied;

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

  /// No description provided for @markerRadioTitle.
  ///
  /// In en, this message translates to:
  /// **'Radio net / contact card'**
  String get markerRadioTitle;

  /// No description provided for @markerRadioEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional callsign, frequency, and mode for ham shack / repeater planning (not live radio).'**
  String get markerRadioEmptyHelp;

  /// No description provided for @markerRadioStructuredHint.
  ///
  /// In en, this message translates to:
  /// **'Structured contact data only — Wayfinder does not transmit or tune radios.'**
  String get markerRadioStructuredHint;

  /// No description provided for @markerRadioSummary.
  ///
  /// In en, this message translates to:
  /// **'{callsign}'**
  String markerRadioSummary(String callsign);

  /// No description provided for @markerRadioNoCallsign.
  ///
  /// In en, this message translates to:
  /// **'Contact card'**
  String get markerRadioNoCallsign;

  /// No description provided for @markerRadioCallsignLabel.
  ///
  /// In en, this message translates to:
  /// **'Callsign'**
  String get markerRadioCallsignLabel;

  /// No description provided for @markerRadioRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get markerRadioRoleLabel;

  /// No description provided for @markerRadioRoleShack.
  ///
  /// In en, this message translates to:
  /// **'Ham shack'**
  String get markerRadioRoleShack;

  /// No description provided for @markerRadioRoleRepeater.
  ///
  /// In en, this message translates to:
  /// **'Repeater'**
  String get markerRadioRoleRepeater;

  /// No description provided for @markerRadioRoleStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get markerRadioRoleStation;

  /// No description provided for @markerRadioRoleNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get markerRadioRoleNet;

  /// No description provided for @markerRadioRoleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get markerRadioRoleOther;

  /// No description provided for @markerRadioNetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Net / group'**
  String get markerRadioNetNameLabel;

  /// No description provided for @markerRadioNetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. County ARES'**
  String get markerRadioNetNameHint;

  /// No description provided for @markerRadioFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get markerRadioFrequencyLabel;

  /// No description provided for @markerRadioModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get markerRadioModeLabel;

  /// No description provided for @markerRadioModeFm.
  ///
  /// In en, this message translates to:
  /// **'FM'**
  String get markerRadioModeFm;

  /// No description provided for @markerRadioModeAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get markerRadioModeAm;

  /// No description provided for @markerRadioModeSsb.
  ///
  /// In en, this message translates to:
  /// **'SSB'**
  String get markerRadioModeSsb;

  /// No description provided for @markerRadioModeCw.
  ///
  /// In en, this message translates to:
  /// **'CW'**
  String get markerRadioModeCw;

  /// No description provided for @markerRadioModeDigi.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get markerRadioModeDigi;

  /// No description provided for @markerRadioModeDmr.
  ///
  /// In en, this message translates to:
  /// **'DMR'**
  String get markerRadioModeDmr;

  /// No description provided for @markerRadioModeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get markerRadioModeOther;

  /// No description provided for @markerRadioToneLabel.
  ///
  /// In en, this message translates to:
  /// **'Tone / CTCSS'**
  String get markerRadioToneLabel;

  /// No description provided for @markerRadioOffsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get markerRadioOffsetLabel;

  /// No description provided for @markerRadioNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Radio notes'**
  String get markerRadioNotesLabel;

  /// No description provided for @markerRadioNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Net time, coverage, PL tip — short planning notes'**
  String get markerRadioNotesHint;

  /// No description provided for @markerRadioClear.
  ///
  /// In en, this message translates to:
  /// **'Clear contact card'**
  String get markerRadioClear;

  /// No description provided for @sidebarFilterRadioContacts.
  ///
  /// In en, this message translates to:
  /// **'Radio contacts'**
  String get sidebarFilterRadioContacts;

  /// No description provided for @markerInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cache inventory'**
  String get markerInventoryTitle;

  /// No description provided for @markerInventoryEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Track supplies at this marker — quantity, unit, expiry, and last audit.'**
  String get markerInventoryEmptyHelp;

  /// No description provided for @markerInventoryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String markerInventoryItemCount(int count);

  /// No description provided for @markerInventoryAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get markerInventoryAddItem;

  /// No description provided for @markerInventoryRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get markerInventoryRemoveItem;

  /// No description provided for @markerInventoryItemHeading.
  ///
  /// In en, this message translates to:
  /// **'Inventory item'**
  String get markerInventoryItemHeading;

  /// No description provided for @markerInventoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get markerInventoryNameLabel;

  /// No description provided for @markerInventoryQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get markerInventoryQuantityLabel;

  /// No description provided for @markerInventoryUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get markerInventoryUnitLabel;

  /// No description provided for @markerInventoryCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get markerInventoryCategoryLabel;

  /// No description provided for @markerInventoryCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get markerInventoryCategoryFood;

  /// No description provided for @markerInventoryCategoryWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get markerInventoryCategoryWater;

  /// No description provided for @markerInventoryCategoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get markerInventoryCategoryMedical;

  /// No description provided for @markerInventoryCategoryAmmo.
  ///
  /// In en, this message translates to:
  /// **'Ammo'**
  String get markerInventoryCategoryAmmo;

  /// No description provided for @markerInventoryCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get markerInventoryCategoryOther;

  /// No description provided for @markerInventoryExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get markerInventoryExpiryLabel;

  /// No description provided for @markerInventorySetExpiry.
  ///
  /// In en, this message translates to:
  /// **'Set expiry'**
  String get markerInventorySetExpiry;

  /// No description provided for @markerInventoryExpiryValue.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String markerInventoryExpiryValue(String date);

  /// No description provided for @markerInventoryClearExpiry.
  ///
  /// In en, this message translates to:
  /// **'Clear expiry'**
  String get markerInventoryClearExpiry;

  /// No description provided for @markerInventoryLastAuditedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last audited'**
  String get markerInventoryLastAuditedLabel;

  /// No description provided for @markerInventorySetLastAudited.
  ///
  /// In en, this message translates to:
  /// **'Set last audited'**
  String get markerInventorySetLastAudited;

  /// No description provided for @markerInventoryLastAuditedValue.
  ///
  /// In en, this message translates to:
  /// **'Audited {date}'**
  String markerInventoryLastAuditedValue(String date);

  /// No description provided for @markerInventoryMarkAuditedNow.
  ///
  /// In en, this message translates to:
  /// **'Mark audited now'**
  String get markerInventoryMarkAuditedNow;

  /// No description provided for @markerInventoryDetailQuantity.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit}'**
  String markerInventoryDetailQuantity(String quantity, String unit);

  /// No description provided for @markerInventoryDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String markerInventoryDetailCategory(String category);

  /// No description provided for @markerInventoryDetailNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get markerInventoryDetailNoExpiry;

  /// No description provided for @markerInventoryDetailExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String markerInventoryDetailExpiry(String date);

  /// No description provided for @markerInventoryDetailNeverAudited.
  ///
  /// In en, this message translates to:
  /// **'Never audited'**
  String get markerInventoryDetailNeverAudited;

  /// No description provided for @markerInventoryDetailLastAudited.
  ///
  /// In en, this message translates to:
  /// **'Last audited {date}'**
  String markerInventoryDetailLastAudited(String date);

  /// No description provided for @markerChecklistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Checklists / SOPs'**
  String get markerChecklistsTitle;

  /// No description provided for @markerChecklistsEmptyHelp.
  ///
  /// In en, this message translates to:
  /// **'Location SOPs and audits — e.g. bug-out bag check at a retreat.'**
  String get markerChecklistsEmptyHelp;

  /// No description provided for @markerChecklistsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 checklist} other{{count} checklists}}'**
  String markerChecklistsCount(int count);

  /// No description provided for @markerChecklistsAddChecklist.
  ///
  /// In en, this message translates to:
  /// **'Add checklist'**
  String get markerChecklistsAddChecklist;

  /// No description provided for @markerChecklistsRemoveChecklist.
  ///
  /// In en, this message translates to:
  /// **'Remove checklist'**
  String get markerChecklistsRemoveChecklist;

  /// No description provided for @markerChecklistsChecklistHeading.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get markerChecklistsChecklistHeading;

  /// No description provided for @markerChecklistsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Checklist name'**
  String get markerChecklistsNameLabel;

  /// No description provided for @markerChecklistsNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get markerChecklistsNotesLabel;

  /// No description provided for @markerChecklistsLastAuditedNever.
  ///
  /// In en, this message translates to:
  /// **'Never audited'**
  String get markerChecklistsLastAuditedNever;

  /// No description provided for @markerChecklistsLastAudited.
  ///
  /// In en, this message translates to:
  /// **'Last audited {date}'**
  String markerChecklistsLastAudited(String date);

  /// No description provided for @markerChecklistsMarkAudited.
  ///
  /// In en, this message translates to:
  /// **'Mark audited now'**
  String get markerChecklistsMarkAudited;

  /// No description provided for @markerChecklistsAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get markerChecklistsAddItem;

  /// No description provided for @markerChecklistsRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get markerChecklistsRemoveItem;

  /// No description provided for @markerChecklistsItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get markerChecklistsItemLabel;

  /// No description provided for @markerChecklistsItemNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Item notes'**
  String get markerChecklistsItemNotesLabel;

  /// No description provided for @markerChecklistsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String markerChecklistsProgress(int done, int total);

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

  /// No description provided for @markerTrackingStatusRecordingGps.
  ///
  /// In en, this message translates to:
  /// **'Recording GPS'**
  String get markerTrackingStatusRecordingGps;

  /// No description provided for @markerTrackingStartGpsTrail.
  ///
  /// In en, this message translates to:
  /// **'Record trail with GPS'**
  String get markerTrackingStartGpsTrail;

  /// No description provided for @markerTrackingStopGpsTrail.
  ///
  /// In en, this message translates to:
  /// **'Stop GPS trail'**
  String get markerTrackingStopGpsTrail;

  /// No description provided for @markerTrackingGpsTrailHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional: bind this device’s GPS to this marker only. Works online or in an offline pack. Other tracking markers (APRS, REST, etc.) are unaffected.'**
  String get markerTrackingGpsTrailHelp;

  /// No description provided for @markerTrackingGpsTrailOffer.
  ///
  /// In en, this message translates to:
  /// **'Record this device’s GPS into that tracking marker’s trail? Works offline in a pack.'**
  String get markerTrackingGpsTrailOffer;

  /// No description provided for @trackCreateEvacKitButton.
  ///
  /// In en, this message translates to:
  /// **'Create evac kit from trail'**
  String get trackCreateEvacKitButton;

  /// No description provided for @mapDeviceLocationRecordingTrail.
  ///
  /// In en, this message translates to:
  /// **'Recording trail: {name}'**
  String mapDeviceLocationRecordingTrail(String name);

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

  /// No description provided for @mapAtlasTooltip.
  ///
  /// In en, this message translates to:
  /// **'Printable map atlas'**
  String get mapAtlasTooltip;

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

  /// No description provided for @mapObjectTypeRangeRing.
  ///
  /// In en, this message translates to:
  /// **'Range ring'**
  String get mapObjectTypeRangeRing;

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
  /// **'Stored altitude'**
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

  /// No description provided for @sidebarFilterFoodExpiring90Days.
  ///
  /// In en, this message translates to:
  /// **'Food expiring in 90 days'**
  String get sidebarFilterFoodExpiring90Days;

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

  /// No description provided for @mapTilesCatalogLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading map tile catalog…'**
  String get mapTilesCatalogLoading;

  /// No description provided for @mapTilesPreparingFile.
  ///
  /// In en, this message translates to:
  /// **'Preparing {name}'**
  String mapTilesPreparingFile(String name);

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

  /// No description provided for @mapTilesOpeningElapsed.
  ///
  /// In en, this message translates to:
  /// **'Opening {name}… {seconds}s'**
  String mapTilesOpeningElapsed(String name, int seconds);

  /// No description provided for @mapTilesOpeningFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Fetching header from {url}'**
  String mapTilesOpeningFromUrl(String url);

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

  /// No description provided for @geocodingPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to configure the geocoding server or manage custom locations.'**
  String get geocodingPermissionDenied;

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

  /// No description provided for @mapRadialPolygon.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get mapRadialPolygon;

  /// No description provided for @mapRadialMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get mapRadialMore;

  /// No description provided for @mapRadialBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get mapRadialBack;

  /// No description provided for @mapRadialCopyCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Copy coordinates'**
  String get mapRadialCopyCoordinates;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @polygonEditingHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a vertex to move · double-click an edge to add · double-click a vertex to remove (keep 3+) · Done when finished'**
  String get polygonEditingHint;

  /// No description provided for @mapRadialDeadReckoning.
  ///
  /// In en, this message translates to:
  /// **'Pace count'**
  String get mapRadialDeadReckoning;

  /// No description provided for @mapRadialViewshed.
  ///
  /// In en, this message translates to:
  /// **'Viewshed'**
  String get mapRadialViewshed;

  /// No description provided for @mapRadialSlope.
  ///
  /// In en, this message translates to:
  /// **'Slope / cost'**
  String get mapRadialSlope;

  /// No description provided for @mapRadialRangeRing.
  ///
  /// In en, this message translates to:
  /// **'Range ring'**
  String get mapRadialRangeRing;

  /// No description provided for @mapRadialCoveragePlan.
  ///
  /// In en, this message translates to:
  /// **'Coverage plan'**
  String get mapRadialCoveragePlan;

  /// No description provided for @mapRadialSunMoon.
  ///
  /// In en, this message translates to:
  /// **'Sun / moon'**
  String get mapRadialSunMoon;

  /// No description provided for @mapRadialTides.
  ///
  /// In en, this message translates to:
  /// **'Tides'**
  String get mapRadialTides;

  /// No description provided for @mapRadialSeasonalOverlay.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get mapRadialSeasonalOverlay;

  /// No description provided for @mapRadialEvacKit.
  ///
  /// In en, this message translates to:
  /// **'Evac kit'**
  String get mapRadialEvacKit;

  /// No description provided for @tidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tide tables'**
  String get tidesTitle;

  /// No description provided for @tidesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nearest coastal station from packs on your Wayfinder server — for boat and water crossings.'**
  String get tidesSubtitle;

  /// No description provided for @tidesLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get tidesLocationLabel;

  /// No description provided for @tidesAnchorMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get tidesAnchorMarker;

  /// No description provided for @tidesAnchorHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tidesAnchorHome;

  /// No description provided for @tidesAnchorMapPoint.
  ///
  /// In en, this message translates to:
  /// **'Map point'**
  String get tidesAnchorMapPoint;

  /// No description provided for @tidesDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tidesDateLabel;

  /// No description provided for @tidesPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get tidesPickDate;

  /// No description provided for @tidesMissingLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location to query tides.'**
  String get tidesMissingLocation;

  /// No description provided for @tidesQueryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load tides: {error}'**
  String tidesQueryFailed(String error);

  /// No description provided for @tidesApproximateBanner.
  ///
  /// In en, this message translates to:
  /// **'Heights are harmonic planning estimates from the installed coastal pack (not live NOAA observations).'**
  String get tidesApproximateBanner;

  /// No description provided for @tidesStationHeading.
  ///
  /// In en, this message translates to:
  /// **'{name} ({id})'**
  String tidesStationHeading(String name, String id);

  /// No description provided for @tidesStationMeta.
  ///
  /// In en, this message translates to:
  /// **'{distance} away · datum {datum}'**
  String tidesStationMeta(String distance, String datum);

  /// No description provided for @tidesExtremesSection.
  ///
  /// In en, this message translates to:
  /// **'Highs and lows'**
  String get tidesExtremesSection;

  /// No description provided for @tidesCurveSection.
  ///
  /// In en, this message translates to:
  /// **'Tide curve'**
  String get tidesCurveSection;

  /// No description provided for @tidesNoExtremes.
  ///
  /// In en, this message translates to:
  /// **'No high/low extremes found for this day.'**
  String get tidesNoExtremes;

  /// No description provided for @tidesCrossingHint.
  ///
  /// In en, this message translates to:
  /// **'Use low-tide windows for fords and high-tide windows for deeper boat passages. Confirm locally before committing.'**
  String get tidesCrossingHint;

  /// No description provided for @tidesExtremeHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tidesExtremeHigh;

  /// No description provided for @tidesExtremeLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tidesExtremeLow;

  /// No description provided for @tidesHeightMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String tidesHeightMeters(String value);

  /// No description provided for @tidesHeightFeet.
  ///
  /// In en, this message translates to:
  /// **'{value} ft'**
  String tidesHeightFeet(String value);

  /// No description provided for @tidesDistanceUnknown.
  ///
  /// In en, this message translates to:
  /// **'distance unknown'**
  String get tidesDistanceUnknown;

  /// No description provided for @tidesDistanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String tidesDistanceMeters(String value);

  /// No description provided for @tidesDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String tidesDistanceKm(String value);

  /// No description provided for @tidesDistanceFeet.
  ///
  /// In en, this message translates to:
  /// **'{value} ft'**
  String tidesDistanceFeet(String value);

  /// No description provided for @tidesDistanceMiles.
  ///
  /// In en, this message translates to:
  /// **'{value} mi'**
  String tidesDistanceMiles(String value);

  /// No description provided for @tidesSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Coastal tide packs'**
  String get tidesSettingsTitle;

  /// No description provided for @tidesSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download NOAA harmonic packs to this Wayfinder server. The map Tide tool queries those packs offline (server must reach NOAA once to import). Save packs as .wayfinder-tide files to restore later without internet.'**
  String get tidesSettingsSubtitle;

  /// No description provided for @tidesPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to download, upload, or remove coastal tide packs.'**
  String get tidesPermissionDenied;

  /// No description provided for @tidesInstalledPacks.
  ///
  /// In en, this message translates to:
  /// **'Installed packs'**
  String get tidesInstalledPacks;

  /// No description provided for @tidesTransferHint.
  ///
  /// In en, this message translates to:
  /// **'Download a pack to your device for offline restore, or upload a .wayfinder-tide file. Tide packs are not part of the map backup zip.'**
  String get tidesTransferHint;

  /// No description provided for @tidesUploadPack.
  ///
  /// In en, this message translates to:
  /// **'Upload pack'**
  String get tidesUploadPack;

  /// No description provided for @tidesExportPack.
  ///
  /// In en, this message translates to:
  /// **'Save pack file'**
  String get tidesExportPack;

  /// No description provided for @tidesExportPackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved tide pack “{name}”.'**
  String tidesExportPackSuccess(String name);

  /// No description provided for @tidesExportPackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save tide pack: {error}'**
  String tidesExportPackFailed(String error);

  /// No description provided for @tidesUploadPackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored “{name}” with {stations} stations.'**
  String tidesUploadPackSuccess(String name, int stations);

  /// No description provided for @tidesUploadPackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload tide pack: {error}'**
  String tidesUploadPackFailed(String error);

  /// No description provided for @tidesNoPacksInstalled.
  ///
  /// In en, this message translates to:
  /// **'No coastal packs installed yet. Download a region below or upload a .wayfinder-tide file.'**
  String get tidesNoPacksInstalled;

  /// No description provided for @tidesPackMeta.
  ///
  /// In en, this message translates to:
  /// **'{stations} stations · {size} · {date}'**
  String tidesPackMeta(int stations, String size, String date);

  /// No description provided for @tidesGetCoastalPacks.
  ///
  /// In en, this message translates to:
  /// **'Get coastal packs'**
  String get tidesGetCoastalPacks;

  /// No description provided for @tidesGetCoastalPacksHint.
  ///
  /// In en, this message translates to:
  /// **'Imports up to ~80 NOAA tide-prediction stations in the region. May take several minutes.'**
  String get tidesGetCoastalPacksHint;

  /// No description provided for @tidesDownloadPack.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get tidesDownloadPack;

  /// No description provided for @tidesImportInProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading coastal pack from NOAA…'**
  String get tidesImportInProgress;

  /// No description provided for @tidesImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Installed “{name}” with {stations} stations.'**
  String tidesImportSuccess(String name, int stations);

  /// No description provided for @tidesImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String tidesImportFailed(String error);

  /// No description provided for @tidesActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Tide action failed: {error}'**
  String tidesActionFailed(String error);

  /// No description provided for @tidesDeletePack.
  ///
  /// In en, this message translates to:
  /// **'Delete pack'**
  String get tidesDeletePack;

  /// No description provided for @tidesDeletePackConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete coastal pack “{name}” from the server?'**
  String tidesDeletePackConfirm(String name);

  /// No description provided for @tidesRegionBbox.
  ///
  /// In en, this message translates to:
  /// **'{minLat}°, {minLng}° → {maxLat}°, {maxLng}°'**
  String tidesRegionBbox(
    String minLat,
    String minLng,
    String maxLat,
    String maxLng,
  );

  /// No description provided for @tidesOpenFromEvac.
  ///
  /// In en, this message translates to:
  /// **'Tide tables at route'**
  String get tidesOpenFromEvac;

  /// No description provided for @sunMoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Sun / moon / twilight'**
  String get sunMoonTitle;

  /// No description provided for @sunMoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline sunrise, sunset, twilight, moon phase, and night-ops windows for a place and date.'**
  String get sunMoonSubtitle;

  /// No description provided for @sunMoonLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sunMoonLocationLabel;

  /// No description provided for @sunMoonAnchorMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get sunMoonAnchorMarker;

  /// No description provided for @sunMoonAnchorHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get sunMoonAnchorHome;

  /// No description provided for @sunMoonAnchorMapPoint.
  ///
  /// In en, this message translates to:
  /// **'Map point'**
  String get sunMoonAnchorMapPoint;

  /// No description provided for @sunMoonDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sunMoonDateLabel;

  /// No description provided for @sunMoonPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get sunMoonPickDate;

  /// No description provided for @sunMoonTimezoneSection.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get sunMoonTimezoneSection;

  /// No description provided for @sunMoonTimezoneHint.
  ///
  /// In en, this message translates to:
  /// **'Convert event times with standard or daylight offsets. Auto follows IANA DST rules for the selected date.'**
  String get sunMoonTimezoneHint;

  /// No description provided for @sunMoonTimeBaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Display times as'**
  String get sunMoonTimeBaseLabel;

  /// No description provided for @sunMoonTimeBaseZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get sunMoonTimeBaseZone;

  /// No description provided for @sunMoonTimeBaseDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get sunMoonTimeBaseDevice;

  /// No description provided for @sunMoonTimeBaseUtc.
  ///
  /// In en, this message translates to:
  /// **'UTC'**
  String get sunMoonTimeBaseUtc;

  /// No description provided for @sunMoonZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get sunMoonZoneLabel;

  /// No description provided for @sunMoonZoneLongitude.
  ///
  /// In en, this message translates to:
  /// **'From longitude ({iana})'**
  String sunMoonZoneLongitude(String iana);

  /// No description provided for @sunMoonDstLabel.
  ///
  /// In en, this message translates to:
  /// **'DST adjustment'**
  String get sunMoonDstLabel;

  /// No description provided for @sunMoonDstAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get sunMoonDstAuto;

  /// No description provided for @sunMoonDstStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get sunMoonDstStandard;

  /// No description provided for @sunMoonDstDaylight.
  ///
  /// In en, this message translates to:
  /// **'Daylight'**
  String get sunMoonDstDaylight;

  /// No description provided for @sunMoonDstAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Use the zone’s DST rules for each event'**
  String get sunMoonDstAutoHint;

  /// No description provided for @sunMoonDstStandardHint.
  ///
  /// In en, this message translates to:
  /// **'Force the standard (non-DST) offset'**
  String get sunMoonDstStandardHint;

  /// No description provided for @sunMoonDstDaylightHint.
  ///
  /// In en, this message translates to:
  /// **'Force the daylight (DST) offset'**
  String get sunMoonDstDaylightHint;

  /// No description provided for @sunMoonDstNoDstHint.
  ///
  /// In en, this message translates to:
  /// **'This zone has no IANA DST rules. Daylight applies a +1 hour planning offset to the standard time.'**
  String get sunMoonDstNoDstHint;

  /// No description provided for @sunMoonTzSummaryUtc.
  ///
  /// In en, this message translates to:
  /// **'Showing UTC'**
  String get sunMoonTzSummaryUtc;

  /// No description provided for @sunMoonTzSummaryDevice.
  ///
  /// In en, this message translates to:
  /// **'Device · {name} · {offset}'**
  String sunMoonTzSummaryDevice(String name, String offset);

  /// No description provided for @sunMoonTzSummaryZone.
  ///
  /// In en, this message translates to:
  /// **'{iana} · {abbr} · {offset} · {dst}'**
  String sunMoonTzSummaryZone(
    String iana,
    String abbr,
    String offset,
    String dst,
  );

  /// No description provided for @sunMoonTimeUtc.
  ///
  /// In en, this message translates to:
  /// **'{time} UTC'**
  String sunMoonTimeUtc(String time);

  /// No description provided for @sunMoonMissingLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location to compute.'**
  String get sunMoonMissingLocation;

  /// No description provided for @sunMoonNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get sunMoonNotApplicable;

  /// No description provided for @sunMoonPolarDay.
  ///
  /// In en, this message translates to:
  /// **'Polar day — the sun does not set on this date.'**
  String get sunMoonPolarDay;

  /// No description provided for @sunMoonPolarNight.
  ///
  /// In en, this message translates to:
  /// **'Polar night — the sun does not rise on this date.'**
  String get sunMoonPolarNight;

  /// No description provided for @sunMoonSunSection.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunMoonSunSection;

  /// No description provided for @sunMoonSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunMoonSunrise;

  /// No description provided for @sunMoonSolarNoon.
  ///
  /// In en, this message translates to:
  /// **'Solar noon'**
  String get sunMoonSolarNoon;

  /// No description provided for @sunMoonSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunMoonSunset;

  /// No description provided for @sunMoonTwilightSection.
  ///
  /// In en, this message translates to:
  /// **'Twilight'**
  String get sunMoonTwilightSection;

  /// No description provided for @sunMoonCivilDawn.
  ///
  /// In en, this message translates to:
  /// **'Civil dawn'**
  String get sunMoonCivilDawn;

  /// No description provided for @sunMoonCivilDusk.
  ///
  /// In en, this message translates to:
  /// **'Civil dusk'**
  String get sunMoonCivilDusk;

  /// No description provided for @sunMoonNauticalDawn.
  ///
  /// In en, this message translates to:
  /// **'Nautical dawn'**
  String get sunMoonNauticalDawn;

  /// No description provided for @sunMoonNauticalDusk.
  ///
  /// In en, this message translates to:
  /// **'Nautical dusk'**
  String get sunMoonNauticalDusk;

  /// No description provided for @sunMoonAstronomicalDawn.
  ///
  /// In en, this message translates to:
  /// **'Astronomical dawn'**
  String get sunMoonAstronomicalDawn;

  /// No description provided for @sunMoonAstronomicalDusk.
  ///
  /// In en, this message translates to:
  /// **'Astronomical dusk'**
  String get sunMoonAstronomicalDusk;

  /// No description provided for @sunMoonNightOpsSection.
  ///
  /// In en, this message translates to:
  /// **'Night ops'**
  String get sunMoonNightOpsSection;

  /// No description provided for @sunMoonNightOpsHint.
  ///
  /// In en, this message translates to:
  /// **'Nautical dusk to the next nautical dawn (sun 12° or more below the horizon).'**
  String get sunMoonNightOpsHint;

  /// No description provided for @sunMoonNightOpsStart.
  ///
  /// In en, this message translates to:
  /// **'Dark start'**
  String get sunMoonNightOpsStart;

  /// No description provided for @sunMoonNightOpsEnd.
  ///
  /// In en, this message translates to:
  /// **'Dark end'**
  String get sunMoonNightOpsEnd;

  /// No description provided for @sunMoonMoonSection.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get sunMoonMoonSection;

  /// No description provided for @sunMoonPhaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get sunMoonPhaseLabel;

  /// No description provided for @sunMoonPhaseNew.
  ///
  /// In en, this message translates to:
  /// **'New moon'**
  String get sunMoonPhaseNew;

  /// No description provided for @sunMoonPhaseWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing crescent'**
  String get sunMoonPhaseWaxingCrescent;

  /// No description provided for @sunMoonPhaseFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First quarter'**
  String get sunMoonPhaseFirstQuarter;

  /// No description provided for @sunMoonPhaseWaxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waxing gibbous'**
  String get sunMoonPhaseWaxingGibbous;

  /// No description provided for @sunMoonPhaseFull.
  ///
  /// In en, this message translates to:
  /// **'Full moon'**
  String get sunMoonPhaseFull;

  /// No description provided for @sunMoonPhaseWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning gibbous'**
  String get sunMoonPhaseWaningGibbous;

  /// No description provided for @sunMoonPhaseLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Last quarter'**
  String get sunMoonPhaseLastQuarter;

  /// No description provided for @sunMoonPhaseWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning crescent'**
  String get sunMoonPhaseWaningCrescent;

  /// No description provided for @sunMoonIlluminationLabel.
  ///
  /// In en, this message translates to:
  /// **'Illumination'**
  String get sunMoonIlluminationLabel;

  /// No description provided for @sunMoonIlluminationValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String sunMoonIlluminationValue(int percent);

  /// No description provided for @sunMoonAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get sunMoonAgeLabel;

  /// No description provided for @sunMoonAgeValue.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String sunMoonAgeValue(String days);

  /// No description provided for @sunMoonMoonrise.
  ///
  /// In en, this message translates to:
  /// **'Moonrise'**
  String get sunMoonMoonrise;

  /// No description provided for @sunMoonMoonset.
  ///
  /// In en, this message translates to:
  /// **'Moonset'**
  String get sunMoonMoonset;

  /// No description provided for @rangeRingTitle.
  ///
  /// In en, this message translates to:
  /// **'Range ring'**
  String get rangeRingTitle;

  /// No description provided for @coveragePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Coverage plan'**
  String get coveragePlanTitle;

  /// No description provided for @coveragePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place suggested repeater or mesh sites with overlapping range circles. Optionally run viewshed (LOS) on the seed site. Planning geometry only — not live RF.'**
  String get coveragePlanSubtitle;

  /// No description provided for @coveragePlanTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get coveragePlanTemplateLabel;

  /// No description provided for @coveragePlanTemplateMesh.
  ///
  /// In en, this message translates to:
  /// **'Mesh / LoRa'**
  String get coveragePlanTemplateMesh;

  /// No description provided for @coveragePlanTemplateRepeater.
  ///
  /// In en, this message translates to:
  /// **'VHF/UHF repeater'**
  String get coveragePlanTemplateRepeater;

  /// No description provided for @coveragePlanTemplateShack.
  ///
  /// In en, this message translates to:
  /// **'Ham shack'**
  String get coveragePlanTemplateShack;

  /// No description provided for @coveragePlanLayoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get coveragePlanLayoutLabel;

  /// No description provided for @coveragePlanLayoutSingle.
  ///
  /// In en, this message translates to:
  /// **'Single site'**
  String get coveragePlanLayoutSingle;

  /// No description provided for @coveragePlanLayoutHexRing.
  ///
  /// In en, this message translates to:
  /// **'Hex ring (7)'**
  String get coveragePlanLayoutHexRing;

  /// No description provided for @coveragePlanAnchorLabel.
  ///
  /// In en, this message translates to:
  /// **'Seed center'**
  String get coveragePlanAnchorLabel;

  /// No description provided for @coveragePlanAnchorMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get coveragePlanAnchorMarker;

  /// No description provided for @coveragePlanAnchorMarkerNamed.
  ///
  /// In en, this message translates to:
  /// **'Marker: {name}'**
  String coveragePlanAnchorMarkerNamed(String name);

  /// No description provided for @coveragePlanAnchorHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get coveragePlanAnchorHome;

  /// No description provided for @coveragePlanAnchorMapPoint.
  ///
  /// In en, this message translates to:
  /// **'Map point'**
  String get coveragePlanAnchorMapPoint;

  /// No description provided for @coveragePlanRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Coverage radius'**
  String get coveragePlanRadiusLabel;

  /// No description provided for @coveragePlanRadiusHelp.
  ///
  /// In en, this message translates to:
  /// **'Range circle drawn around each site.'**
  String get coveragePlanRadiusHelp;

  /// No description provided for @coveragePlanSpacingLabel.
  ///
  /// In en, this message translates to:
  /// **'Site spacing'**
  String get coveragePlanSpacingLabel;

  /// No description provided for @coveragePlanSpacingHelp.
  ///
  /// In en, this message translates to:
  /// **'Center-to-center distance for the hex ring (defaults to ~1.7× radius for light overlap).'**
  String get coveragePlanSpacingHelp;

  /// No description provided for @coveragePlanCreateMarkers.
  ///
  /// In en, this message translates to:
  /// **'Create markers'**
  String get coveragePlanCreateMarkers;

  /// No description provided for @coveragePlanCreateCircles.
  ///
  /// In en, this message translates to:
  /// **'Create range circles'**
  String get coveragePlanCreateCircles;

  /// No description provided for @coveragePlanRunViewshed.
  ///
  /// In en, this message translates to:
  /// **'Run viewshed on seed'**
  String get coveragePlanRunViewshed;

  /// No description provided for @coveragePlanRunViewshedHelp.
  ///
  /// In en, this message translates to:
  /// **'Compute terrain LOS from the seed using the template antenna height and coverage radius.'**
  String get coveragePlanRunViewshedHelp;

  /// No description provided for @coveragePlanSiteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Creates 1 site} other{Creates {count} sites}}'**
  String coveragePlanSiteCount(int count);

  /// No description provided for @coveragePlanCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get coveragePlanCreateAction;

  /// No description provided for @coveragePlanMissingCenter.
  ///
  /// In en, this message translates to:
  /// **'Choose a seed center (marker, home, or map point).'**
  String get coveragePlanMissingCenter;

  /// No description provided for @coveragePlanInvalidRadius.
  ///
  /// In en, this message translates to:
  /// **'Enter a coverage radius between 50 m and 100 km.'**
  String get coveragePlanInvalidRadius;

  /// No description provided for @coveragePlanInvalidSpacing.
  ///
  /// In en, this message translates to:
  /// **'Enter a site spacing between 50 m and 100 km.'**
  String get coveragePlanInvalidSpacing;

  /// No description provided for @coveragePlanNeedOutput.
  ///
  /// In en, this message translates to:
  /// **'Enable markers and/or range circles.'**
  String get coveragePlanNeedOutput;

  /// No description provided for @coveragePlanSiteName.
  ///
  /// In en, this message translates to:
  /// **'{template} {label}'**
  String coveragePlanSiteName(String template, String label);

  /// No description provided for @coveragePlanCircleNotes.
  ///
  /// In en, this message translates to:
  /// **'Coverage plan range circle ({template})'**
  String coveragePlanCircleNotes(String template);

  /// No description provided for @coveragePlanRadioNotes.
  ///
  /// In en, this message translates to:
  /// **'Placed by coverage plan ({template})'**
  String coveragePlanRadioNotes(String template);

  /// No description provided for @coveragePlanCreatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Coverage plan: {markers} marker(s), {circles} circle(s).'**
  String coveragePlanCreatedSnack(int markers, int circles);

  /// No description provided for @rangeRingHelp.
  ///
  /// In en, this message translates to:
  /// **'Compute a travel or fuel radius from home, a selected marker (rally point), or the map point, then save it as a circle.'**
  String get rangeRingHelp;

  /// No description provided for @rangeRingCenterLabel.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get rangeRingCenterLabel;

  /// No description provided for @rangeRingCenterMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get rangeRingCenterMarker;

  /// No description provided for @rangeRingCenterHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get rangeRingCenterHome;

  /// No description provided for @rangeRingCenterMapPoint.
  ///
  /// In en, this message translates to:
  /// **'Map point'**
  String get rangeRingCenterMapPoint;

  /// No description provided for @rangeRingNoCenter.
  ///
  /// In en, this message translates to:
  /// **'Select a marker, set a home location, or long-press the map first.'**
  String get rangeRingNoCenter;

  /// No description provided for @rangeRingModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get rangeRingModeLabel;

  /// No description provided for @rangeRingBasisLabel.
  ///
  /// In en, this message translates to:
  /// **'Basis'**
  String get rangeRingBasisLabel;

  /// No description provided for @rangeRingBasisDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get rangeRingBasisDuration;

  /// No description provided for @rangeRingBasisFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get rangeRingBasisFuel;

  /// No description provided for @rangeRingDurationHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (hours)'**
  String get rangeRingDurationHoursLabel;

  /// No description provided for @rangeRingDurationHelp.
  ///
  /// In en, this message translates to:
  /// **'Uses {speedKmh} km/h planning speed (editable under Assumptions).'**
  String rangeRingDurationHelp(String speedKmh);

  /// No description provided for @rangeRingFuelAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel amount'**
  String get rangeRingFuelAmountLabel;

  /// No description provided for @rangeRingFuelUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get rangeRingFuelUnitLabel;

  /// No description provided for @rangeRingFuelUnitLiters.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get rangeRingFuelUnitLiters;

  /// No description provided for @rangeRingFuelUnitGallons.
  ///
  /// In en, this message translates to:
  /// **'gal'**
  String get rangeRingFuelUnitGallons;

  /// No description provided for @rangeRingFuelTankHelp.
  ///
  /// In en, this message translates to:
  /// **'Default tank ≈ {amount} {unit}.'**
  String rangeRingFuelTankHelp(String amount, String unit);

  /// No description provided for @rangeRingAssumptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get rangeRingAssumptionsTitle;

  /// No description provided for @rangeRingSpeedKmhLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed (km/h)'**
  String get rangeRingSpeedKmhLabel;

  /// No description provided for @rangeRingEconomyLabel.
  ///
  /// In en, this message translates to:
  /// **'Fuel economy (L/100 km)'**
  String get rangeRingEconomyLabel;

  /// No description provided for @rangeRingEconomyHelp.
  ///
  /// In en, this message translates to:
  /// **'Lower is more efficient. ATV defaults are thirstier than a car.'**
  String get rangeRingEconomyHelp;

  /// No description provided for @rangeRingTankLabel.
  ///
  /// In en, this message translates to:
  /// **'Tank size ({unit})'**
  String rangeRingTankLabel(String unit);

  /// No description provided for @rangeRingUseFullTank.
  ///
  /// In en, this message translates to:
  /// **'Use full tank'**
  String get rangeRingUseFullTank;

  /// No description provided for @rangeRingPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a duration or fuel amount to preview the radius.'**
  String get rangeRingPreviewEmpty;

  /// No description provided for @rangeRingPreviewRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius ≈ {distance}'**
  String rangeRingPreviewRadius(String distance);

  /// No description provided for @rangeRingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get rangeRingContinue;

  /// No description provided for @rangeRingInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid duration or fuel amount.'**
  String get rangeRingInvalidInput;

  /// No description provided for @rangeRingSuggestedNameDuration.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {hours} h'**
  String rangeRingSuggestedNameDuration(String mode, String hours);

  /// No description provided for @rangeRingSuggestedNameFuel.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {amount} {unit}'**
  String rangeRingSuggestedNameFuel(String mode, String amount, String unit);

  /// No description provided for @rangeRingSuggestedNameMode.
  ///
  /// In en, this message translates to:
  /// **'{mode} range'**
  String rangeRingSuggestedNameMode(String mode);

  /// No description provided for @rangeRingDetailDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String rangeRingDetailDurationHours(String hours);

  /// No description provided for @rangeRingDetailFuelLiters.
  ///
  /// In en, this message translates to:
  /// **'{liters} L'**
  String rangeRingDetailFuelLiters(String liters);

  /// No description provided for @mapRadialAddToGeocoding.
  ///
  /// In en, this message translates to:
  /// **'Add to search'**
  String get mapRadialAddToGeocoding;

  /// No description provided for @viewshedTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewshed / RF LOS'**
  String get viewshedTitle;

  /// No description provided for @slopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Slope / cross-country'**
  String get slopeTitle;

  /// No description provided for @slopeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get slopeRangeLabel;

  /// No description provided for @slopeOpacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get slopeOpacityLabel;

  /// No description provided for @slopeModeCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get slopeModeCost;

  /// No description provided for @slopeModeSlope.
  ///
  /// In en, this message translates to:
  /// **'Slope'**
  String get slopeModeSlope;

  /// No description provided for @slopeMobilityWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get slopeMobilityWalk;

  /// No description provided for @slopeMobilityBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get slopeMobilityBike;

  /// No description provided for @slopeMobilityDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get slopeMobilityDrive;

  /// No description provided for @slopeComputeAction.
  ///
  /// In en, this message translates to:
  /// **'Compute'**
  String get slopeComputeAction;

  /// No description provided for @slopeStatusReadyToCompute.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get slopeStatusReadyToCompute;

  /// No description provided for @slopeStatusComputing.
  ///
  /// In en, this message translates to:
  /// **'Computing {percent}%'**
  String slopeStatusComputing(int percent);

  /// No description provided for @slopeStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get slopeStatusReady;

  /// No description provided for @slopeStatusMissingDem.
  ///
  /// In en, this message translates to:
  /// **'No DEM elevation data'**
  String get slopeStatusMissingDem;

  /// No description provided for @slopeStatusError.
  ///
  /// In en, this message translates to:
  /// **'Slope analysis failed'**
  String get slopeStatusError;

  /// No description provided for @slopeStats.
  ///
  /// In en, this message translates to:
  /// **'Mean slope {mean}° · Max {max}°'**
  String slopeStats(String mean, String max);

  /// No description provided for @slopeLegendHint.
  ///
  /// In en, this message translates to:
  /// **'Green = gentle / easier · Red = steep / costly. DEM slope only — pick Walk, Bike, or Drive.'**
  String get slopeLegendHint;

  /// No description provided for @slopeLegendHintWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk cost: green = easy footing · red = steep scramble. DEM slope only (no trails).'**
  String get slopeLegendHintWalk;

  /// No description provided for @slopeLegendHintBike.
  ///
  /// In en, this message translates to:
  /// **'Bike cost: green = easy spin · red = steep climb. DEM slope only (no roads/trails).'**
  String get slopeLegendHintBike;

  /// No description provided for @slopeLegendHintDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive cost: green = gentle grade · red = steep for vehicles. DEM slope only (no road network).'**
  String get slopeLegendHintDrive;

  /// No description provided for @slopeLegendHintSlope.
  ///
  /// In en, this message translates to:
  /// **'Slope angle: green = flat · red = steep (~35°+). Raw DEM grade, not travel cost.'**
  String get slopeLegendHintSlope;

  /// No description provided for @viewshedInstructions.
  ///
  /// In en, this message translates to:
  /// **'Antenna = observer height above ground (building + mast). Target = receiver/eye height AGL (0 = ground). Range = how far to check. Heights and range use your measurement units (Settings).'**
  String get viewshedInstructions;

  /// No description provided for @viewshedAntennaHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Ant. ({unit})'**
  String viewshedAntennaHeightLabel(String unit);

  /// No description provided for @viewshedTargetHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Tgt ({unit})'**
  String viewshedTargetHeightLabel(String unit);

  /// No description provided for @viewshedRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get viewshedRangeLabel;

  /// No description provided for @viewshedComputeAction.
  ///
  /// In en, this message translates to:
  /// **'Compute'**
  String get viewshedComputeAction;

  /// No description provided for @viewshedStatusReadyToCompute.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get viewshedStatusReadyToCompute;

  /// No description provided for @viewshedStatusComputing.
  ///
  /// In en, this message translates to:
  /// **'Computing… {percent}%'**
  String viewshedStatusComputing(int percent);

  /// No description provided for @viewshedStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get viewshedStatusReady;

  /// No description provided for @viewshedStatusMissingDem.
  ///
  /// In en, this message translates to:
  /// **'No DEM elevation data'**
  String get viewshedStatusMissingDem;

  /// No description provided for @viewshedStatusMissingElevation.
  ///
  /// In en, this message translates to:
  /// **'No elevation at observer'**
  String get viewshedStatusMissingElevation;

  /// No description provided for @viewshedStatusError.
  ///
  /// In en, this message translates to:
  /// **'Viewshed failed'**
  String get viewshedStatusError;

  /// No description provided for @viewshedObserverElevation.
  ///
  /// In en, this message translates to:
  /// **'Ground {ground} · eye {eye}'**
  String viewshedObserverElevation(String ground, String eye);

  /// No description provided for @mapDeadReckoningTitle.
  ///
  /// In en, this message translates to:
  /// **'Dead reckoning'**
  String get mapDeadReckoningTitle;

  /// No description provided for @mapDeadReckoningModePaces.
  ///
  /// In en, this message translates to:
  /// **'Paces'**
  String get mapDeadReckoningModePaces;

  /// No description provided for @mapDeadReckoningModeDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get mapDeadReckoningModeDistance;

  /// No description provided for @mapDeadReckoningHeadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Brg'**
  String get mapDeadReckoningHeadingLabel;

  /// No description provided for @mapDeadReckoningPacesLabel.
  ///
  /// In en, this message translates to:
  /// **'Paces'**
  String get mapDeadReckoningPacesLabel;

  /// No description provided for @mapDeadReckoningPaceLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'m/pace'**
  String get mapDeadReckoningPaceLengthLabel;

  /// No description provided for @mapDeadReckoningDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Dist'**
  String get mapDeadReckoningDistanceLabel;

  /// No description provided for @mapDeadReckoningPlaceMarker.
  ///
  /// In en, this message translates to:
  /// **'Place marker'**
  String get mapDeadReckoningPlaceMarker;

  /// No description provided for @mapDeadReckoningCreateLine.
  ///
  /// In en, this message translates to:
  /// **'Create line'**
  String get mapDeadReckoningCreateLine;

  /// No description provided for @mapDeadReckoningMarkerName.
  ///
  /// In en, this message translates to:
  /// **'DR estimate'**
  String get mapDeadReckoningMarkerName;

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

  /// No description provided for @mapMarkerQrButton.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get mapMarkerQrButton;

  /// No description provided for @mapMarkerQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Marker QR code'**
  String get mapMarkerQrTitle;

  /// No description provided for @mapMarkerQrSavePng.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get mapMarkerQrSavePng;

  /// No description provided for @mapMarkerQrSaveSvg.
  ///
  /// In en, this message translates to:
  /// **'Save vector'**
  String get mapMarkerQrSaveSvg;

  /// No description provided for @mapMarkerQrSavedPng.
  ///
  /// In en, this message translates to:
  /// **'QR code image saved.'**
  String get mapMarkerQrSavedPng;

  /// No description provided for @mapMarkerQrSavedSvg.
  ///
  /// In en, this message translates to:
  /// **'QR code vector saved.'**
  String get mapMarkerQrSavedSvg;

  /// No description provided for @mapMarkerQrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save QR code: {error}'**
  String mapMarkerQrSaveFailed(String error);

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

  /// No description provided for @sortCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get sortCreated;

  /// No description provided for @sortHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get sortHue;

  /// No description provided for @sidebarMergeLines.
  ///
  /// In en, this message translates to:
  /// **'Merge lines'**
  String get sidebarMergeLines;

  /// No description provided for @sidebarMergeLinesNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Select at least two lines to merge.'**
  String get sidebarMergeLinesNeedTwo;

  /// No description provided for @sidebarMergeLinesDone.
  ///
  /// In en, this message translates to:
  /// **'Lines merged. Control points were kept in walk order.'**
  String get sidebarMergeLinesDone;

  /// No description provided for @sidebarMergeLinesFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not merge lines: {error}'**
  String sidebarMergeLinesFailed(String error);

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

  /// No description provided for @mapObjectTypePolygon.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get mapObjectTypePolygon;

  /// No description provided for @mapObjectTypeEvacKit.
  ///
  /// In en, this message translates to:
  /// **'Evac route kit'**
  String get mapObjectTypeEvacKit;

  /// No description provided for @evacKitCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create evac route kit'**
  String get evacKitCreateTitle;

  /// No description provided for @evacKitEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit evac route kit'**
  String get evacKitEditTitle;

  /// No description provided for @evacKitDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Evac kit'**
  String get evacKitDefaultName;

  /// No description provided for @evacKitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Rally → safe house…'**
  String get evacKitNameHint;

  /// No description provided for @evacKitFormHelp.
  ///
  /// In en, this message translates to:
  /// **'{count} waypoints on primary route'**
  String evacKitFormHelp(int count);

  /// No description provided for @evacKitEtaPreview.
  ///
  /// In en, this message translates to:
  /// **'{mode}: {eta}'**
  String evacKitEtaPreview(String mode, String eta);

  /// No description provided for @evacKitPrimaryRouteName.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get evacKitPrimaryRouteName;

  /// No description provided for @evacKitPrimaryRouteNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary route name'**
  String get evacKitPrimaryRouteNameLabel;

  /// No description provided for @evacKitDefaultModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Default travel mode'**
  String get evacKitDefaultModeLabel;

  /// No description provided for @evacKitShowNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Show name on map'**
  String get evacKitShowNameLabel;

  /// No description provided for @evacKitAddAlternateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add alternate route'**
  String get evacKitAddAlternateTitle;

  /// No description provided for @evacKitRouteNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Route name'**
  String get evacKitRouteNameLabel;

  /// No description provided for @evacKitAlternateRouteName.
  ///
  /// In en, this message translates to:
  /// **'Alternate {index}'**
  String evacKitAlternateRouteName(int index);

  /// No description provided for @evacKitDrawingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add waypoints (or tap markers). Double-tap or Finish when done (2+). Undo removes the last point.'**
  String get evacKitDrawingHint;

  /// No description provided for @evacKitDrawingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get evacKitDrawingFinish;

  /// No description provided for @evacKitDrawingUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get evacKitDrawingUndo;

  /// No description provided for @evacKitDrawingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get evacKitDrawingCancel;

  /// No description provided for @evacKitRoutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get evacKitRoutesLabel;

  /// No description provided for @evacKitPrimaryBadge.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get evacKitPrimaryBadge;

  /// No description provided for @evacKitAlternateBadge.
  ///
  /// In en, this message translates to:
  /// **'Alternate'**
  String get evacKitAlternateBadge;

  /// No description provided for @evacKitWaypointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get evacKitWaypointsLabel;

  /// No description provided for @evacKitDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get evacKitDistanceLabel;

  /// No description provided for @evacKitEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get evacKitEtaLabel;

  /// No description provided for @evacKitAddAlternate.
  ///
  /// In en, this message translates to:
  /// **'Add alternate route'**
  String get evacKitAddAlternate;

  /// No description provided for @evacKitRemoveAlternate.
  ///
  /// In en, this message translates to:
  /// **'Remove alternate'**
  String get evacKitRemoveAlternate;

  /// No description provided for @evacKitRemoveAlternateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this alternate route from the kit?'**
  String get evacKitRemoveAlternateConfirm;

  /// No description provided for @evacKitRemoveRoute.
  ///
  /// In en, this message translates to:
  /// **'Remove route'**
  String get evacKitRemoveRoute;

  /// No description provided for @evacKitRemovePrimaryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove the primary route? Choose which alternate becomes the new primary.'**
  String get evacKitRemovePrimaryConfirm;

  /// No description provided for @evacKitRemovePrimarySingleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove the primary route? “{name}” will become the new primary.'**
  String evacKitRemovePrimarySingleConfirm(String name);

  /// No description provided for @evacKitChooseNewPrimary.
  ///
  /// In en, this message translates to:
  /// **'New primary route'**
  String get evacKitChooseNewPrimary;

  /// No description provided for @evacKitMakePrimary.
  ///
  /// In en, this message translates to:
  /// **'Make primary'**
  String get evacKitMakePrimary;

  /// No description provided for @evacKitMakePrimaryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Make “{name}” the primary route? The current primary becomes an alternate.'**
  String evacKitMakePrimaryConfirm(String name);

  /// No description provided for @evacKitCannotRemoveLastRoute.
  ///
  /// In en, this message translates to:
  /// **'A kit must keep at least one route.'**
  String get evacKitCannotRemoveLastRoute;

  /// No description provided for @evacKitEditRouteOnMap.
  ///
  /// In en, this message translates to:
  /// **'Edit route on map'**
  String get evacKitEditRouteOnMap;

  /// No description provided for @evacKitEditingHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a waypoint or control point to move · tap a segment to add a control point · double-tap a mid-point to convert waypoint ↔ control · tap the last waypoint to extend · long-press a mid-point to remove (keep 2+ waypoints) · Done when finished'**
  String get evacKitEditingHint;

  /// No description provided for @evacKitExtendingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map or markers to append waypoints after the end. Done stops extending.'**
  String get evacKitExtendingHint;

  /// No description provided for @sidebarEditEvacKit.
  ///
  /// In en, this message translates to:
  /// **'Edit evac kit'**
  String get sidebarEditEvacKit;

  /// No description provided for @sidebarDeleteEvacKit.
  ///
  /// In en, this message translates to:
  /// **'Delete evac kit'**
  String get sidebarDeleteEvacKit;

  /// No description provided for @polygonCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create polygon AOI'**
  String get polygonCreateTitle;

  /// No description provided for @polygonEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit polygon AOI'**
  String get polygonEditTitle;

  /// No description provided for @polygonDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get polygonDefaultName;

  /// No description provided for @polygonNameHint.
  ///
  /// In en, this message translates to:
  /// **'Property line, patrol sector, no-go…'**
  String get polygonNameHint;

  /// No description provided for @polygonVertexCount.
  ///
  /// In en, this message translates to:
  /// **'{count} vertices'**
  String polygonVertexCount(int count);

  /// No description provided for @polygonDrawingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add vertices. Double-tap or Finish when done (3+). Undo removes the last point.'**
  String get polygonDrawingHint;

  /// No description provided for @polygonFinishAction.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get polygonFinishAction;

  /// No description provided for @polygonUndoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get polygonUndoAction;

  /// No description provided for @sidebarHidePolygon.
  ///
  /// In en, this message translates to:
  /// **'Hide polygon'**
  String get sidebarHidePolygon;

  /// No description provided for @sidebarShowPolygon.
  ///
  /// In en, this message translates to:
  /// **'Show polygon'**
  String get sidebarShowPolygon;

  /// No description provided for @sidebarEditPolygon.
  ///
  /// In en, this message translates to:
  /// **'Edit polygon'**
  String get sidebarEditPolygon;

  /// No description provided for @sidebarDeletePolygon.
  ///
  /// In en, this message translates to:
  /// **'Delete polygon'**
  String get sidebarDeletePolygon;

  /// No description provided for @mapObjectDetailVertices.
  ///
  /// In en, this message translates to:
  /// **'Vertices'**
  String get mapObjectDetailVertices;

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

  /// No description provided for @settingsRestApiPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to manage REST API keys.'**
  String get settingsRestApiPermissionDenied;

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

  /// No description provided for @seasonalOverlayCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create seasonal overlay'**
  String get seasonalOverlayCreateTitle;

  /// No description provided for @seasonalOverlayEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit seasonal overlay'**
  String get seasonalOverlayEditTitle;

  /// No description provided for @seasonalOverlayDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Seasonal area'**
  String get seasonalOverlayDefaultName;

  /// No description provided for @seasonalOverlayVertexCount.
  ///
  /// In en, this message translates to:
  /// **'{count} vertices'**
  String seasonalOverlayVertexCount(int count);

  /// No description provided for @seasonalOverlayDrawingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add vertices for this seasonal area. Double-tap or Finish when you have 3+ points.'**
  String get seasonalOverlayDrawingHint;

  /// No description provided for @seasonalOverlayDateMode.
  ///
  /// In en, this message translates to:
  /// **'Date mode'**
  String get seasonalOverlayDateMode;

  /// No description provided for @seasonalOverlayDateModeAbsolute.
  ///
  /// In en, this message translates to:
  /// **'Absolute'**
  String get seasonalOverlayDateModeAbsolute;

  /// No description provided for @seasonalOverlayDateModeRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get seasonalOverlayDateModeRecurring;

  /// No description provided for @seasonalOverlayWindows.
  ///
  /// In en, this message translates to:
  /// **'Date windows'**
  String get seasonalOverlayWindows;

  /// No description provided for @seasonalOverlayAddWindow.
  ///
  /// In en, this message translates to:
  /// **'Add window'**
  String get seasonalOverlayAddWindow;

  /// No description provided for @seasonalOverlayEditWindow.
  ///
  /// In en, this message translates to:
  /// **'Edit date window'**
  String get seasonalOverlayEditWindow;

  /// No description provided for @seasonalOverlayStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get seasonalOverlayStartDate;

  /// No description provided for @seasonalOverlayEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get seasonalOverlayEndDate;

  /// No description provided for @seasonalOverlayStartMonth.
  ///
  /// In en, this message translates to:
  /// **'Start month'**
  String get seasonalOverlayStartMonth;

  /// No description provided for @seasonalOverlayStartDay.
  ///
  /// In en, this message translates to:
  /// **'Start day'**
  String get seasonalOverlayStartDay;

  /// No description provided for @seasonalOverlayEndMonth.
  ///
  /// In en, this message translates to:
  /// **'End month'**
  String get seasonalOverlayEndMonth;

  /// No description provided for @seasonalOverlayEndDay.
  ///
  /// In en, this message translates to:
  /// **'End day'**
  String get seasonalOverlayEndDay;

  /// No description provided for @seasonalOverlayRecurringHint.
  ///
  /// In en, this message translates to:
  /// **'Month/day each year. Ranges may wrap across New Year.'**
  String get seasonalOverlayRecurringHint;

  /// No description provided for @seasonalOverlayStatusActive.
  ///
  /// In en, this message translates to:
  /// **'In season'**
  String get seasonalOverlayStatusActive;

  /// No description provided for @seasonalOverlayStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Out of season'**
  String get seasonalOverlayStatusInactive;

  /// No description provided for @seasonalOverlayWindowCount.
  ///
  /// In en, this message translates to:
  /// **'{count} window(s)'**
  String seasonalOverlayWindowCount(int count);

  /// No description provided for @seasonalOverlayHide.
  ///
  /// In en, this message translates to:
  /// **'Hide overlay'**
  String get seasonalOverlayHide;

  /// No description provided for @seasonalOverlayShow.
  ///
  /// In en, this message translates to:
  /// **'Show overlay'**
  String get seasonalOverlayShow;

  /// No description provided for @seasonalOverlayZoomTo.
  ///
  /// In en, this message translates to:
  /// **'Zoom to overlay'**
  String get seasonalOverlayZoomTo;

  /// No description provided for @seasonalOverlayDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete seasonal overlay?'**
  String get seasonalOverlayDeleteTitle;

  /// No description provided for @seasonalOverlayDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String seasonalOverlayDeleteConfirm(String name);

  /// No description provided for @seasonalOverlaysSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal overlays'**
  String get seasonalOverlaysSettingsTitle;

  /// No description provided for @seasonalOverlaysSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dated polygon layers for hunting seasons, freeze/thaw windows, and other recurring or one-time map seasons. Stored on the server and included in map backups.'**
  String get seasonalOverlaysSettingsSubtitle;

  /// No description provided for @seasonalOverlaysShowInactive.
  ///
  /// In en, this message translates to:
  /// **'Show out-of-season overlays'**
  String get seasonalOverlaysShowInactive;

  /// No description provided for @seasonalOverlaysShowInactiveHint.
  ///
  /// In en, this message translates to:
  /// **'When off, overlays outside their date windows stay hidden even if enabled.'**
  String get seasonalOverlaysShowInactiveHint;

  /// No description provided for @seasonalOverlaysDrawHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press the map → More → More → Season, then draw a polygon and set date windows.'**
  String get seasonalOverlaysDrawHint;

  /// No description provided for @seasonalOverlaysInstalled.
  ///
  /// In en, this message translates to:
  /// **'Overlays'**
  String get seasonalOverlaysInstalled;

  /// No description provided for @seasonalOverlaysEmpty.
  ///
  /// In en, this message translates to:
  /// **'No seasonal overlays yet.'**
  String get seasonalOverlaysEmpty;

  /// No description provided for @seasonalOverlaysLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load seasonal overlays: {error}'**
  String seasonalOverlaysLoadFailed(String error);

  /// No description provided for @sidebarSeasonalOverlays.
  ///
  /// In en, this message translates to:
  /// **'Seasonal overlays'**
  String get sidebarSeasonalOverlays;

  /// No description provided for @sidebarSeasonalOverlaysLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get sidebarSeasonalOverlaysLoading;

  /// No description provided for @sidebarSeasonalOverlaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} overlay(s)'**
  String sidebarSeasonalOverlaysCount(int count);

  /// No description provided for @routingTitle.
  ///
  /// In en, this message translates to:
  /// **'Routing'**
  String get routingTitle;

  /// No description provided for @routingPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to configure the routing server.'**
  String get routingPermissionDenied;

  /// No description provided for @routingServerConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Routing server'**
  String get routingServerConnectionTitle;

  /// No description provided for @routingServerConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Separate offline OSM turn-by-turn routing server (GraphHopper). Import a region once, then LAN clients can compute routes from the routing host without any internet access.'**
  String get routingServerConnectionDescription;

  /// No description provided for @routingServerUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Routing server web URL'**
  String get routingServerUrlLabel;

  /// No description provided for @routingSaveServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Save routing server URL'**
  String get routingSaveServerUrl;

  /// No description provided for @routingServerUrlSaved.
  ///
  /// In en, this message translates to:
  /// **'Routing server URL saved.'**
  String get routingServerUrlSaved;

  /// No description provided for @routingStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Import status'**
  String get routingStatusTitle;

  /// No description provided for @routingStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Not imported'**
  String get routingStatusIdle;

  /// No description provided for @routingStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking routing server…'**
  String get routingStatusChecking;

  /// No description provided for @routingStatusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get routingStatusDownloading;

  /// No description provided for @routingImportProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String routingImportProgressPercent(String percent);

  /// No description provided for @routingStatusBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building routing graph…'**
  String get routingStatusBuilding;

  /// No description provided for @routingStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get routingStatusReady;

  /// No description provided for @routingStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get routingStatusFailed;

  /// No description provided for @routingStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get routingStatusCancelled;

  /// No description provided for @routingImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import map data'**
  String get routingImportTitle;

  /// No description provided for @routingImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import OSM region(s) and build the offline routing graph. Prefer US state extracts; select multiple bordering states (e.g. Virginia + West Virginia) to merge them into one graph for cross-border routes.'**
  String get routingImportDescription;

  /// No description provided for @routingMultiStateHint.
  ///
  /// In en, this message translates to:
  /// **'Search and add US states one at a time. Multiple states are downloaded, merged with Osmium, and built as a single routing graph — no need for the entire United States.'**
  String get routingMultiStateHint;

  /// No description provided for @routingSelectedStatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected states'**
  String get routingSelectedStatesLabel;

  /// No description provided for @routingMultiStateMergeHint.
  ///
  /// In en, this message translates to:
  /// **'{count} states will be merged into one graph.'**
  String routingMultiStateMergeHint(int count);

  /// No description provided for @routingImportMultiAction.
  ///
  /// In en, this message translates to:
  /// **'Import {count} states'**
  String routingImportMultiAction(int count);

  /// No description provided for @routingRegionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a state or region…'**
  String get routingRegionSearchHint;

  /// No description provided for @routingLocalOsmHint.
  ///
  /// In en, this message translates to:
  /// **'Large country extracts are best downloaded elsewhere and copied into the routing server data folder as osm.pbf, or uploaded here. The routing graph is stored on that server\'s disk (MMAP) — there is no Postgres database.'**
  String get routingLocalOsmHint;

  /// No description provided for @routingOsmOnServerHint.
  ///
  /// In en, this message translates to:
  /// **'OSM extract on server: {size}'**
  String routingOsmOnServerHint(String size);

  /// No description provided for @routingUploadOsmAction.
  ///
  /// In en, this message translates to:
  /// **'Upload OSM file'**
  String get routingUploadOsmAction;

  /// No description provided for @routingBuildFromLocalAction.
  ///
  /// In en, this message translates to:
  /// **'Build from file on server'**
  String get routingBuildFromLocalAction;

  /// No description provided for @routingOsmUploadStarted.
  ///
  /// In en, this message translates to:
  /// **'OSM file upload started; graph build will follow.'**
  String get routingOsmUploadStarted;

  /// No description provided for @routingOsmUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'OSM upload failed: {error}'**
  String routingOsmUploadFailed(String error);

  /// No description provided for @routingRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get routingRegionLabel;

  /// No description provided for @routingCustomRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom region'**
  String get routingCustomRegionLabel;

  /// No description provided for @routingCustomUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom OSM extract URL'**
  String get routingCustomUrlLabel;

  /// No description provided for @routingRegionOrUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more regions, or enter a custom OSM extract URL.'**
  String get routingRegionOrUrlRequired;

  /// No description provided for @routingImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import region'**
  String get routingImportAction;

  /// No description provided for @routingCancelImport.
  ///
  /// In en, this message translates to:
  /// **'Cancel import'**
  String get routingCancelImport;

  /// No description provided for @routingImportStarted.
  ///
  /// In en, this message translates to:
  /// **'Routing import started.'**
  String get routingImportStarted;

  /// No description provided for @routingImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Routing import failed: {error}'**
  String routingImportFailed(String error);

  /// No description provided for @routingAbortFailed.
  ///
  /// In en, this message translates to:
  /// **'Abort failed: {error}'**
  String routingAbortFailed(String error);

  /// No description provided for @routingServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the routing server. Check that it is running and reachable from your browser.'**
  String get routingServerUnreachable;

  /// No description provided for @routingNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configure a routing server URL to enable turn-by-turn routing.'**
  String get routingNotConfigured;

  /// No description provided for @routingNotReady.
  ///
  /// In en, this message translates to:
  /// **'The routing server has not finished importing map data yet.'**
  String get routingNotReady;

  /// No description provided for @routingReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Ready for routing. LAN clients can compute routes from this host without internet access.'**
  String get routingReadyHint;

  /// No description provided for @routingRouteHereAction.
  ///
  /// In en, this message translates to:
  /// **'Route here'**
  String get routingRouteHereAction;

  /// No description provided for @routingProfilePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel mode'**
  String get routingProfilePickerTitle;

  /// No description provided for @routingProfilePickerDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how to route from your current location to this place.'**
  String get routingProfilePickerDescription;

  /// No description provided for @routingProfileFoot.
  ///
  /// In en, this message translates to:
  /// **'Foot'**
  String get routingProfileFoot;

  /// No description provided for @routingProfileBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get routingProfileBike;

  /// No description provided for @routingProfileCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get routingProfileCar;

  /// No description provided for @routingRouteRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Route request failed: {error}'**
  String routingRouteRequestFailed(String error);

  /// No description provided for @routingRouteSummary.
  ///
  /// In en, this message translates to:
  /// **'{distance} · {duration}'**
  String routingRouteSummary(String distance, String duration);

  /// No description provided for @routingRouteSummaryWithProfile.
  ///
  /// In en, this message translates to:
  /// **'{profile} · {distance} · {duration}'**
  String routingRouteSummaryWithProfile(
    String profile,
    String distance,
    String duration,
  );

  /// No description provided for @routingClearRouteAction.
  ///
  /// In en, this message translates to:
  /// **'Clear route'**
  String get routingClearRouteAction;

  /// No description provided for @routingDirectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get routingDirectionsTitle;

  /// No description provided for @routingDirectionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No turn-by-turn steps were returned for this route.'**
  String get routingDirectionsEmpty;
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
