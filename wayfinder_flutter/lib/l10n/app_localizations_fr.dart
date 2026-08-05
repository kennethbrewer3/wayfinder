// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Wayfinder';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsTabGeneral => 'Général';

  @override
  String get settingsTabMapTiles => 'Tuiles cartographiques';

  @override
  String get settingsTabMarkerIcons => 'Icônes de marqueurs';

  @override
  String get settingsTabThemes => 'Thèmes';

  @override
  String get settingsTabGeocoding => 'Géocodage';

  @override
  String get settingsTabRouting => 'Itinéraires';

  @override
  String get settingsTabTides => 'Marées';

  @override
  String get settingsTabSeasonalOverlays => 'Seasons';

  @override
  String get settingsTabUsers => 'Utilisateurs et rôles';

  @override
  String get settingsTabTrash => 'Corbeille';

  @override
  String get settingsTabBackup => 'Sauvegarde';

  @override
  String get settingsTabAbout => 'À propos';

  @override
  String get actionUndo => 'Annuler';

  @override
  String get mapObjectDeletedSnackbar => 'Déplacé vers la corbeille';

  @override
  String mapObjectDeletedNamedSnackbar(String name) {
    return '« $name » déplacé vers la corbeille';
  }

  @override
  String get mapObjectCreatedBy => 'Créé par';

  @override
  String get mapObjectUpdatedBy => 'Dernière modification par';

  @override
  String get mapObjectAttributionUnknown => 'Inconnu';

  @override
  String get mapObjectTrashTitle => 'Corbeille';

  @override
  String get mapObjectTrashHelp =>
      'Les marqueurs et zones supprimés peuvent être restaurés ou définitivement effacés. La suppression définitive est irréversible.';

  @override
  String get mapObjectTrashEmpty => 'La corbeille est vide.';

  @override
  String mapObjectTrashLoadFailed(String error) {
    return 'Impossible de charger la corbeille : $error';
  }

  @override
  String get mapObjectTrashMarkersSection => 'Marqueurs';

  @override
  String get mapObjectTrashZonesSection => 'Zones';

  @override
  String get mapObjectTrashRestore => 'Restaurer';

  @override
  String get mapObjectTrashPurge => 'Supprimer définitivement';

  @override
  String get mapObjectTrashRestoreAll => 'Tout restaurer';

  @override
  String get mapObjectTrashPurgeAll => 'Tout supprimer définitivement';

  @override
  String mapObjectTrashDeletedBy(String user) {
    return 'Supprimé par $user';
  }

  @override
  String get mapObjectTrashPurgeConfirmTitle => 'Supprimer définitivement ?';

  @override
  String mapObjectTrashPurgeConfirmBody(String name) {
    return '« $name » sera définitivement supprimé, y compris les pièces jointes.';
  }

  @override
  String get mapObjectTrashPurgeAllConfirmTitle =>
      'Tout supprimer définitivement ?';

  @override
  String get mapObjectTrashPurgeAllConfirmBody =>
      'Tout le contenu de la corbeille sera définitivement supprimé, y compris les pièces jointes.';

  @override
  String get mapObjectTrashPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de restaurer ou de supprimer définitivement des éléments de la corbeille.';

  @override
  String get accessSignInSubtitle =>
      'Sign in with the username your TOC administrator created for you. No email is sent — this app is designed for offline use.';

  @override
  String get accessSignInRequired => 'Sign in to manage users and roles.';

  @override
  String get accessSignInAction => 'Sign in';

  @override
  String accessSessionLoadFailed(String error) {
    return 'Could not load access session: $error';
  }

  @override
  String get accessRetry => 'Retry';

  @override
  String get accessConnectionHint =>
      'If this device cannot reach localhost, enter your Wayfinder API and web server addresses below (LAN IP or hostname).';

  @override
  String get accessServerUrlHelp =>
      'API server URL for sign-in and live data (Serverpod). Do not use localhost on a phone.';

  @override
  String get accessServerUrlHint => 'https://wayfinder-api.example.com';

  @override
  String get accessWebServerUrlHelp =>
      'Web server URL for map tiles (PMTiles), REST, and file downloads. Often a different host than the API.';

  @override
  String get accessWebServerUrlHint => 'https://wayfinder-web.example.com';

  @override
  String accessServerUrlApplied(String apiUrl) {
    return 'Connecting to $apiUrl…';
  }

  @override
  String accessServerUrlsApplied(String apiUrl, String webUrl) {
    return 'Connecting…\nAPI: $apiUrl\nWeb: $webUrl';
  }

  @override
  String accessApiServerConfigured(String apiUrl) {
    return 'API server: $apiUrl';
  }

  @override
  String get accessChangeApiServer => 'Change API server';

  @override
  String get accessSignOut => 'Sign out';

  @override
  String get accessChangePassword => 'Change password';

  @override
  String get accessChangePasswordTitle => 'Change password';

  @override
  String get accessChangePasswordSave => 'Update password';

  @override
  String get accessCurrentPasswordLabel => 'Current password';

  @override
  String get accessNewPasswordLabel => 'New password';

  @override
  String get accessConfirmPasswordLabel => 'Confirm new password';

  @override
  String get accessChangePasswordTooShort =>
      'Password must be at least 8 characters.';

  @override
  String get accessChangePasswordMismatch =>
      'New password and confirmation do not match.';

  @override
  String get accessChangePasswordSameAsCurrent =>
      'New password must be different from the current password.';

  @override
  String get accessChangePasswordFieldsRequired =>
      'Enter your current password and a new password.';

  @override
  String get accessChangePasswordSuccess => 'Password updated.';

  @override
  String accessChangePasswordFailed(String error) {
    return 'Could not change password: $error';
  }

  @override
  String get accessSignedIn => 'Signed in';

  @override
  String get accessUnknownRole => 'No role';

  @override
  String get accessUsersTitle => 'Users';

  @override
  String get accessUsersHelp =>
      'Create TOC accounts and assign roles. Usernames are local login IDs — Wayfinder does not send email.';

  @override
  String get accessUsersPermissionDenied =>
      'You do not have permission to manage users or roles.';

  @override
  String get manageLayersPermissionDenied =>
      'You do not have permission to manage map layers or seasonal overlays.';

  @override
  String get accessUsersEmpty =>
      'No users yet. Create an administrator or set WAYFINDER_BOOTSTRAP_ADMIN_EMAIL / PASSWORD (username + password).';

  @override
  String accessUsersLoadFailed(String error) {
    return 'Could not load users: $error';
  }

  @override
  String get accessCreateUser => 'Create user';

  @override
  String get accessUsernameLabel => 'Username';

  @override
  String get accessUsernameHelp =>
      'Local login id for this TOC. No email is sent.';

  @override
  String get accessEmailLabel => 'Username';

  @override
  String get accessPasswordLabel => 'Password';

  @override
  String get accessDisplayNameLabel => 'Display name (optional)';

  @override
  String get accessRoleLabel => 'Role';

  @override
  String get accessChangeRole => 'Change role';

  @override
  String get accessBlockUser => 'Block user';

  @override
  String get accessUnblockUser => 'Unblock user';

  @override
  String get accessResetPassword => 'Reset password';

  @override
  String accessResetPasswordTitle(String email) {
    return 'Reset password for $email';
  }

  @override
  String get accessResetPasswordSave => 'Set new password';

  @override
  String accessResetPasswordSuccess(String email) {
    return 'Password reset for $email.';
  }

  @override
  String accessResetPasswordFailed(String error) {
    return 'Could not reset password: $error';
  }

  @override
  String get accessDeleteUser => 'Remove user';

  @override
  String get accessDeleteUserTitle => 'Remove user?';

  @override
  String accessDeleteUserConfirm(String email) {
    return 'Remove $email? Their account and preferences will be deleted. This cannot be undone.';
  }

  @override
  String accessDeleteUserSuccess(String email) {
    return 'Removed $email.';
  }

  @override
  String get accessUserBlocked => 'Blocked';

  @override
  String get accessRolesTitle => 'Roles';

  @override
  String get accessRolesHelp =>
      'Built-in Administrator, Editor, and Viewer roles are seeded automatically. Create custom roles and choose permissions.';

  @override
  String get accessRolesEmpty => 'No roles found.';

  @override
  String accessRolesLoadFailed(String error) {
    return 'Could not load roles: $error';
  }

  @override
  String get accessCreateRole => 'Create role';

  @override
  String get accessEditRole => 'Edit role';

  @override
  String get accessDeleteRole => 'Delete role';

  @override
  String get accessRoleKeyLabel => 'Role key';

  @override
  String get accessRoleKeyHelp =>
      'Lowercase letters, numbers, and underscores.';

  @override
  String get accessRoleNameLabel => 'Display name';

  @override
  String get accessRoleDescriptionLabel => 'Description';

  @override
  String get accessPermissionsLabel => 'Permissions';

  @override
  String accessRoleMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String get settingsAboutTitle => 'À propos de Wayfinder';

  @override
  String get settingsAboutDescription =>
      'Détails de compilation et de connexion en lecture seule pour ce client. Utilisez le commit git pour vérifier si la dernière compilation est en cours d\'exécution.';

  @override
  String get settingsAboutOpenManual => 'Open user manual';

  @override
  String get settingsAboutLoading =>
      'Chargement des informations de l\'application…';

  @override
  String settingsAboutLoadFailed(String error) {
    return 'Impossible de charger les informations de l\'application : $error';
  }

  @override
  String get settingsAboutAppSection => 'Application';

  @override
  String get settingsAboutConnectionSection => 'Connexion';

  @override
  String get settingsAboutDeploymentSection => 'Déploiement';

  @override
  String get settingsAboutDockerImageId => 'ID d\'image Docker';

  @override
  String get settingsAboutDockerImageIdUnavailable =>
      'Non disponible — recréez le conteneur après un pull pour enregistrer l\'ID d\'image au démarrage.';

  @override
  String get settingsAboutDockerImageRef => 'Référence d\'image Docker';

  @override
  String get settingsAboutContainerStarted => 'Conteneur démarré';

  @override
  String settingsAboutDockerImageIdHint(String imageIdPrefix) {
    return 'L\'ID d\'image Docker change à chaque nouveau pull. Il devrait commencer par $imageIdPrefix et correspondre à la colonne IMAGE ID de docker compose images ou docker image inspect.';
  }

  @override
  String get settingsAboutDockerImageIdHintUnavailable =>
      'Après docker compose pull, exécutez docker compose up -d --force-recreate pour que le conteneur enregistre ici l\'ID d\'image actuel. L\'ID change à chaque nouvelle compilation même si l\'étiquette reste :latest.';

  @override
  String get settingsAboutAppName => 'Nom de l\'application';

  @override
  String get settingsAboutVersion => 'Version';

  @override
  String get settingsAboutGitCommit => 'Commit git';

  @override
  String get settingsAboutGitCommitUnavailable =>
      'Non disponible (compilation locale de développement)';

  @override
  String get settingsAboutBuildTime => 'Compilée';

  @override
  String get settingsAboutPlatform => 'Plateforme';

  @override
  String get settingsAboutPackage => 'Paquet';

  @override
  String get settingsAboutApiServer => 'Serveur API';

  @override
  String get settingsAboutWebServer => 'Serveur web';

  @override
  String get settingsAboutGeocodingServer => 'Serveur de géocodage';

  @override
  String get settingsAboutGeocodingServerNotConfigured => 'Non configuré';

  @override
  String get settingsAboutRoutingServer => 'Serveur d\'itinéraires';

  @override
  String get settingsAboutRoutingServerNotConfigured => 'Non configuré';

  @override
  String settingsAboutCommitHint(String commit) {
    return 'Les compilations déployées incluent un commit git (par exemple $commit). Comparez-le au dernier commit sur main ou à l\'étiquette d\'image que vous avez téléchargée.';
  }

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionLater => 'Plus tard';

  @override
  String get actionOk => 'OK';

  @override
  String get actionReloadNow => 'Recharger maintenant';

  @override
  String get actionSaving => 'Enregistrement…';

  @override
  String get actionCreate => 'Créer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionImport => 'Importer';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionRemoveAll => 'Tout supprimer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionTryAgain => 'Réessayer';

  @override
  String get actionOpenSettings => 'Ouvrir les paramètres';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String get actionSignOut => 'Se déconnecter';

  @override
  String get actionUploading => 'Téléversement…';

  @override
  String get actionExporting => 'Exportation…';

  @override
  String get actionImporting => 'Importation…';

  @override
  String get actionRestoring => 'Restauration…';

  @override
  String get actionAborting => 'Annulation…';

  @override
  String get statusLoading => 'Chargement…';

  @override
  String get statusWorking => 'Traitement…';

  @override
  String errorWithMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get settingsAppearanceTitle => 'Apparence';

  @override
  String get settingsAppearanceDescription =>
      'Choisissez un thème et activez le mode sombre. Les thèmes personnalisés génèrent des palettes claire et sombre à partir de la même couleur de base. Gérés dans Paramètres → Thèmes (manage_themes). Enregistré sur votre compte pour vous suivre sur n\'importe quel poste.';

  @override
  String get settingsAppearanceTheme => 'Thème';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsDarkModeDescription =>
      'Utilise la palette sombre du thème sélectionné. Les thèmes intégrés et personnalisés prennent en charge clair et sombre.';

  @override
  String get settingsThemesTitle => 'Thèmes';

  @override
  String get settingsThemesDescription =>
      'Créez et gérez des thèmes partagés du TOC. Tout le monde peut choisir un thème ; seuls les utilisateurs avec manage_themes peuvent créer, modifier, importer ou exporter.';

  @override
  String get settingsThemesPermissionDenied =>
      'Vous pouvez choisir un thème, mais vous n\'avez pas la permission de créer, modifier, importer ou exporter.';

  @override
  String get settingsThemesBuiltInTitle => 'Thèmes intégrés';

  @override
  String get settingsThemesBuiltInSubtitle => 'Inclus avec Wayfinder';

  @override
  String get settingsThemesCustomTitle => 'Thèmes personnalisés du TOC';

  @override
  String get settingsThemesCustomEmpty =>
      'Aucun thème personnalisé pour l\'instant. Créez-en un ou importez un fichier JSON.';

  @override
  String get settingsThemesCustomSubtitle =>
      'Clair et sombre depuis la couleur de base';

  @override
  String get settingsThemesUseBuiltInHint => 'Thème intégré en cours';

  @override
  String get settingsThemesNew => 'Nouveau thème';

  @override
  String get settingsThemesNewTitle => 'Nouveau thème';

  @override
  String get settingsThemesEditTitle => 'Modifier le thème';

  @override
  String get settingsThemesEdit => 'Modifier';

  @override
  String get settingsThemesDuplicate => 'Dupliquer';

  @override
  String get settingsThemesExport => 'Exporter';

  @override
  String get settingsThemesImport => 'Importer';

  @override
  String get settingsThemesDelete => 'Supprimer';

  @override
  String get settingsThemesUse => 'Utiliser';

  @override
  String get settingsThemesName => 'Nom';

  @override
  String get settingsThemesNameRequired => 'Saisissez un nom de thème.';

  @override
  String get settingsThemesSeedColor => 'Couleur de base';

  @override
  String get settingsThemesSeedColorHint =>
      'Material génère les palettes claire et sombre à partir de cette couleur. Les remplacements ci-dessous s\'appliquent uniquement à la luminosité d\'édition.';

  @override
  String get settingsThemesAuthoringBrightness => 'Luminosité d\'édition';

  @override
  String get settingsThemesAuthoringBrightnessHint =>
      'Modifiez les remplacements pour cette luminosité. L\'autre mode est généré automatiquement à partir de la couleur de base via Mode sombre dans Apparence.';

  @override
  String get settingsThemesOverridesTitle => 'Remplacements de couleur';

  @override
  String get settingsThemesOverridesHint =>
      'Facultatif. Uniquement pour la luminosité d\'édition ; l\'autre mode utilise la palette générée.';

  @override
  String get settingsThemesOverrideFromSeed => 'Depuis la base';

  @override
  String get settingsThemesClearOverride => 'Effacer le remplacement';

  @override
  String get settingsThemesShowAllOverrides =>
      'Afficher tous les rôles de couleur';

  @override
  String get settingsThemesShowFewerOverrides => 'Afficher moins de rôles';

  @override
  String get settingsThemesPreview => 'Aperçu';

  @override
  String settingsThemesLoadFailed(String error) {
    return 'Échec du chargement des thèmes : $error';
  }

  @override
  String settingsThemesLoadFailedServerError(String apiUrl) {
    return 'The API server returned an error (HTTP 500) while listing custom themes.\n\nAPI: $apiUrl\n\nCustom themes are loaded from the Wayfinder API (not the web/PMTiles URL). This usually means the API is outdated or missing the app_theme_definition database migration. Built-in themes above still work — update/redeploy the API and apply migrations, then retry.';
  }

  @override
  String settingsThemesLoadFailedSignIn(String apiUrl) {
    return 'Could not list custom themes. Sign in with an account that can view the map, then retry.\n\nAPI: $apiUrl';
  }

  @override
  String settingsThemesLoadFailedUnreachable(String apiUrl) {
    return 'Could not reach the Wayfinder API to load custom themes.\n\nAPI: $apiUrl\n\nOn a phone, confirm Settings → General uses your real API URL (not localhost) and that it is separate from the web/PMTiles URL.';
  }

  @override
  String settingsThemesLoadFailedGeneric(String apiUrl, String error) {
    return 'Could not load custom themes.\n\nAPI: $apiUrl\n\nDetails: $error';
  }

  @override
  String get settingsThemesRetry => 'Retry';

  @override
  String settingsThemesSaved(String name) {
    return 'Thème « $name » enregistré.';
  }

  @override
  String settingsThemesSaveFailed(String error) {
    return 'Échec de l\'enregistrement du thème : $error';
  }

  @override
  String settingsThemesImported(String name) {
    return 'Thème « $name » importé.';
  }

  @override
  String settingsThemesImportFailed(String error) {
    return 'Échec de l\'importation du thème : $error';
  }

  @override
  String settingsThemesExported(String name) {
    return 'Thème « $name » exporté.';
  }

  @override
  String settingsThemesExportFailed(String error) {
    return 'Échec de l\'exportation du thème : $error';
  }

  @override
  String get settingsThemesDeleteTitle => 'Supprimer le thème ?';

  @override
  String settingsThemesDeleteMessage(String name) {
    return 'Supprimer « $name » ? Les utilisateurs qui l\'avaient choisi repasseront au thème clair standard.';
  }

  @override
  String settingsThemesDeleted(String name) {
    return 'Thème « $name » supprimé.';
  }

  @override
  String settingsThemesDeleteFailed(String error) {
    return 'Échec de la suppression du thème : $error';
  }

  @override
  String settingsThemesCopyName(String name) {
    return 'Copie de $name';
  }

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageDescription =>
      'Choisissez la langue utilisée dans l\'application. Enregistrée sur votre compte pour vous suivre sur n\'importe quel poste.';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get settingsThemeStyle => 'Style de thème';

  @override
  String get settingsBrightness => 'Luminosité';

  @override
  String get settingsMapHomeTitle => 'Accueil carte';

  @override
  String get settingsMapHomeDescription =>
      'Coordonnées et zoom du bouton d\'accueil sur la carte. Enregistré sur le serveur pour que tous les clients partagent le même point d\'accueil. Utilisé aussi comme vue initiale lorsqu\'aucune position précédente n\'est enregistrée.';

  @override
  String get settingsMapHomePermissionDenied =>
      'Vous n\'avez pas l\'autorisation de modifier le point d\'accueil partagé de la carte.';

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
  String get settingsSaveHome => 'Enregistrer l\'accueil';

  @override
  String get settingsUseCurrentMapView => 'Utiliser la vue actuelle';

  @override
  String get settingsResetToDefault => 'Réinitialiser par défaut';

  @override
  String get settingsServerConnectionTitle => 'Connexion au serveur';

  @override
  String get settingsServerConnectionDescription =>
      'Saisissez l\'URL de l\'API Wayfinder (connexion / données en direct) et l\'URL web (tuiles cartographiques, REST, fichiers). Ce sont souvent des hôtes différents derrière un reverse proxy.';

  @override
  String get settingsServerConnectionPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de modifier l\'URL du serveur Wayfinder de cet appareil.';

  @override
  String get settingsServerUrl => 'URL du serveur API';

  @override
  String get settingsWebServerUrl => 'URL du serveur web';

  @override
  String settingsCurrentWebServer(String webUrl) {
    return 'Serveur web actuel : $webUrl';
  }

  @override
  String get settingsSaveServerUrl => 'Enregistrer les URL du serveur';

  @override
  String get settingsEditServerUrls => 'Modifier les URL du serveur';

  @override
  String get settingsGeocodingAvailabilityTitle => 'Map search (geocoding)';

  @override
  String get settingsGeocodingAvailabilityDescription =>
      'Whether place and address search from the map bar is available for this device.';

  @override
  String get settingsGeocodingOpenTab => 'Geocoding settings';

  @override
  String get settingsRoutingAvailabilityTitle => 'Itinéraires turn-by-turn';

  @override
  String get settingsRoutingAvailabilityDescription =>
      'Indique si le calcul d\'itinéraires OSM A→B depuis cet appareil peut joindre le serveur d\'itinéraires optionnel.';

  @override
  String get settingsRoutingOpenTab => 'Paramètres d\'itinéraires';

  @override
  String get settingsMeasurementsTitle => 'Mesures';

  @override
  String get settingsMeasurementsDescription =>
      'Choisissez comment les distances des lignes sont affichées sur la carte. Enregistré sur le serveur pour que chaque navigateur utilise les mêmes unités.';

  @override
  String get settingsAnglesTitle => 'Angles';

  @override
  String get settingsAnglesDescription =>
      'Choisissez comment les angles relatifs sont affichés sur la carte et dans les graphiques de relèvement. Enregistré sur le serveur pour que chaque navigateur utilise le même format.';

  @override
  String get settingsBearingsTitle => 'Relèvements';

  @override
  String get settingsBearingsDescription =>
      'Affichez les relèvements absolus en nord vrai (°T) ou nord magnétique (°M) avec la déclinaison WMM2025 à votre GPS ou au centre de la carte. La rose des vents indique toujours le nord vrai ; la variation apparaît en dessous.';

  @override
  String get bearingReferenceTrue => 'Nord vrai';

  @override
  String get bearingReferenceMagnetic => 'Nord magnétique';

  @override
  String get bearingReferenceTrueShort => 'Vrai';

  @override
  String get bearingReferenceMagneticShort => 'Magnétique';

  @override
  String get lineArrowDensityLabel => 'Fréquence des flèches';

  @override
  String get lineArrowDensitySparse => 'Clairsemé';

  @override
  String get lineArrowDensityLight => 'Léger';

  @override
  String get lineArrowDensityBalanced => 'Équilibré';

  @override
  String get lineArrowDensityFrequent => 'Fréquent';

  @override
  String get lineArrowDensityDense => 'Dense';

  @override
  String get settingsCirclesTitle => 'Cercles';

  @override
  String get settingsCirclesDescription =>
      'Choisissez l\'étiquette de taille par défaut affichée sur les nouvelles zones circulaires. Enregistré sur le serveur pour que chaque navigateur utilise la même valeur par défaut.';

  @override
  String get settingsMapEditingTitle => 'Édition de la carte';

  @override
  String get settingsMapEditingDescription =>
      'Accrochage lors de l\'édition des sommets de polygones et de calques saisonniers. L\'aimant se libère si vous continuez à glisser au-delà.';

  @override
  String get settingsPolygonSnapRightAnglesTitle =>
      'Accrocher aux angles droits (90°)';

  @override
  String get settingsPolygonSnapRightAnglesDescription =>
      'En faisant glisser un sommet, accroche doucement aux coins carrés — y compris pour rendre les coins adjacents à 90° pour de meilleurs rectangles.';

  @override
  String get settingsPolygonSnap45AnglesTitle => 'Accrocher aux angles de 45°';

  @override
  String get settingsPolygonSnap45AnglesDescription =>
      'Accroche aussi le coin déplacé vers des angles de 45° et 135°.';

  @override
  String get settingsMapDisplayTitle => 'Affichage de la carte';

  @override
  String get settingsMapDisplayDescription =>
      'Rose des vents, grille MGRS et tuiles assombries en mode sombre pour votre compte. Enregistré sur votre compte pour vous suivre sur tout poste de travail.';

  @override
  String get settingsMapCompassRoseTitle => 'Afficher la rose des vents';

  @override
  String get settingsMapCompassRoseDescription =>
      'Affiche une boussole en bas à gauche de la carte (au-dessus de la barre d\'état GPS si elle est visible). Double frappe : réinitialiser la rotation ; appui long : basculer nord vrai/magnétique ; boutons ±5° pour tourner la carte. Variation WMM2025.';

  @override
  String get settingsMapMgrsGridTitle => 'Afficher la grille MGRS';

  @override
  String get settingsMapMgrsGridDescription =>
      'Superpose une vraie grille MGRS (basée sur l\'UTM). L\'espacement suit le zoom. Les joints de zone et une légère courbure sur la carte Web Mercator sont attendus — les carrés MGRS ne sont pas des rectangles lat/lng.';

  @override
  String get settingsDarkMapTilesTitle => 'Assombrir les tuiles en mode sombre';

  @override
  String get settingsDarkMapTilesDescription =>
      'Lorsque l\'application est en mode sombre, applique un filtre de couleur aux tuiles du fond de carte pour les assombrir. C\'est un style sombre simulé sur les tuiles existantes — pas une cartographie sombre distincte. Désactivez pour conserver l\'apparence habituelle des tuiles pendant que le reste de l\'interface reste sombre. Les PDF d\'atlas imprimable utilisent toujours des tuiles normales pour rester lisibles sur papier.';

  @override
  String get settingsMapZoomRangeTitle => 'Plage de zoom de la carte';

  @override
  String get settingsMapZoomRangeDescription =>
      'Zoom minimum et maximum partagés pour tous les clients. Enregistré sur le serveur. Augmenter le maximum peut nuire aux performances si les tuiles hors ligne ne couvrent pas ces niveaux.';

  @override
  String get settingsMapZoomRangePermissionDenied =>
      'Vous n\'avez pas l\'autorisation de modifier la plage de zoom partagée de la carte.';

  @override
  String get settingsMapZoomRangeWarning =>
      'Modifier la plage de zoom peut ralentir la carte, augmenter l\'utilisation de la mémoire ou afficher des tuiles étirées lorsque vos données hors ligne ne contiennent pas de détails à ces niveaux. N\'augmentez le maximum que si vos archives cartographiques le prennent en charge.';

  @override
  String get settingsMapMinZoom => 'Zoom minimum';

  @override
  String get settingsMapMaxZoom => 'Zoom maximum';

  @override
  String settingsMapZoomLimitHelper(String min, String max) {
    return '$min–$max';
  }

  @override
  String get settingsMapZoomRangeSave => 'Enregistrer la plage de zoom';

  @override
  String get settingsMapZoomRangeSaved =>
      'Plage de zoom de la carte enregistrée.';

  @override
  String get settingsMapZoomRangeInvalid =>
      'Saisissez des valeurs de zoom minimum et maximum valides.';

  @override
  String settingsMapZoomRangeSaveFailed(String error) {
    return 'Échec de l\'enregistrement de la plage de zoom : $error';
  }

  @override
  String get settingsMapDebugTitle => 'Débogage de la carte';

  @override
  String get settingsMapDebugDescription =>
      'Aides enregistrées uniquement sur cet appareil.';

  @override
  String get settingsMapMarkerSizeTitle => 'Taille des marqueurs';

  @override
  String get settingsMapMarkerSizeDescription =>
      'Ajustez la taille des marqueurs sur la carte. Enregistré sur votre compte pour vous suivre sur tout poste de travail.';

  @override
  String settingsMapMarkerSizeValue(int percent) {
    return '$percent %';
  }

  @override
  String get settingsMapMarkerSizeMinLabel => 'Plus petit';

  @override
  String get settingsMapMarkerSizeMaxLabel => 'Plus grand';

  @override
  String get settingsMapViewportDebugBorderTitle =>
      'Afficher la bordure du viewport de la carte';

  @override
  String get settingsMapViewportDebugBorderDescription =>
      'Dessine un contour rouge autour du canevas de la carte avec les détails d\'archive, de zoom et de tuile centrale.';

  @override
  String get settingsMapTileBorderDebugTitle =>
      'Afficher les bordures de tuiles';

  @override
  String get settingsMapTileBorderDebugDescription =>
      'Dessine des bordures vertes autour de chaque tuile de la carte. Nécessite la superposition de débogage du viewport ci-dessus.';

  @override
  String get settingsForceOfflinePackTitle =>
      'Utiliser le pack hors ligne en ligne';

  @override
  String get settingsForceOfflinePackDescription =>
      'Utilise le pack hors ligne / de terrain préparé même si le serveur Wayfinder est joignable. Permet de tester le pack sans couper Internet pour les autres applications.';

  @override
  String get settingsForceOfflinePackUnavailable =>
      'Préparez d\'abord un pack hors ligne depuis la barre d\'outils de la carte.';

  @override
  String get settingsSimulatedGpsWalkDelayTitle =>
      'Délai de marche GPS simulée';

  @override
  String get settingsSimulatedGpsWalkDelayDescription =>
      'Secondes entre les positions GPS fictives lors de la simulation d\'une marche sur un itinéraire suivi. S\'applique au prochain démarrage de la simulation.';

  @override
  String settingsSimulatedGpsWalkDelayValue(String seconds) {
    return '$seconds s';
  }

  @override
  String get settingsSimulatedGpsWalkDelayMinLabel => 'Plus rapide';

  @override
  String get settingsSimulatedGpsWalkDelayMaxLabel => 'Plus lent';

  @override
  String get mapDebugOverlayCopyTooltip => 'Copier les infos de débogage';

  @override
  String get mapDebugOverlayCopied =>
      'Infos de débogage copiées dans le presse-papiers.';

  @override
  String get mapDebugOverlayCopyFailedTitle =>
      'Copie bloquée — sélectionnez et copiez manuellement';

  @override
  String get settingsHomeLocationSaved => 'Point d\'accueil enregistré.';

  @override
  String get settingsHomeLocationReset =>
      'Point d\'accueil réinitialisé par défaut.';

  @override
  String get settingsOpenMapFirst =>
      'Ouvrez d\'abord la carte pour capturer sa vue.';

  @override
  String get settingsHomeLocationInvalid =>
      'Saisissez des nombres valides pour la latitude, la longitude et le zoom.';

  @override
  String settingsHomeLocationSaveFailed(String error) {
    return 'Échec de l\'enregistrement du point d\'accueil : $error';
  }

  @override
  String get settingsRestartRequiredTitle => 'Redémarrage requis';

  @override
  String settingsRestartRequiredMessage(String apiUrl, String webUrl) {
    return 'URL du serveur enregistrée.\n\nAPI : $apiUrl\nWeb : $webUrl\n\nRedémarrez l\'application pour vous connecter au nouveau serveur.';
  }

  @override
  String get settingsServerUrlAppliedTitle => 'URL du serveur mise à jour';

  @override
  String settingsServerUrlAppliedMessage(String apiUrl, String webUrl) {
    return 'URL du serveur enregistrée et appliquée.\n\nAPI : $apiUrl\nWeb : $webUrl';
  }

  @override
  String get settingsServerUrlReset =>
      'URL du serveur réinitialisée par défaut. Redémarrez l\'application pour appliquer.';

  @override
  String settingsServerUrlSaveFailed(String error) {
    return 'Échec de l\'enregistrement de l\'URL du serveur : $error';
  }

  @override
  String get themePreviewPrimary => 'Primaire';

  @override
  String get themePreviewSecondary => 'Secondaire';

  @override
  String get themePreviewSurface => 'Surface';

  @override
  String get themePreviewAccent => 'Accent';

  @override
  String get themePreviewButton => 'Bouton';

  @override
  String get themePreviewOutline => 'Contour';

  @override
  String get themeFamilyStandard => 'Standard';

  @override
  String get themeFamilyMilitary => 'Militaire';

  @override
  String get themeBrightnessLight => 'Clair';

  @override
  String get themeBrightnessDark => 'Sombre';

  @override
  String get themeChoiceMilitaryLight => 'Militaire clair';

  @override
  String get themeChoiceMilitaryDark => 'Militaire sombre';

  @override
  String get measurementMetric => 'Métrique';

  @override
  String get measurementImperial => 'Impérial';

  @override
  String get measurementNautical => 'Nautique';

  @override
  String get measurementMetricShort => 'm/km';

  @override
  String get measurementImperialShort => 'pi/pi';

  @override
  String get measurementNauticalShort => 'mn';

  @override
  String get angleFormatDecimal => 'Degrés décimaux';

  @override
  String get angleFormatDms => 'Degrés, minutes, secondes';

  @override
  String get angleFormatDecimalShort => 'DD';

  @override
  String get angleFormatDmsShort => 'DMS';

  @override
  String get circleSizeRadius => 'Rayon';

  @override
  String get circleSizeDiameter => 'Diamètre';

  @override
  String get circleSizeNone => 'Aucun';

  @override
  String get circleSizeToggleRadius =>
      'Rayon affiché sur la carte · appuyez pour le diamètre';

  @override
  String get circleSizeToggleDiameter =>
      'Diamètre affiché sur la carte · appuyez pour masquer';

  @override
  String get circleSizeToggleNone =>
      'Taille masquée sur la carte · appuyez pour le rayon';

  @override
  String get watchLogTitle => 'Journal d\'incident / de veille';

  @override
  String get watchLogSubtitle =>
      'Événements horodatés pour le retour d\'expérience. Notes de planification uniquement.';

  @override
  String get watchLogPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de consulter le journal d\'incident / de veille.';

  @override
  String get watchLogAddPermissionDenied =>
      'Vous n\'avez pas l\'autorisation d\'ajouter ou de modifier des entrées du journal d\'incident / de veille.';

  @override
  String get watchLogObjectHint => 'Entrées liées à cet objet cartographique.';

  @override
  String get watchLogSidebarHint => 'Plus récents d\'abord sur tous les objets';

  @override
  String get watchLogAddEntry => 'Ajouter une entrée';

  @override
  String get watchLogAddEntryTitle => 'Ajouter une entrée au journal';

  @override
  String get watchLogEditEntryTitle => 'Modifier l\'entrée du journal';

  @override
  String get watchLogEmpty => 'Aucune entrée dans le journal pour l\'instant.';

  @override
  String get watchLogEmptyForObject =>
      'Aucune entrée liée à cet objet pour l\'instant.';

  @override
  String watchLogMoreEntries(int count) {
    return '$count de plus…';
  }

  @override
  String watchLogLoadFailed(String error) {
    return 'Impossible de charger le journal : $error';
  }

  @override
  String get watchLogOccurredAtLabel => 'Survenu à';

  @override
  String get watchLogAuthorLabel => 'Opérateur / indicatif';

  @override
  String get watchLogAuthorHint => 'Facultatif';

  @override
  String get watchLogSeverityLabel => 'Sévérité';

  @override
  String get watchLogSeverityInfo => 'Info';

  @override
  String get watchLogSeverityNotice => 'Avis';

  @override
  String get watchLogSeverityWarning => 'Avertissement';

  @override
  String get watchLogSeverityCritical => 'Critique';

  @override
  String get watchLogTextLabel => 'Événement';

  @override
  String get watchLogTextHint => 'Que s\'est-il passé ?';

  @override
  String get watchLogTextRequired => 'Saisissez le texte de l\'événement.';

  @override
  String get backupTitle => 'Sauvegarde des données cartographiques';

  @override
  String get backupPermissionDenied =>
      'Vous n\'avez pas l\'autorisation d\'exporter ou de restaurer les sauvegardes cartographiques.';

  @override
  String get backupDescription =>
      'Exporter ou restaurer les données cartographiques Wayfinder : couches, marqueurs, zones, calques saisonniers, entrées du journal, plans de communications, icônes personnalisées et réglages. Les sauvegardes sont des .zip avec backup.json et marker-icons/*.svg. Les packs de marées et PMTiles ne sont pas inclus (transférez-les depuis Marées / Tuiles). Les anciennes sauvegardes .json restent prises en charge.';

  @override
  String get backupExportButton => 'Exporter les données (.zip)';

  @override
  String get backupRestoreButton => 'Restaurer depuis une sauvegarde';

  @override
  String get backupExportSuccess =>
      'Sauvegarde des données cartographiques enregistrée.';

  @override
  String backupExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get backupRestoreConfirmTitle =>
      'Restaurer les données cartographiques ?';

  @override
  String get backupRestoreConfirmMessage =>
      'Cela remplace toutes les couches, marqueurs, zones, calques saisonniers, entrées du journal de veille, plans de communications et icônes personnalisées sur le serveur par le fichier sélectionné. Cette action est irréversible.';

  @override
  String backupRestoreSuccess(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int commsPlans,
  ) {
    return '$layers couche(s), $markers marqueur(s), $zones zone(s), $seasonalOverlays calque(s) saisonnier(s), $watchLogEntries entrée(s) du journal et $commsPlans plan(s) de communications restauré(s).';
  }

  @override
  String backupRestoreSuccessWithIcons(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int commsPlans,
    int icons,
  ) {
    return '$layers couche(s), $markers marqueur(s), $zones zone(s), $seasonalOverlays calque(s) saisonnier(s), $watchLogEntries entrée(s) du journal, $commsPlans plan(s) de communications et $icons icône(s) personnalisée(s) restauré(s).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get markerAttachmentsTitle => 'Photos';

  @override
  String get markerAttachmentsEmpty =>
      'Pas encore de photos. Ajoutez une image JPEG, PNG ou WebP.';

  @override
  String get markerAttachmentsEmptyReadOnly => 'Aucune photo sur ce marqueur.';

  @override
  String get markerAttachmentAdd => 'Ajouter une photo';

  @override
  String get markerAttachmentUploading => 'Téléversement…';

  @override
  String get markerAttachmentUploadSuccess => 'Photo ajoutée.';

  @override
  String markerAttachmentUploadFailed(String error) {
    return 'Échec du téléversement de la photo : $error';
  }

  @override
  String markerAttachmentLoadFailed(String error) {
    return 'Impossible de charger les photos : $error';
  }

  @override
  String get markerAttachmentDeleteConfirmTitle => 'Supprimer la photo ?';

  @override
  String markerAttachmentDeleteConfirmMessage(String fileName) {
    return 'Retirer « $fileName » de ce marqueur ?';
  }

  @override
  String markerAttachmentDeleteFailed(String error) {
    return 'Impossible de supprimer la photo : $error';
  }

  @override
  String get kioskModeTitle => 'Mode kiosque / visionneuse';

  @override
  String get kioskModeDescription =>
      'Transformez ce portable en visionneuse TOC : masquez Réglages et outils de création, bloquez les modifications et utilisez une interrogation plus douce pour la batterie. À utiliser sur les portables de secours pointés vers votre serveur Wayfinder. Pour un serveur de secours qui doit refuser toutes les écritures, définissez WAYFINDER_READ_ONLY=1 sur le serveur.';

  @override
  String get kioskModeEnter => 'Entrer en mode kiosque';

  @override
  String get kioskModeExit => 'Quitter le kiosque';

  @override
  String get kioskModeEntered =>
      'Mode kiosque activé — cet appareil est en lecture seule.';

  @override
  String get kioskModeEnterConfirmTitle => 'Entrer en mode kiosque ?';

  @override
  String get kioskModeEnterConfirmMessage =>
      'Les réglages et l\'édition de la carte seront masqués sur cet appareil jusqu\'à ce que vous quittiez le mode kiosque. Les autres appareils ne sont pas affectés.';

  @override
  String get kioskModeBannerTitle => 'Mode visionneuse';

  @override
  String get kioskModeBannerHint =>
      'Ce portable est en lecture seule. Vous pouvez déplacer, zoomer, rechercher et inspecter les objets de la carte.';

  @override
  String get kioskModeBannerServerEnforced =>
      'Ce serveur Wayfinder est en lecture seule (WAYFINDER_READ_ONLY). Les écritures sont bloquées pour tous les clients.';

  @override
  String get kioskModeSettingsLockedMessage =>
      'Les réglages sont masqués tant que cet appareil est en mode kiosque / visionneuse.';

  @override
  String get kioskModeBackToMap => 'Retour à la carte';

  @override
  String get fieldPackTitle => 'Pack terrain';

  @override
  String get fieldPackDescription =>
      'Une archive pour un serveur ou un ordinateur portable de secours : objets cartographiques, icônes personnalisées et les régions PMTiles que vous sélectionnez. Proche des packs hors ligne, mais destiné à transférer une instance Wayfinder complète plutôt qu\'à mettre des tuiles en cache sur cet appareil.';

  @override
  String get fieldPackExportButton => 'Exporter le pack terrain';

  @override
  String get fieldPackRestoreButton => 'Restaurer le pack terrain';

  @override
  String get fieldPackSelectPmtilesTitle => 'Inclure les PMTiles';

  @override
  String get fieldPackSelectPmtilesMessage =>
      'Choisissez les archives de tuiles à inclure. Les gros fichiers régionaux peuvent rendre le pack de plusieurs Go.';

  @override
  String get fieldPackSelectPmtilesEmpty =>
      'Aucun PMTiles n\'est installé sur ce serveur. Le pack n\'inclura que les données cartographiques et les icônes.';

  @override
  String get fieldPackSelectAll => 'Tout sélectionner';

  @override
  String get fieldPackSelectNone => 'Ne rien sélectionner';

  @override
  String get fieldPackExportConfirm => 'Exporter';

  @override
  String get fieldPackExportSuccess => 'Pack terrain enregistré.';

  @override
  String fieldPackExportFailed(String error) {
    return 'Échec de l\'exportation du pack terrain : $error';
  }

  @override
  String get fieldPackRestoreConfirmTitle => 'Restaurer le pack terrain ?';

  @override
  String get fieldPackRestoreConfirmMessage =>
      'Cela remplace toutes les données cartographiques et icônes personnalisées sur le serveur, et installe les archives PMTiles du pack (les identifiants correspondants sont écrasés). Cette action est irréversible.';

  @override
  String fieldPackRestoreSuccess(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int commsPlans,
    int icons,
    int pmtiles,
  ) {
    return '$layers couche(s), $markers marqueur(s), $zones zone(s), $seasonalOverlays calque(s) saisonnier(s), $watchLogEntries entrée(s) du journal, $commsPlans plan(s) de communications, $icons icône(s) personnalisée(s) et $pmtiles archive(s) PMTiles restauré(s).';
  }

  @override
  String fieldPackRestoreFailed(String error) {
    return 'Échec de la restauration du pack terrain : $error';
  }

  @override
  String get geoExchangeTitle => 'GPX / KML / GeoJSON';

  @override
  String get geoExchangeDescription =>
      'Importez des waypoints et traces depuis GPX, KML ou GeoJSON. Si la carte a déjà des marqueurs ou zones, vous pouvez les conserver, les remplacer ou annuler. Exportez les marqueurs en waypoints et les lignes/traces en chemins.';

  @override
  String get geoExchangeImportButton => 'Importer un fichier géographique';

  @override
  String get geoExchangeExportButton => 'Exporter un fichier géographique';

  @override
  String get geoExchangeExportFormatTitle => 'Format d\'exportation';

  @override
  String get geoExchangeImportConfirmTitle =>
      'Importer des données géographiques ?';

  @override
  String geoExchangeImportConfirmMessage(int markers, int zones) {
    return 'La carte contient déjà $markers marqueur(s) et $zones zone(s). Choisissez Ajouter pour les conserver et importer en plus, Remplacer pour supprimer tous les marqueurs et zones d\'abord, ou Annuler pour abandonner.';
  }

  @override
  String get geoExchangeImportAdd => 'Ajouter aux existants';

  @override
  String get geoExchangeImportReplace => 'Remplacer les existants';

  @override
  String geoExchangeImportSuccess(int markers, int lines) {
    return '$markers marqueur(s) et $lines ligne(s) importé(s).';
  }

  @override
  String get geoExchangeImportEmpty =>
      'Aucun waypoint ni trace trouvé dans ce fichier.';

  @override
  String geoExchangeImportFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get geoExchangeExportSuccess => 'Export géographique enregistré.';

  @override
  String get geoExchangeExportEmpty =>
      'Rien à exporter — ajoutez d\'abord des marqueurs ou des lignes.';

  @override
  String geoExchangeExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get geoExchangeFormatGpx => 'GPX';

  @override
  String get geoExchangeFormatKml => 'KML';

  @override
  String get geoExchangeFormatGeojson => 'GeoJSON';

  @override
  String get mapAtlasTitle => 'Atlas cartographique imprimable';

  @override
  String get mapAtlasDescription =>
      'Exportez un PDF multipage de la zone actuelle de la carte (ou de tous les marqueurs) avec le fond PMTiles activé, une grille lat/lng, les marqueurs, les zones, une barre d\'échelle et une flèche nord. Les feuilles se chevauchent légèrement pour un usage terrain.';

  @override
  String get mapAtlasExportButton => 'Exporter l\'atlas imprimable (PDF)';

  @override
  String get mapAtlasDialogTitle => 'Exporter l\'atlas imprimable';

  @override
  String get mapAtlasDialogDescription =>
      'Choisissez la couverture, le format de page et le nombre de feuilles. Les feuilles incluent le fond PMTiles activé plus les superpositions. Chaque feuille a une étiquette MGRS approximative de son centre.';

  @override
  String get mapAtlasTitleLabel => 'Titre de l\'atlas';

  @override
  String get mapAtlasCoverageLabel => 'Couverture';

  @override
  String get mapAtlasCoverageMapView => 'Vue carte actuelle';

  @override
  String get mapAtlasCoverageMarkers => 'Ajuster aux marqueurs';

  @override
  String get mapAtlasGridLabel => 'Grille de feuilles';

  @override
  String get mapAtlasPageSizeLabel => 'Format de page';

  @override
  String get mapAtlasPageLetter => 'Letter US paysage';

  @override
  String get mapAtlasPageA4 => 'A4 paysage';

  @override
  String get mapAtlasIncludeMarkerIndex =>
      'Inclure la liste des marqueurs sur chaque feuille';

  @override
  String get mapAtlasIncludeActiveRoute =>
      'Dessiner l\'itinéraire actif sur les feuilles';

  @override
  String get mapAtlasIncludeDirectionsList =>
      'Inclure une page d\'instructions pas à pas';

  @override
  String get mapAtlasCoverageActiveRoute => 'Ajuster à l\'itinéraire actif';

  @override
  String get mapAtlasDirectionsStepColumn => 'Étape';

  @override
  String get mapAtlasDirectionsInstructionColumn => 'Instruction';

  @override
  String get mapAtlasDirectionsDistanceColumn => 'Distance';

  @override
  String get mapAtlasSheetCountHint => 'Feuilles';

  @override
  String get mapAtlasExportSuccess => 'PDF de l\'atlas imprimable enregistré.';

  @override
  String mapAtlasExportFailed(String error) {
    return 'Échec de l\'export de l\'atlas : $error';
  }

  @override
  String get mapAtlasExportNoCoverage =>
      'Impossible de déterminer la couverture de l\'atlas. Ouvrez d\'abord la carte, ou ajoutez des marqueurs visibles et choisissez Ajuster aux marqueurs.';

  @override
  String get mapTilesFolderTitle => 'Dossier PMTiles';

  @override
  String get mapTilesFolderDescription =>
      'Dossier sur le serveur contenant les archives .pmtiles. Enregistré dans la base de données pour que chaque client utilise la même bibliothèque de tuiles après redémarrage.';

  @override
  String get mapTilesStoragePathLabel => 'Chemin de stockage PMTiles';

  @override
  String get mapTilesStoragePathRequired =>
      'Le chemin de stockage PMTiles est requis.';

  @override
  String get mapTilesSaveAndRescan => 'Enregistrer et rescanner le dossier';

  @override
  String mapTilesFolderSaved(String path) {
    return 'Dossier PMTiles enregistré. Resynchronisé depuis $path.';
  }

  @override
  String mapTilesFolderSaveFailed(String error) {
    return 'Échec de l\'enregistrement du dossier PMTiles : $error';
  }

  @override
  String get mapTilesMapsTitle => 'Cartes PMTiles';

  @override
  String get mapTilesMapsDescription =>
      'Organisez les archives cartographiques hors ligne en groupes et choisissez lesquelles sont affichées sur la carte. Les packs DEM d\'élévation (nom contenant dem, terrarium, terrain-rgb ou elevation) servent à la hauteur ponctuelle et aux profils — activez-les ici, mais ils ne sont pas dessinés comme fond de carte.';

  @override
  String get mapTilesPermissionDenied =>
      'Vous n\'avez pas l\'autorisation d\'ajouter, de mettre à jour ou d\'organiser les tuiles cartographiques.';

  @override
  String get mapTilesDemBadge => 'DEM d\'élévation';

  @override
  String get mapTilesUploadButton => 'Téléverser un fichier .pmtiles';

  @override
  String get mapTilesGetMapsButton => 'Obtenir des cartes';

  @override
  String get offlinePackPrepareTitle => 'Préparer pour le hors ligne';

  @override
  String get offlinePackPrepareDescription =>
      'Mettez en miroir les calques choisis et mettez en cache les tuiles du fond de carte pour la vue actuelle. Conservez plusieurs packs AOI (maison, repli, chasse) et activez-en un sans reconstruire.';

  @override
  String get offlinePackPrepareAction => 'Mettre à jour le pack hors ligne';

  @override
  String get offlinePackPrepareNewAction => 'Créer un pack hors ligne';

  @override
  String get offlinePackPrepareTooltip => 'Préparer pour le hors ligne';

  @override
  String get offlinePackPrepareTooltipReady =>
      'Packs prêts — appuyez pour gérer';

  @override
  String get offlinePackNameLabel => 'Nom du pack';

  @override
  String get offlinePackNameHint => 'Maison, repli, chasse…';

  @override
  String get offlinePackDefaultName => 'Pack hors ligne';

  @override
  String get offlinePackTargetLabel => 'Enregistrer comme';

  @override
  String get offlinePackTargetNew => 'Nouveau pack (conserver les existants)';

  @override
  String offlinePackTargetReplace(String name) {
    return 'Remplacer « $name »';
  }

  @override
  String get offlinePackSavedPacksLabel => 'Packs enregistrés';

  @override
  String get offlinePackActiveLabel => 'Actif';

  @override
  String get offlinePackInactiveLabel =>
      'Appuyez sur Activer pour changer sans reconstruire';

  @override
  String get offlinePackActivateAction => 'Activer';

  @override
  String get offlinePackRenameTitle => 'Renommer le pack hors ligne';

  @override
  String get offlinePackNameDuplicate =>
      'Un pack portant ce nom existe déjà. Choisissez un autre nom.';

  @override
  String offlinePackDetailsLayers(String layers) {
    return 'Calques : $layers';
  }

  @override
  String get offlinePackDetailsLayersEmpty => 'Calques : (aucun enregistré)';

  @override
  String offlinePackDetailsCounts(
    int markerCount,
    int zoneCount,
    int tileCount,
    int seasonalCount,
  ) {
    return '$markerCount marqueurs · $zoneCount zones · $tileCount tuiles · $seasonalCount superpositions saisonnières';
  }

  @override
  String offlinePackDetailsPrepared(String when) {
    return 'Préparé $when';
  }

  @override
  String get offlinePackSwitchTooltip => 'Changer de pack hors ligne';

  @override
  String get offlinePackSwitchTitle => 'Changer de pack hors ligne';

  @override
  String get offlinePackSwitchDescription =>
      'Choisissez le pack AOI à utiliser. Les tuiles restent en cache — aucune reconstruction nécessaire.';

  @override
  String get offlinePackLayersLabel => 'Calques à inclure';

  @override
  String get offlinePackIncludeSeasonalOverlays =>
      'Inclure les superpositions saisonnières';

  @override
  String get offlinePackIncludeSeasonalOverlaysHint =>
      'Inclure toutes les superpositions saisonnières en lecture seule hors ligne (séparées des calques de carte).';

  @override
  String get offlinePackIncludePackedRoutes =>
      'Inclure les itinéraires OSM vers les marqueurs du pack';

  @override
  String offlinePackIncludePackedRoutesHint(int maxRoutes) {
    return 'Utilise le serveur de routage maintenant pour précalculer les trajets à pied/vélo/voiture depuis l’origine choisie vers chaque marqueur du pack (jusqu’à $maxRoutes). Ces itinéraires fonctionnent hors ligne.';
  }

  @override
  String get offlinePackRouteOriginLabel => 'Origine de l’itinéraire';

  @override
  String get offlinePackRouteOriginGps => 'Position GPS actuelle';

  @override
  String get offlinePackRouteOriginMapCenter => 'Centre actuel de la carte';

  @override
  String get offlinePackRouteOriginGpsUnavailable =>
      'Pas encore de GPS — activez la localisation ou choisissez le centre de la carte.';

  @override
  String get offlinePackRoutingNotReady =>
      'Activez un serveur de routage prêt (Réglages → Routage) avant d’empaqueter des itinéraires OSM.';

  @override
  String offlinePackDetailsRoutes(int routeCount) {
    return '$routeCount itinéraire(s) OSM empaqueté(s)';
  }

  @override
  String get offlinePackRouteMissing =>
      'Aucun itinéraire OSM empaqueté pour ce marqueur. Repréparez le pack avec « Inclure les itinéraires OSM » pendant que le serveur de routage est prêt.';

  @override
  String offlinePackRouteLoaded(
    String profile,
    String distance,
    String duration,
  ) {
    return 'Itinéraire OSM empaqueté chargé ($profile) : $distance, $duration';
  }

  @override
  String get offlinePackSeasonalOverlaysNotIncluded =>
      'Aucune superposition saisonnière dans ce pack. Repréparez-le avec « Inclure les superpositions saisonnières » en ligne.';

  @override
  String get offlinePackNoLayers => 'Aucun calque de carte disponible.';

  @override
  String get offlinePackSelectLayersRequired =>
      'Sélectionnez au moins un calque.';

  @override
  String offlinePackZoomLabel(int minZoom, int maxZoom) {
    return 'Détail des tuiles (z$minZoom–z$maxZoom)';
  }

  @override
  String get offlinePackZoomRangeInvalid =>
      'Le zoom min doit être inférieur ou égal au zoom max.';

  @override
  String offlinePackEstimate(int tileCount, int archiveCount) {
    return 'Environ $tileCount tuiles sur $archiveCount fond(s) de carte activé(s). Les grandes zones peuvent prendre plusieurs minutes et utiliser beaucoup de stockage sur le web.';
  }

  @override
  String offlinePackExistingSummary(
    String name,
    int tileCount,
    int markerCount,
  ) {
    return 'Pack actuel « $name » : $tileCount tuiles, $markerCount marqueurs.';
  }

  @override
  String get offlinePackPreparing => 'Préparation du pack hors ligne…';

  @override
  String get offlinePackClear => 'Effacer le pack';

  @override
  String offlinePackSynced(int count) {
    return '$count modification(s) hors ligne synchronisée(s) avec le serveur.';
  }

  @override
  String offlineModeBannerTitle(String packName) {
    return 'Hors ligne — $packName';
  }

  @override
  String get offlineModeBannerReadWriteHint =>
      'Affichage des calques du pack. Vous pouvez ajouter des marqueurs, changer leur calque, supprimer les marqueurs non synchronisés, enregistrer des traces GPS et ajouter des entrées du journal de veille.';

  @override
  String get offlineModeBannerForcedHint =>
      'Pack hors ligne forcé (serveur toujours joignable). Désactivez dans Paramètres → Général → Débogage de la carte une fois les tests terminés.';

  @override
  String get offlineDeleteUnsyncedMarker =>
      'Supprimer le marqueur non synchronisé';

  @override
  String get offlineDeleteSyncedMarkerDisabled =>
      'Seuls les marqueurs hors ligne non synchronisés peuvent être supprimés tant que le serveur est absent';

  @override
  String get offlineGeocodingUnavailable =>
      'Les contributions de géocodage sont indisponibles hors ligne.';

  @override
  String offlineModeBannerPending(int count) {
    return '$count modification(s) en attente de synchronisation.';
  }

  @override
  String get mapTilesGetMapsTitle => 'Obtenir des cartes';

  @override
  String get mapTilesGetMapsDescription =>
      'Téléchargez des basemaps Protomaps régionaux depuis Project NOMAD, ou un DEM Terrarium depuis Mapterhorn. Le serveur Wayfinder télécharge ou extrait le fichier — gardez cette boîte de dialogue ouverte jusqu\'à la fin.';

  @override
  String get mapTilesGetMapsBasemapDescription =>
      'Basemaps vectoriels par État américain (Project NOMAD, quelques centaines de Mo). Cherchez votre État puis Importer — le serveur le télécharge dans le stockage des tuiles.';

  @override
  String get mapTilesGetMapsDemDescription =>
      'DEM Terrarium par État américain (Mapterhorn). Extraire lance un découpage régional sur le serveur Wayfinder — gardez la boîte ouverte (les grands États peuvent prendre plusieurs minutes). Préférez un État à l\'option planète en bas de liste.';

  @override
  String get mapTilesGetMapsSearchHint => 'Rechercher un État…';

  @override
  String get mapTilesGetMapsImportAction => 'Importer';

  @override
  String get mapTilesGetMapsExtractAction => 'Extraire';

  @override
  String mapTilesGetMapsImporting(String title) {
    return 'Importation de $title…';
  }

  @override
  String mapTilesGetMapsExtracting(String title) {
    return 'Extraction de $title sur le serveur…';
  }

  @override
  String mapTilesGetMapsImported(String title) {
    return '$title importé.';
  }

  @override
  String mapTilesGetMapsCatalogFailed(String error) {
    return 'Impossible de charger le catalogue : $error';
  }

  @override
  String get mapTilesGetMapsEmpty =>
      'Aucun paquet ne correspond à votre recherche.';

  @override
  String get mapTilesGetMapsSizeUnknown => 'taille inconnue';

  @override
  String get mapTilesGetMapsSizeRegional => 'extrait régional';

  @override
  String get mapTilesGetMapsBasemapBadge => 'Fond de carte';

  @override
  String mapTilesUploadProgress(String sent, String total) {
    return 'Téléversement $sent / $total';
  }

  @override
  String get mapTilesUploadProgressHint =>
      'Les grandes archives sont téléversées par morceaux afin que les journaux serveur montrent la progression. Gardez cet onglet ouvert jusqu’à la fin.';

  @override
  String get elevationDemLabel => 'Élévation DEM';

  @override
  String get elevationDemUnavailable => 'Pas de couverture DEM';

  @override
  String get elevationNoDemAvailable =>
      'Aucun DEM d\'élévation n\'est activé. Téléversez un .pmtiles Terrarium ou Terrain-RGB nommé avec dem/terrarium/elevation et activez-le sous Tuiles cartographiques.';

  @override
  String get elevationProfileTitle => 'Profil d\'élévation';

  @override
  String get elevationProfileButton => 'Profil d\'élévation';

  @override
  String get routeFollowButton => 'Suivre l\'itinéraire';

  @override
  String get routeFollowPrimaryButton => 'Suivre l\'itinéraire principal';

  @override
  String get routeFollowStop => 'Arrêter le suivi';

  @override
  String get routeFollowSimulate => 'Simuler la marche sur l\'itinéraire';

  @override
  String get routeFollowStopSimulate => 'Arrêter la simulation';

  @override
  String routeFollowStarted(String name) {
    return 'Suivi de « $name ». Restez près du tracé.';
  }

  @override
  String get routeFollowGpsRequired =>
      'Impossible de démarrer le GPS. Activez la localisation et réessayez.';

  @override
  String routeFollowActive(String name) {
    return 'Suivi de $name';
  }

  @override
  String routeFollowOffRoute(String distance) {
    return 'Hors parcours · $distance';
  }

  @override
  String get routeFollowCompleted => 'Itinéraire terminé';

  @override
  String routeFollowRemaining(String distance) {
    return '$distance restants';
  }

  @override
  String routeFollowEta(String eta) {
    return 'ETA $eta';
  }

  @override
  String routeFollowTurnLeftIn(String distance) {
    return 'Dans $distance, tournez à gauche';
  }

  @override
  String routeFollowTurnRightIn(String distance) {
    return 'Dans $distance, tournez à droite';
  }

  @override
  String routeFollowTurnPortIn(String distance, int degrees) {
    return 'Dans $distance, tournez de $degrees° à bâbord';
  }

  @override
  String routeFollowTurnStarboardIn(String distance, int degrees) {
    return 'Dans $distance, tournez de $degrees° à tribord';
  }

  @override
  String get routeFollowNauticalModeEnable =>
      'Indications nautiques (bâbord / tribord)';

  @override
  String get routeFollowNauticalModeDisable =>
      'Indications standard (gauche / droite)';

  @override
  String routeFollowContinueFor(String distance) {
    return 'Continuez $distance';
  }

  @override
  String routeFollowArriveIn(String distance) {
    return 'Arrivée dans $distance';
  }

  @override
  String get elevationProfileEmpty =>
      'Impossible d\'échantillonner les élévations le long de ce parcours.';

  @override
  String elevationProfileFailed(String error) {
    return 'Impossible de créer le profil d\'élévation : $error';
  }

  @override
  String get elevationProfileFlatHint =>
      'Peu de dénivelé sur ce parcours — le graphique peut paraître presque plat.';

  @override
  String elevationProfileCombinedLegs(int count) {
    return 'Combiné à partir de $count segments (ordre de sélection ; chaque segment peut être inversé pour se connecter).';
  }

  @override
  String elevationProfileSelectionCount(int count) {
    return '$count parcours sélectionnés pour le profil d\'élévation';
  }

  @override
  String get elevationProfileClearSelection => 'Effacer';

  @override
  String get elevationProfileMin => 'Min';

  @override
  String get elevationProfileMax => 'Max';

  @override
  String get elevationProfileGain => 'Dénivelé +';

  @override
  String get elevationProfileLoss => 'Dénivelé −';

  @override
  String elevationClimbToMarker(String name, String delta) {
    return 'Montée vers $name : $delta';
  }

  @override
  String mapTilesUploadSuccess(String name) {
    return 'Fichier PMTiles téléversé : $name';
  }

  @override
  String mapTilesUploadFailed(String error) {
    return 'Échec du téléversement : $error';
  }

  @override
  String get mapTilesAllHidden =>
      'Toutes les tuiles cartographiques sont masquées sur la carte.';

  @override
  String get mapTilesNewGroupTitle => 'Nouveau groupe de tuiles';

  @override
  String get mapTilesGroupNameLabel => 'Nom du groupe';

  @override
  String get mapTilesGroupNameHint => 'p. ex. États du Mid-Atlantic';

  @override
  String mapTilesGroupCreated(String name) {
    return 'Groupe « $name » créé.';
  }

  @override
  String mapTilesGroupCreateFailed(String error) {
    return 'Impossible de créer le groupe : $error';
  }

  @override
  String get mapTilesDeleteGroupTitle => 'Supprimer le groupe de tuiles ?';

  @override
  String mapTilesDeleteGroupMessage(String name) {
    return 'Supprimer « $name » ? Les fichiers de ce groupe deviendront non groupés.';
  }

  @override
  String get mapTilesDeleteFileTitle => 'Supprimer le fichier PMTiles ?';

  @override
  String mapTilesDeleteFileMessage(String name) {
    return 'Retirer « $name » du serveur ?';
  }

  @override
  String get mapTilesFileDeleted => 'Fichier PMTiles supprimé.';

  @override
  String get mapTilesDownloadTooltip => 'Télécharger l’archive';

  @override
  String mapTilesDownloadStarted(String name) {
    return 'Téléchargement de « $name »…';
  }

  @override
  String mapTilesDownloadSaved(String name) {
    return '« $name » enregistré.';
  }

  @override
  String mapTilesDownloadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String mapTilesFilesLoadFailed(String error) {
    return 'Échec du chargement des fichiers : $error';
  }

  @override
  String mapTilesGroupsLoadFailed(String error) {
    return 'Échec du chargement des groupes : $error';
  }

  @override
  String get mapTilesNoFiles =>
      'Aucun fichier PMTiles téléversé pour l\'instant.';

  @override
  String mapTilesShownOnMapCount(int shown, int total) {
    return '$shown sur $total affiché(s) sur la carte';
  }

  @override
  String get mapTilesUngrouped => 'Non groupé';

  @override
  String get mapTilesNoFilesAssigned => 'Aucun fichier assigné';

  @override
  String get mapTilesShowUngroupedOnMap =>
      'Afficher les non groupés sur la carte';

  @override
  String get mapTilesShowGroupOnMap => 'Afficher le groupe sur la carte';

  @override
  String get mapTilesDeleteGroupTooltip => 'Supprimer le groupe';

  @override
  String get mapTilesUngroupedEmptyMessage =>
      'Les fichiers non assignés à un groupe apparaissent ici.';

  @override
  String get mapTilesGroupEmptyMessage =>
      'Assignez des fichiers à ce groupe depuis le menu de chaque tuile.';

  @override
  String get mapTilesNoGroups => 'Aucun groupe';

  @override
  String mapTilesGroupCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '1 groupe',
    );
    return '$_temp0';
  }

  @override
  String get mapTilesManageGroupsTooltip => 'Gérer les groupes';

  @override
  String get mapTilesNewGroup => 'Nouveau groupe';

  @override
  String get mapTilesShowAllOnMap => 'Tout afficher sur la carte';

  @override
  String get mapTilesHideAllFromMap => 'Tout masquer sur la carte';

  @override
  String get markerIconsTitle => 'Icônes de marqueurs';

  @override
  String get markerIconsDescription =>
      'Téléversez des icônes SVG de marqueurs sur le serveur. Les clients les chargent à l\'exécution pour ajouter ou mettre à jour des icônes sans redéployer l\'application. L\'authentification REST peut être requise — configurez une clé dans Paramètres → À propos.';

  @override
  String get markerIconsPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de gérer les catégories d\'icônes ni les icônes de marqueurs personnalisées.';

  @override
  String get markerIconsAddButton => 'Ajouter une icône personnalisée';

  @override
  String get markerIconsServerCatalogTitle => 'Catalogue serveur';

  @override
  String get markerIconsNoServerEntries =>
      'Aucune icône gérée par le serveur pour l\'instant. Ajoutez une icône personnalisée ou téléversez un SVG pour remplacer une icône intégrée ci-dessous.';

  @override
  String markerIconsLoadFailed(String error) {
    return 'Échec du chargement des icônes : $error';
  }

  @override
  String markerIconsEntryCustomSvg(String key) {
    return '$key • SVG personnalisé';
  }

  @override
  String markerIconsEntryMaterialFallback(String key) {
    return '$key • icône Material de secours';
  }

  @override
  String get markerIconsUploadSvgAction => 'Téléverser SVG';

  @override
  String get markerIconsEditAction => 'Modifier les métadonnées';

  @override
  String get markerIconsBuiltInTitle => 'Remplacer les icônes intégrées';

  @override
  String get markerIconsBuiltInDescription =>
      'Téléversez un SVG pour une clé intégrée afin de remplacer le fichier embarqué sur tous les clients connectés.';

  @override
  String get markerIconsBuiltInExpandTitle => 'Icônes SVG intégrées';

  @override
  String markerIconsBuiltInExpandSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count icônes',
      one: '1 icône',
    );
    return '$_temp0';
  }

  @override
  String markerIconsUploadSuccess(String key) {
    return 'SVG téléversé pour $key';
  }

  @override
  String markerIconsUploadFailed(String error) {
    return 'Échec du téléversement SVG : $error';
  }

  @override
  String get markerIconsCreateTitle => 'Ajouter une icône de marqueur';

  @override
  String markerIconsCreateSuccess(String label) {
    return 'Icône ajoutée : $label';
  }

  @override
  String markerIconsCreateFailed(String error) {
    return 'Impossible d\'ajouter l\'icône : $error';
  }

  @override
  String markerIconsUpdateSuccess(String label) {
    return 'Icône mise à jour : $label';
  }

  @override
  String markerIconsUpdateFailed(String error) {
    return 'Impossible de mettre à jour l\'icône : $error';
  }

  @override
  String get markerIconsDeleteTitle => 'Supprimer l\'icône de marqueur ?';

  @override
  String markerIconsDeleteMessage(String label, String key) {
    return 'Supprimer « $label » ($key) du serveur ? Les clients reviendront à l\'icône intégrée si elle existe.';
  }

  @override
  String get markerIconsDeleteSuccess => 'Icône supprimée.';

  @override
  String markerIconsDeleteFailed(String error) {
    return 'Impossible de supprimer l\'icône : $error';
  }

  @override
  String get markerIconsKeyLabel => 'Clé de l\'icône';

  @override
  String get markerIconsKeyHint => 'custom_drone';

  @override
  String get markerIconsKeyRequired => 'La clé de l\'icône est obligatoire.';

  @override
  String get markerIconsKeyInvalid =>
      'Utilisez des lettres minuscules, des chiffres et des traits de soulignement (max. 64).';

  @override
  String get markerIconsLabelField => 'Libellé affiché';

  @override
  String get markerIconsLabelRequired => 'Le libellé affiché est obligatoire.';

  @override
  String get markerIconsColoredAssetLabel => 'Conserver les couleurs du SVG';

  @override
  String get markerIconsColoredAssetHelp =>
      'Conserver les couleurs d\'origine au lieu de teinter avec la couleur du marqueur.';

  @override
  String markerIconsGlyphScaleLabel(String value) {
    return 'Échelle de l\'icône : $value';
  }

  @override
  String get markerIconsPickSvgOptional => 'Choisir un SVG (facultatif)';

  @override
  String markerIconsPickSvgSelected(String name) {
    return 'SVG : $name';
  }

  @override
  String get markerIconsEditTitle => 'Modifier l\'icône de marqueur';

  @override
  String get markerIconsCategoryLabel => 'Catégorie';

  @override
  String get markerIconBackgroundColorTitle => 'Arrière-plan de l\'icône';

  @override
  String get markerIconBackgroundColorDescription =>
      'Choisissez la couleur de remplissage derrière les icônes de marqueur sur la carte. Les SVG transparents s\'affichent sur cet arrière-plan — ajustez-le pour un meilleur contraste avec vos fonds de carte.';

  @override
  String get markerIconBackgroundColorLabel => 'Couleur d\'arrière-plan';

  @override
  String get markerIconCategoryGeneral => 'Général';

  @override
  String get markerIconCategoryPlaces => 'Lieux et bâtiments';

  @override
  String get markerIconCategoryTransportation => 'Transport';

  @override
  String get markerIconCategoryPeopleAnimals => 'Personnes et animaux';

  @override
  String get markerIconCategoryInfrastructure => 'Infrastructure';

  @override
  String get markerIconCategoryMilitary => 'Militaire et défense';

  @override
  String get markerIconCategoryEmergency => 'Urgence et médical';

  @override
  String get markerIconCategorySanitation => 'Assainissement et hygiène';

  @override
  String get markerIconCategoryNaturalDisasters =>
      'Météo et catastrophes naturelles';

  @override
  String get markerIconCategoryShelterPreparedness => 'Abri et préparation';

  @override
  String get markerIconCategoryRecreation => 'Chasse et cueillette';

  @override
  String get markerIconCategoryAgriculture => 'Agriculture';

  @override
  String get markerIconCategoryCustom => 'Personnalisé';

  @override
  String get markerIconCategoriesTitle => 'Catégories d\'icônes';

  @override
  String get markerIconCategoriesDescription =>
      'Organisez les icônes de marqueurs en catégories. Les catégories apparaissent dans le sélecteur d\'icônes et les listes des paramètres. La suppression d\'une catégorie déplace ses icônes vers Personnalisé.';

  @override
  String markerIconCategoriesExpandSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catégories',
      one: '1 catégorie',
    );
    return '$_temp0';
  }

  @override
  String get markerIconCategoriesAddButton => 'Ajouter une catégorie';

  @override
  String get markerIconCategoriesCreateTitle => 'Ajouter une catégorie';

  @override
  String get markerIconCategoriesEditTitle => 'Modifier la catégorie';

  @override
  String get markerIconCategoriesKeyLabel => 'Clé de catégorie';

  @override
  String get markerIconCategoriesKeyHint => 'ma_categorie';

  @override
  String get markerIconCategoriesKeyRequired =>
      'La clé de catégorie est obligatoire.';

  @override
  String get markerIconCategoriesKeyInvalid =>
      'Utilisez des lettres minuscules, des chiffres et des traits de soulignement (64 max.).';

  @override
  String get markerIconCategoriesLabelField => 'Libellé affiché';

  @override
  String get markerIconCategoriesLabelRequired =>
      'Le libellé affiché est obligatoire.';

  @override
  String markerIconCategoriesCreateSuccess(String label) {
    return 'Catégorie ajoutée : $label';
  }

  @override
  String markerIconCategoriesUpdateSuccess(String label) {
    return 'Catégorie mise à jour : $label';
  }

  @override
  String get markerIconCategoriesDeleteTitle => 'Supprimer la catégorie ?';

  @override
  String markerIconCategoriesDeleteMessage(String label, String key) {
    return 'Supprimer « $label » ($key) ? Les icônes de cette catégorie seront déplacées vers Personnalisé.';
  }

  @override
  String get markerIconCategoriesDeleteSuccess => 'Catégorie supprimée.';

  @override
  String markerIconCategoriesCreateFailed(String error) {
    return 'Impossible d\'ajouter la catégorie : $error';
  }

  @override
  String markerIconCategoriesUpdateFailed(String error) {
    return 'Impossible de mettre à jour la catégorie : $error';
  }

  @override
  String markerIconCategoriesDeleteFailed(String error) {
    return 'Impossible de supprimer la catégorie : $error';
  }

  @override
  String get markerIconCategoriesProtectedHint =>
      'Catégorie de secours intégrée (ne peut pas être supprimée)';

  @override
  String get layerLabel => 'Couche';

  @override
  String get layerUnassigned => 'Non assigné';

  @override
  String get layerUnknown => 'Couche inconnue';

  @override
  String get formNameLabel => 'Nom';

  @override
  String get formColorLabel => 'Couleur';

  @override
  String get formNotesLabel => 'Notes';

  @override
  String get formNotesPlaceholder =>
      'Ajouter des notes (enregistrées en Markdown)...';

  @override
  String get formPreviewLabel => 'Aperçu';

  @override
  String get formShowNameOnMap => 'Afficher le nom sur la carte';

  @override
  String get formBorderColorLabel => 'Couleur de bordure';

  @override
  String get formFillColorLabel => 'Couleur de remplissage';

  @override
  String get formUnitLabel => 'Unité';

  @override
  String get formFillOpacityHelp =>
      'Ajustez l\'opacité pour contrôler la transparence du remplissage.';

  @override
  String get coordinatesTitle => 'Coordonnées';

  @override
  String get markerCreateTitle => 'Créer un marqueur';

  @override
  String get markerEditTitle => 'Modifier le marqueur';

  @override
  String get markerDefaultName => 'Nouveau marqueur';

  @override
  String get markerCoordinatesHelp =>
      'Modifiez la latitude et la longitude pour déplacer le marqueur sur la carte.';

  @override
  String get markerRadioTitle => 'Réseau radio / fiche contact';

  @override
  String get markerRadioEmptyHelp =>
      'Indicatif, fréquence et mode optionnels pour shack / relais (pas de radio en direct).';

  @override
  String get markerRadioStructuredHint =>
      'Données structurées uniquement — Wayfinder n\'émet ni ne règle les radios.';

  @override
  String markerRadioSummary(String callsign) {
    return '$callsign';
  }

  @override
  String get markerRadioNoCallsign => 'Fiche contact';

  @override
  String get markerRadioCallsignLabel => 'Indicatif';

  @override
  String get markerRadioRoleLabel => 'Rôle';

  @override
  String get markerRadioRoleShack => 'Ham shack';

  @override
  String get markerRadioRoleRepeater => 'Relais';

  @override
  String get markerRadioRoleStation => 'Station';

  @override
  String get markerRadioRoleNet => 'Réseau';

  @override
  String get markerRadioRoleOther => 'Autre';

  @override
  String get markerRadioNetNameLabel => 'Réseau / groupe';

  @override
  String get markerRadioNetNameHint => 'ex. ARES du comté';

  @override
  String get markerRadioFrequencyLabel => 'Fréquence';

  @override
  String get markerRadioModeLabel => 'Mode';

  @override
  String get markerRadioModeFm => 'FM';

  @override
  String get markerRadioModeAm => 'AM';

  @override
  String get markerRadioModeSsb => 'SSB';

  @override
  String get markerRadioModeCw => 'CW';

  @override
  String get markerRadioModeDigi => 'Numérique';

  @override
  String get markerRadioModeDmr => 'DMR';

  @override
  String get markerRadioModeOther => 'Autre';

  @override
  String get markerRadioToneLabel => 'Tonalité / CTCSS';

  @override
  String get markerRadioOffsetLabel => 'Décalage';

  @override
  String get markerRadioNotesLabel => 'Notes radio';

  @override
  String get markerRadioNotesHint =>
      'Heure de net, couverture, tip PL — notes brèves';

  @override
  String get markerRadioClear => 'Effacer la fiche contact';

  @override
  String get sidebarFilterRadioContacts => 'Contacts radio';

  @override
  String get sidebarFilterResourceSpring => 'Sources';

  @override
  String get sidebarFilterResourceWell => 'Puits';

  @override
  String get sidebarFilterResourceCache => 'Caches';

  @override
  String get sidebarFilterResourceFuel => 'Carburant';

  @override
  String get sidebarFilterResourceClinic => 'Cliniques';

  @override
  String get markerInventoryTitle => 'Inventaire de cache';

  @override
  String get markerInventoryEmptyHelp =>
      'Suivez les provisions de ce marqueur — quantité, unité, expiration et dernier inventaire.';

  @override
  String markerInventoryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get markerInventoryAddItem => 'Ajouter un article';

  @override
  String get markerInventoryRemoveItem => 'Supprimer l’article';

  @override
  String get markerInventoryItemHeading => 'Article d’inventaire';

  @override
  String get markerInventoryNameLabel => 'Nom de l’article';

  @override
  String get markerInventoryQuantityLabel => 'Quantité';

  @override
  String get markerInventoryUnitLabel => 'Unité';

  @override
  String get markerInventoryCategoryLabel => 'Catégorie';

  @override
  String get markerInventoryCategoryFood => 'Nourriture';

  @override
  String get markerInventoryCategoryWater => 'Eau';

  @override
  String get markerInventoryCategoryMedical => 'Médical';

  @override
  String get markerInventoryCategoryAmmo => 'Munitions';

  @override
  String get markerInventoryCategoryOther => 'Autre';

  @override
  String get markerInventoryExpiryLabel => 'Date d’expiration';

  @override
  String get markerInventorySetExpiry => 'Définir l’expiration';

  @override
  String markerInventoryExpiryValue(String date) {
    return 'Expire le $date';
  }

  @override
  String get markerInventoryClearExpiry => 'Effacer l’expiration';

  @override
  String get markerInventoryLastAuditedLabel => 'Dernier inventaire';

  @override
  String get markerInventorySetLastAudited => 'Définir le dernier inventaire';

  @override
  String markerInventoryLastAuditedValue(String date) {
    return 'Inventorié le $date';
  }

  @override
  String get markerInventoryMarkAuditedNow => 'Marquer inventorié maintenant';

  @override
  String markerInventoryDetailQuantity(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String markerInventoryDetailCategory(String category) {
    return 'Catégorie : $category';
  }

  @override
  String get markerInventoryDetailNoExpiry => 'Pas de date d’expiration';

  @override
  String markerInventoryDetailExpiry(String date) {
    return 'Expire le $date';
  }

  @override
  String get markerInventoryDetailNeverAudited => 'Jamais inventorié';

  @override
  String markerInventoryDetailLastAudited(String date) {
    return 'Dernier inventaire le $date';
  }

  @override
  String get markerChecklistsTitle => 'Listes de contrôle / SOP';

  @override
  String get markerChecklistsEmptyHelp =>
      'SOP et audits du lieu — p. ex. vérification du sac d\'évacuation au refuge.';

  @override
  String markerChecklistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listes',
      one: '1 liste',
    );
    return '$_temp0';
  }

  @override
  String get markerChecklistsAddChecklist => 'Ajouter une liste';

  @override
  String get markerChecklistsRemoveChecklist => 'Supprimer la liste';

  @override
  String get markerChecklistsChecklistHeading => 'Liste de contrôle';

  @override
  String get markerChecklistsNameLabel => 'Nom de la liste';

  @override
  String get markerChecklistsNotesLabel => 'Notes';

  @override
  String get markerChecklistsLastAuditedNever => 'Jamais audité';

  @override
  String markerChecklistsLastAudited(String date) {
    return 'Dernier audit le $date';
  }

  @override
  String get markerChecklistsMarkAudited => 'Marquer audité maintenant';

  @override
  String get markerChecklistsAddItem => 'Ajouter un élément';

  @override
  String get markerChecklistsRemoveItem => 'Supprimer l\'élément';

  @override
  String get markerChecklistsItemLabel => 'Élément';

  @override
  String get markerChecklistsItemNotesLabel => 'Notes de l\'élément';

  @override
  String markerChecklistsProgress(int done, int total) {
    return '$done sur $total faits';
  }

  @override
  String get markerTrackingLabel => 'Marqueur de suivi';

  @override
  String get markerTrackingHelp =>
      'Enregistrez l\'historique des déplacements sous forme de trace sur la carte.';

  @override
  String get markerTrackingStatusActive => 'Actif';

  @override
  String get markerTrackingStatusRecordingGps => 'Enregistrement GPS';

  @override
  String get markerTrackingStartGpsTrail => 'Enregistrer la trace avec le GPS';

  @override
  String get markerTrackingStopGpsTrail => 'Arrêter la trace GPS';

  @override
  String get markerTrackingGpsTrailHelp =>
      'Optionnel : associez le GPS de cet appareil à ce marqueur uniquement. Fonctionne en ligne ou avec un pack hors ligne. Les autres marqueurs de suivi (APRS, REST, etc.) ne sont pas affectés.';

  @override
  String get markerTrackingGpsTrailOffer =>
      'Enregistrer le GPS de cet appareil dans la trace de ce marqueur ? Fonctionne hors ligne avec un pack.';

  @override
  String get trackCreateEvacKitButton =>
      'Créer un kit d\'évacuation depuis la trace';

  @override
  String mapDeviceLocationRecordingTrail(String name) {
    return 'Enregistrement de la trace : $name';
  }

  @override
  String get weatherStationCurrentConditions => 'Conditions actuelles';

  @override
  String get weatherDisplayUnitsLabel => 'Unités';

  @override
  String get weatherNoData =>
      'Aucune lecture météo pour l\'instant. Les données sont stockées sur le serveur lorsqu\'elles arrivent via APRS ou d\'autres intégrations locales.';

  @override
  String get weatherFeelsLike => 'Ressenti';

  @override
  String get weatherHumidity => 'Humidité';

  @override
  String get weatherWind => 'Vent';

  @override
  String get weatherPrecipitation => 'Précipitations';

  @override
  String get weatherPressure => 'Pression';

  @override
  String get weatherDewPoint => 'Point de rosée';

  @override
  String get weatherLuminosity => 'Luminosité';

  @override
  String get weatherSolarRadiation => 'Rayonnement solaire';

  @override
  String get weatherUvIndex => 'Indice UV';

  @override
  String get weatherSnowfall => 'Chute de neige';

  @override
  String get weatherWaterLevel => 'Niveau d\'eau';

  @override
  String get weatherSoilTemperature => 'Température du sol';

  @override
  String get weatherSoilMoisture => 'Humidité du sol';

  @override
  String get weatherLeafWetness => 'Humidité foliaire';

  @override
  String get weatherIndoorTemperature => 'Température intérieure';

  @override
  String get weatherIndoorHumidity => 'Humidité intérieure';

  @override
  String get weatherBatteryVoltage => 'Tension batterie';

  @override
  String get weatherWindRun => 'Course du vent';

  @override
  String get weatherStationStatus => 'État de la station';

  @override
  String get weatherSensorHealth => 'État des capteurs';

  @override
  String get weatherHistoryTitle => 'Lectures récentes';

  @override
  String weatherSource(String source) {
    return 'Source : $source';
  }

  @override
  String weatherUpdatedAt(String time) {
    return 'Mis à jour $time';
  }

  @override
  String get weatherConditionClear => 'Dégagé';

  @override
  String get weatherConditionPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherConditionOvercast => 'Couvert';

  @override
  String get weatherConditionFog => 'Brouillard';

  @override
  String get weatherConditionDrizzle => 'Bruine';

  @override
  String get weatherConditionRain => 'Pluie';

  @override
  String get weatherConditionSnow => 'Neige';

  @override
  String get weatherConditionShowers => 'Averses';

  @override
  String get weatherConditionThunderstorm => 'Orage';

  @override
  String get weatherConditionUnknown => 'Inconnu';

  @override
  String get markerNameHint => 'p. ex. Maison, Travail, Départ de sentier';

  @override
  String get markerElevationLabel => 'Altitude (m)';

  @override
  String get markerIconLabel => 'Icône';

  @override
  String get markerIconHelp =>
      'Choisissez une icône pour l\'épingle sur la carte, par exemple Maison pour votre domicile.';

  @override
  String get markerSaveSearchedCoordinatesTitle =>
      'Enregistrer les coordonnées recherchées';

  @override
  String get markerSaveSearchedCoordinatesConfirm => 'Enregistrer le marqueur';

  @override
  String get lineCreateTitle => 'Créer une ligne';

  @override
  String get lineEditTitle => 'Modifier la ligne';

  @override
  String get lineDefaultName => 'Nouvelle ligne';

  @override
  String get lineNameHint => 'p. ex. Route vers le camp, Limite de propriété';

  @override
  String get lineDistanceLabel => 'Distance';

  @override
  String get lineStartPointLabel => 'Point de départ';

  @override
  String get lineEndPointLabel => 'Point d\'arrivée';

  @override
  String get lineStyleLabel => 'Style de ligne';

  @override
  String get lineBorderSolid => 'Plein';

  @override
  String get lineBorderDashed => 'Tirets';

  @override
  String get lineDirectionArrowsTitle => 'Flèches de direction';

  @override
  String get lineDirectionArrowsSubtitle =>
      'Les flèches pointent du premier point vers le second.';

  @override
  String get circleCreateTitle => 'Créer un cercle';

  @override
  String get circleEditTitle => 'Modifier le cercle';

  @override
  String get trackEditTitle => 'Modifier la trace';

  @override
  String get trackTransportationModeLabel => 'Transport';

  @override
  String get trackTransportationModeOnFoot => 'À pied';

  @override
  String get trackTransportationModeHorse => 'Cheval';

  @override
  String get trackTransportationModeBike => 'Vélo';

  @override
  String get trackTransportationModeMotorcycle => 'Moto';

  @override
  String get trackTransportationModeAtv => 'VTT';

  @override
  String get trackTransportationModeLandVehicle => 'Véhicule terrestre';

  @override
  String get trackTransportationModeTruck => 'Camion';

  @override
  String get trackTransportationModeBus => 'Bus';

  @override
  String get trackTransportationModeRv => 'Camping-car';

  @override
  String get trackTransportationModeTrain => 'Train';

  @override
  String get trackTransportationModeAmbulance => 'Ambulance';

  @override
  String get trackTransportationModeFireTruck => 'Camion de pompiers';

  @override
  String get trackTransportationModeFarmVehicle => 'Véhicule agricole';

  @override
  String get trackTransportationModeCanoe => 'Canoë';

  @override
  String get trackTransportationModeWatercraft => 'Embarcation';

  @override
  String get trackTransportationModeSailboat => 'Voilier';

  @override
  String get trackTransportationModeAircraft => 'Aéronef';

  @override
  String get trackTransportationModeHelicopter => 'Hélicoptère';

  @override
  String get trackTransportationModeGlider => 'Planeur';

  @override
  String get trackTransportationModeBalloon => 'Montgolfière';

  @override
  String get trackShowFootstepsLabel => 'Afficher la trace sur la carte';

  @override
  String get trackShowFootstepsHelp =>
      'Affiche des icônes de transport le long de la trace de déplacement.';

  @override
  String get circleDefaultName => 'Nouveau cercle';

  @override
  String get circleNameHint => 'p. ex. Zone de recherche, Limite de propriété';

  @override
  String get circleMeasurementsLabel => 'Mesures';

  @override
  String get circleCenterMoveHelp =>
      'Modifiez la latitude et la longitude pour déplacer le centre, par exemple pour l\'aligner sur un marqueur.';

  @override
  String get circleInvalidSize =>
      'Saisissez une taille valide d\'au moins 1 m de rayon.';

  @override
  String get circleCenterLabel => 'Centre';

  @override
  String get circleSizeLabelOnMap => 'Étiquette de taille sur la carte';

  @override
  String get circleCenterMarkerLabel => 'Marqueur central';

  @override
  String get rectangleCreateTitle => 'Créer un rectangle';

  @override
  String get rectangleEditTitle => 'Modifier le rectangle';

  @override
  String get rectangleDefaultName => 'Nouveau rectangle';

  @override
  String get rectangleCornerALabel => 'Coin A';

  @override
  String get rectangleCornerBLabel => 'Coin B';

  @override
  String get rectangleCenterMoveHelp =>
      'Déplacer le centre déplace tout le rectangle sur la carte.';

  @override
  String get mapHomeTooltip => 'Accueil';

  @override
  String get mapAtlasTooltip => 'Atlas cartographique imprimable';

  @override
  String get mapSettingsTooltip => 'Paramètres';

  @override
  String get mapManualTooltip => 'User manual';

  @override
  String get mapDeviceLocationTooltip => 'Ma position';

  @override
  String get mapDeviceLocationFollowingTooltip =>
      'Suivi de votre position (faites glisser pour arrêter)';

  @override
  String get mapDeviceLocationStopTooltip =>
      'Ma position (appui long pour masquer)';

  @override
  String get mapDeviceLocationServiceDisabled =>
      'Les services de localisation sont désactivés sur cet appareil.';

  @override
  String get mapDeviceLocationPermissionDenied =>
      'L\'autorisation de localisation a été refusée.';

  @override
  String get mapDeviceLocationPermissionDeniedForever =>
      'L\'autorisation de localisation est bloquée. Activez-la dans les réglages du système ou du navigateur.';

  @override
  String get mapDeviceLocationUnavailable =>
      'Impossible de déterminer votre position. Sur le web, utilisez HTTPS ou localhost.';

  @override
  String get mapDeviceLocationSelectedMarker => 'Marqueur sélectionné';

  @override
  String get mapDeviceLocationSelectMarkerHint =>
      'Sélectionnez un marqueur pour la distance et le cap';

  @override
  String mapDeviceLocationToMarker(String name, String range) {
    return 'Vers $name : $range';
  }

  @override
  String get mapMgrsGridShowTooltip => 'Afficher la grille MGRS';

  @override
  String get mapMgrsGridHideTooltip => 'Masquer la grille MGRS';

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
  String get mapShowObjectsTooltip => 'Afficher les objets cartographiques';

  @override
  String mapLoadFailed(String error) {
    return 'Échec du chargement de la carte : $error';
  }

  @override
  String get mapNoOfflineMapTitle =>
      'Aucune carte hors ligne installée ou visible';

  @override
  String get mapNoOfflineMapMessage =>
      'Téléversez un fichier .pmtiles dans les Paramètres, ou activez la visibilité des tuiles déjà sur le serveur.';

  @override
  String get mapObjectDetailsTitle => 'Objet cartographique';

  @override
  String get mapObjectDetailsLoading => 'Chargement des détails…';

  @override
  String get mapObjectDetailsNotFound => 'Cet objet est introuvable.';

  @override
  String get mapObjectDetailType => 'Type';

  @override
  String get mapObjectTypeMarker => 'Marqueur';

  @override
  String get mapObjectTypeLine => 'Ligne';

  @override
  String get mapObjectTypeTrack => 'Trace';

  @override
  String get mapObjectTypeCircle => 'Cercle';

  @override
  String get mapObjectTypeRangeRing => 'Anneau de portée';

  @override
  String get mapObjectDetailCoordinates => 'Coordonnées';

  @override
  String get mapObjectDetailMgrs => 'MGRS';

  @override
  String get mapObjectDetailMgrsUnavailable =>
      'Indisponible (hors couverture MGRS)';

  @override
  String get mapObjectDetailElevation => 'Altitude enregistrée';

  @override
  String get mapObjectDetailVisibility => 'Visibilité';

  @override
  String get mapObjectVisibilityVisible => 'Visible';

  @override
  String get mapObjectVisibilityHidden => 'Masqué';

  @override
  String get mapObjectDetailLength => 'Longueur';

  @override
  String get mapObjectDetailPointCount => 'Points';

  @override
  String get mapObjectDetailStart => 'Début';

  @override
  String get mapObjectDetailEnd => 'Fin';

  @override
  String get mapObjectDetailRadius => 'Rayon';

  @override
  String get mapObjectDetailDiameter => 'Diamètre';

  @override
  String get mapObjectDetailCenter => 'Centre';

  @override
  String get mapObjectDetailMapLabel => 'Étiquette sur la carte';

  @override
  String get mapObjectMapLabelNone => 'Aucune';

  @override
  String get mapObjectDetailDimensions => 'Dimensions';

  @override
  String get mapObjectDetailArea => 'Surface';

  @override
  String get mapObjectsErrorServerUnreachable =>
      'Le serveur Wayfinder est inaccessible. Démarrez le serveur pour synchroniser les marqueurs et les zones.';

  @override
  String get mapObjectsErrorSignInRequired =>
      'Connectez-vous pour charger vos objets cartographiques.';

  @override
  String get mapObjectsErrorGeneric =>
      'Une erreur s\'est produite lors du chargement des objets cartographiques. Vérifiez votre connexion et réessayez.';

  @override
  String get mapObjectsErrorRetry =>
      'Une erreur s\'est produite lors du chargement des objets cartographiques. Veuillez réessayer.';

  @override
  String get layersErrorTableMissing =>
      'La table des couches cartographiques est absente. Redémarrez le serveur Wayfinder avec les migrations appliquées.';

  @override
  String get layersErrorEndpointUnavailable =>
      'Redémarrez le serveur Wayfinder avec la dernière version du code.';

  @override
  String get layersErrorGeneric =>
      'Une erreur s\'est produite lors du chargement des couches. Veuillez réessayer.';

  @override
  String get sidebarTitle => 'Objets cartographiques';

  @override
  String get sidebarCollapsePanel => 'Réduire le panneau';

  @override
  String get sidebarExpandPanel => 'Développer le panneau';

  @override
  String get sidebarLayerOrderHint =>
      'Les couches supérieures s\'affichent au-dessus des inférieures. Utilisez ▼ pour développer ou réduire le contenu d\'une couche.';

  @override
  String get sidebarLayersUnavailable => 'Couches indisponibles';

  @override
  String get sidebarMarkersUnavailable => 'Marqueurs indisponibles';

  @override
  String get sidebarZonesUnavailable => 'Zones indisponibles';

  @override
  String get sidebarAddLayer => 'Ajouter une couche';

  @override
  String get sidebarKeepOneLayer => 'Vous devez conserver au moins une couche.';

  @override
  String get sidebarNewLayerTitle => 'Nouvelle couche';

  @override
  String get sidebarRenameLayerTitle => 'Renommer la couche';

  @override
  String get sidebarLayerNameLabel => 'Nom de la couche';

  @override
  String get sidebarDeleteLayerTitle => 'Supprimer la couche ?';

  @override
  String sidebarDeleteLayerMessage(String name) {
    return 'Supprimer « $name » ? Ses marqueurs et zones seront déplacés vers une autre couche.';
  }

  @override
  String get sidebarCollapseLayer => 'Réduire la couche';

  @override
  String get sidebarExpandLayer => 'Développer la couche';

  @override
  String get sidebarHideLayer => 'Masquer la couche';

  @override
  String get sidebarShowLayer => 'Afficher la couche';

  @override
  String sidebarObjectCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objets',
      one: '1 objet',
    );
    return '$_temp0';
  }

  @override
  String get sidebarSelectedForNewObjects =>
      '· sélectionné pour les nouveaux objets';

  @override
  String get sidebarMoveUp => 'Monter';

  @override
  String get sidebarMoveDown => 'Descendre';

  @override
  String get sidebarTabMarkers => 'Marqueurs';

  @override
  String get sidebarTabZones => 'Zones';

  @override
  String get sidebarViewList => 'Liste';

  @override
  String get sidebarViewTree => 'Arbre';

  @override
  String get sidebarFilterFoodExpiring90Days =>
      'Nourriture expirant sous 90 jours';

  @override
  String get sidebarFiltersTitle => 'Filtres';

  @override
  String get sidebarFiltersActiveTooltip => 'Des filtres sont appliqués';

  @override
  String get sidebarFilterResourcesLabel => 'Ressources';

  @override
  String get markerResourceTypeLabel => 'Type de ressource';

  @override
  String get markerResourceTypeHelp =>
      'Classez sources, puits, caches, carburant et cliniques pour les filtres de la carte des ressources.';

  @override
  String get markerResourceTypeNone => 'Aucun (pas une ressource)';

  @override
  String get markerResourceTypeSpring => 'Source';

  @override
  String get markerResourceTypeWell => 'Puits';

  @override
  String get markerResourceTypeCache => 'Cache';

  @override
  String get markerResourceTypeFuel => 'Carburant';

  @override
  String get markerResourceTypeClinic => 'Clinique';

  @override
  String markerResourceTypeDetail(String type) {
    return 'Ressource : $type';
  }

  @override
  String get sidebarNoMatchingMarkers => 'Aucun marqueur correspondant';

  @override
  String get sidebarNoMatchingZones => 'Aucune zone correspondante';

  @override
  String get sidebarTryDifferentSearch =>
      'Essayez un autre terme de recherche.';

  @override
  String get sidebarNoMarkersOnLayer => 'Aucun marqueur sur cette couche';

  @override
  String get sidebarAddMarkerHint =>
      'Appuyez longuement sur la carte pour ajouter un marqueur.';

  @override
  String get sidebarNoZonesOnLayer => 'Aucune zone sur cette couche';

  @override
  String get sidebarAddZoneHint =>
      'Appuyez longuement sur la carte et choisissez Ligne pour en dessiner une.';

  @override
  String get sidebarHideMarker => 'Masquer le marqueur';

  @override
  String get sidebarShowMarker => 'Afficher le marqueur';

  @override
  String get sidebarEditMarker => 'Modifier le marqueur';

  @override
  String get sidebarDeleteMarker => 'Supprimer le marqueur';

  @override
  String get sidebarHideNameOnMap => 'Masquer le nom sur la carte';

  @override
  String get sidebarShowNameOnMap => 'Afficher le nom sur la carte';

  @override
  String get sidebarHideDistanceOnMap => 'Masquer la distance sur la carte';

  @override
  String get sidebarShowDistanceOnMap => 'Afficher la distance sur la carte';

  @override
  String get sidebarHideLine => 'Masquer la ligne';

  @override
  String get sidebarShowLine => 'Afficher la ligne';

  @override
  String get sidebarEditLine => 'Modifier la ligne';

  @override
  String get sidebarEditTrack => 'Modifier la trace';

  @override
  String get sidebarDeleteTrack => 'Supprimer la trace';

  @override
  String get sidebarShowTrack => 'Afficher la trace';

  @override
  String get sidebarHideTrack => 'Masquer la trace';

  @override
  String get sidebarDeleteLine => 'Supprimer la ligne';

  @override
  String get sidebarHideCircle => 'Masquer le cercle';

  @override
  String get sidebarShowCircle => 'Afficher le cercle';

  @override
  String get sidebarEditCircle => 'Modifier le cercle';

  @override
  String get sidebarDeleteCircle => 'Supprimer le cercle';

  @override
  String get sidebarHideRectangle => 'Masquer le rectangle';

  @override
  String get sidebarShowRectangle => 'Afficher le rectangle';

  @override
  String get sidebarEditRectangle => 'Modifier le rectangle';

  @override
  String get sidebarDeleteRectangle => 'Supprimer le rectangle';

  @override
  String get sidebarHideZone => 'Masquer la zone';

  @override
  String get sidebarShowZone => 'Afficher la zone';

  @override
  String get sidebarDeleteZone => 'Supprimer la zone';

  @override
  String get searchReadinessReadySnackBar =>
      'Recherche complète prête — lieux et adresses.';

  @override
  String get searchReadinessCheckingTooltip =>
      'Vérification de la disponibilité de la recherche…';

  @override
  String get searchReadinessUnavailableTooltip =>
      'Disponibilité de la recherche indisponible';

  @override
  String get searchReadinessFullReadyTooltip => 'Recherche complète prête';

  @override
  String get searchReadinessBuildingTooltip =>
      'Construction des index de recherche…';

  @override
  String get searchReadinessNotReadyTooltip => 'Recherche complète non prête';

  @override
  String get searchReadinessGeocodingNotConfiguredTooltip =>
      'Serveur de géocodage non configuré';

  @override
  String get searchReadinessGeocodingUnavailableTooltip =>
      'Serveur de géocodage indisponible';

  @override
  String searchReadinessImportInProgressTooltip(String phase) {
    return 'Importation en cours : $phase';
  }

  @override
  String get searchReadinessImportPlacesDialogTitle =>
      'Importation des données de lieux';

  @override
  String get searchReadinessImportAddressesDialogTitle =>
      'Importation des données d\'adresses';

  @override
  String get searchReadinessFullReadyTitle => 'Recherche complète prête';

  @override
  String get searchReadinessPlacesReadyTitle => 'Recherche de lieux prête';

  @override
  String get searchReadinessAddressReadyTitle => 'Recherche d\'adresses prête';

  @override
  String get searchReadinessWaitingForDataTitle =>
      'En attente des données de géocodage';

  @override
  String get searchReadinessNotReadyTitle => 'Recherche pas encore prête';

  @override
  String searchReadinessIndexesBuilt(int ready, int total) {
    return 'Index de recherche : $ready sur $total';
  }

  @override
  String get searchReadinessCheckingStatus =>
      'Vérification de l\'état de la recherche…';

  @override
  String get searchReadinessFullReadyMessage =>
      'Vous pouvez rechercher des lieux et des adresses postales depuis la barre de recherche de la carte.';

  @override
  String get searchReadinessPlacesOnlyMessage =>
      'Vous pouvez rechercher des noms de lieux depuis la barre de recherche de la carte. Importez les données d\'adresses dans Paramètres → Géocodage pour rechercher des adresses.';

  @override
  String get searchReadinessAddressOnlyMessage =>
      'Vous pouvez rechercher des adresses postales depuis la barre de recherche de la carte. Importez les données de lieux dans Paramètres → Géocodage pour rechercher des noms de lieux.';

  @override
  String get searchReadinessWaitingForDataMessage =>
      'Les index de recherche sont prêts. Importez les jeux de données manquants dans Paramètres → Géocodage pour activer la recherche.';

  @override
  String get searchReadinessRequirementsTitle => 'Conditions de recherche';

  @override
  String get searchReadinessRequirementPlacesData =>
      'Données de lieux importées';

  @override
  String get searchReadinessRequirementAddressData =>
      'Données d\'adresses importées';

  @override
  String get searchReadinessRequirementIndexes =>
      'Index de recherche construits';

  @override
  String get searchReadinessRequirementReady => 'Prêt';

  @override
  String get searchReadinessRequirementMissing => 'Pas prêt';

  @override
  String get searchReadinessPartialReadyTooltip => 'Recherche partielle prête';

  @override
  String get searchReadinessPlacesOnlyTooltip => 'Recherche de lieux prête';

  @override
  String searchReadinessPercentComplete(int percent) {
    return '$percent % terminé';
  }

  @override
  String searchReadinessEta(String eta) {
    return 'Temps restant estimé : $eta';
  }

  @override
  String searchReadinessCurrentIndex(String name) {
    return 'Index en cours : $name';
  }

  @override
  String get searchReadinessServerUnreachable =>
      'Impossible de joindre le serveur pour vérifier l\'état de la recherche.';

  @override
  String get mapTilesReadyTooltip => 'Tuiles cartographiques prêtes';

  @override
  String get mapTilesLoadingTooltip => 'Chargement des tuiles cartographiques';

  @override
  String get mapTilesNotReadyTooltip => 'Tuiles cartographiques non prêtes';

  @override
  String get mapTilesLoadingTitle => 'Chargement des tuiles cartographiques';

  @override
  String get mapTilesCatalogLoadFailed =>
      'Échec du chargement du catalogue de tuiles.';

  @override
  String get mapTilesCatalogLoading => 'Loading map tile catalog…';

  @override
  String mapTilesPreparingFile(String name) {
    return 'Preparing $name';
  }

  @override
  String mapTilesOpeningLayer(String name) {
    return 'Ouverture : $name';
  }

  @override
  String get mapTilesLargeArchiveHelp =>
      'Les grandes archives .pmtiles peuvent prendre plusieurs minutes à s\'ouvrir avant que les tuiles apparaissent. Le panoramique et le zoom chargeront les tuiles au fur et à mesure.';

  @override
  String mapTilesLayersPrepared(int loaded, int enabled) {
    return 'Couches préparées : $loaded sur $enabled';
  }

  @override
  String mapTilesActiveLayer(String name) {
    return 'Couche active : $name';
  }

  @override
  String get mapTilesReadyHelp =>
      'Les tuiles pour la vue actuelle devraient être visibles. Si la carte est encore vide, essayez de zoomer sur la zone couverte par la couche.';

  @override
  String mapTilesOpeningProgress(String name) {
    return 'Ouverture de $name…';
  }

  @override
  String mapTilesOpeningElapsed(String name, int seconds) {
    return 'Opening $name… ${seconds}s';
  }

  @override
  String mapTilesOpeningFromUrl(String url) {
    return 'Fetching header from $url';
  }

  @override
  String get greetingsConnected => 'Vous êtes connecté';

  @override
  String get greetingsNameHint => 'Entrez votre nom';

  @override
  String get greetingsSendToServer => 'Envoyer au serveur';

  @override
  String get greetingsNoResponse => 'Pas encore de réponse du serveur.';

  @override
  String get authSuccess => 'Utilisateur authentifié.';

  @override
  String authFailed(String error) {
    return 'Échec de l\'authentification : $error';
  }

  @override
  String couldNotOpenLink(String url) {
    return 'Impossible d\'ouvrir le lien : $url';
  }

  @override
  String get geocodingAbortImport => 'Annuler l\'importation';

  @override
  String get geocodingTitle => 'Géocodage';

  @override
  String get geocodingDescription =>
      'Téléchargez les données OSMNames sur le serveur de géocodage pour la recherche hors ligne. Les noms de lieux et les adresses postales sont importés séparément.';

  @override
  String get geocodingPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de configurer le serveur de géocodage ni de gérer les emplacements personnalisés.';

  @override
  String get geocodingServerConnectionTitle => 'Serveur de géocodage';

  @override
  String get geocodingServerConnectionDescription =>
      'Séparé du serveur principal Wayfinder. Exécutez la pile de géocodage sur une autre machine lorsque les importations nécessitent une grande base de données.';

  @override
  String get geocodingServerUrlLabel => 'URL web du serveur de géocodage';

  @override
  String get geocodingSaveServerUrl =>
      'Enregistrer l\'URL du serveur de géocodage';

  @override
  String get geocodingServerNotConfiguredMessage =>
      'Configurez l\'URL du serveur de géocodage pour activer la recherche de lieux et d\'adresses. Redémarrez l\'application après l\'enregistrement.';

  @override
  String get geocodingServerUrlSavedRestart =>
      'URL du serveur de géocodage enregistrée. Redémarrez l\'application pour vous connecter.';

  @override
  String get geocodingServerUrlSaved => 'Geocoding server URL saved.';

  @override
  String get geocodingPlacesSectionTitle => 'Noms de lieux (geonames.tsv)';

  @override
  String get geocodingDownloadedDatasetsSectionTitle =>
      'Downloaded datasets (OSMNames)';

  @override
  String get geocodingDownloadedDatasetsSectionDescription =>
      'Large planet or regional imports from OSMNames. Custom locations above work without importing these.';

  @override
  String get geocodingPlaceDatasetLabel => 'Jeu de données de lieux';

  @override
  String get geocodingCustomPlaceUrlLabel =>
      'URL de données de lieux personnalisée';

  @override
  String geocodingStatusLabel(String status) {
    return 'État : $status';
  }

  @override
  String geocodingLastSelection(String dataset) {
    return 'Dernière sélection : $dataset';
  }

  @override
  String geocodingLastImport(String dateTime) {
    return 'Dernière importation : $dateTime';
  }

  @override
  String get geocodingPlacesArchiveDescription =>
      'Archivez les données de lieux en JSON, restaurez depuis une exportation précédente ou supprimez tous les enregistrements du serveur.';

  @override
  String get geocodingPlaceImportInProgress => 'Importation de lieux en cours…';

  @override
  String get geocodingDownloadImportPlaces =>
      'Télécharger et importer les lieux';

  @override
  String get geocodingAddressesSectionTitle =>
      'Adresses postales (housenumbers.tsv)';

  @override
  String get geocodingHousenumbersUrlLabel => 'URL des données housenumbers';

  @override
  String get geocodingAddressesArchiveDescription =>
      'Archivez les données d\'adresses dans un fichier JSON séparé, restaurez depuis une exportation précédente ou supprimez tous les enregistrements du serveur.';

  @override
  String get geocodingAddressImportInProgress =>
      'Importation d\'adresses en cours…';

  @override
  String get geocodingDownloadImportHousenumbers =>
      'Télécharger et importer les housenumbers';

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
    return 'Échec du chargement des paramètres de géocodage : $error';
  }

  @override
  String get geocodingStatusNotImported => 'Non importé';

  @override
  String get geocodingStatusDownloading => 'Téléchargement…';

  @override
  String get geocodingStatusImporting => 'Importation…';

  @override
  String geocodingStatusReady(String count, String label) {
    return 'Prêt ($count $label)';
  }

  @override
  String get geocodingStatusFailed => 'Échec';

  @override
  String get geocodingStatusCancelled => 'Annulé';

  @override
  String get geocodingCustomUrlLabel => 'URL personnalisée';

  @override
  String get geocodingRowLabelPlaces => 'lieux';

  @override
  String get geocodingRowLabelAddresses => 'adresses';

  @override
  String get geocodingRowLabelRows => 'lignes';

  @override
  String geocodingImportProgress(
    String percent,
    String count,
    String rowLabel,
  ) {
    return '$percent % · $count $rowLabel importé(s)';
  }

  @override
  String get geocodingImportPhaseDownloadingTitle =>
      'Téléchargement du jeu de données';

  @override
  String get geocodingImportPhaseDownloadingDetail =>
      'Récupération du fichier compressé de noms de lieux depuis Internet.';

  @override
  String get geocodingImportPhaseImportingTitle => 'Lecture des noms de lieux';

  @override
  String get geocodingImportPhaseImportingDetail =>
      'Enregistrement des lieux sur le serveur au fur et à mesure de la lecture du fichier.';

  @override
  String get geocodingImportPhaseImportingAddressesTitle =>
      'Lecture des adresses';

  @override
  String get geocodingImportPhaseImportingAddressesDetail =>
      'Enregistrement des adresses sur le serveur au fur et à mesure de la lecture du fichier.';

  @override
  String get geocodingImportPhaseFinalizingTitle => 'Finalisation';

  @override
  String get geocodingImportPhaseFinalizingDetail =>
      'Enregistrement du dernier lot avant l\'étape finale.';

  @override
  String get geocodingImportPhaseCommittingTitle => 'Presque terminé';

  @override
  String geocodingImportPhaseCommittingDetail(String count, String rowLabel) {
    return 'Les $count $rowLabel ont tous été lus. Le serveur les enregistre maintenant pour la recherche. Cela peut prendre une à trois heures et la barre de progression peut s\'arrêter ici.';
  }

  @override
  String get geocodingImportDoNotRestartTitle => 'Gardez le serveur en marche';

  @override
  String get geocodingImportDoNotRestartMessage =>
      'Ne redémarrez pas et n\'arrêtez pas le serveur pendant cette étape. Sinon, l\'importation sera annulée et vous devrez recommencer depuis le début.';

  @override
  String get geocodingSourceUrlRequired =>
      'L\'URL source de géocodage est requise.';

  @override
  String get geocodingPlanetImportStarted =>
      'Importation planétaire des lieux démarrée. Cela peut prendre de nombreuses heures.';

  @override
  String get geocodingPlaceImportStarted =>
      'Importation des noms de lieux démarrée.';

  @override
  String geocodingPlaceImportFailed(String error) {
    return 'Échec de l\'importation des lieux : $error';
  }

  @override
  String get geocodingPlaceImportAbortRequested =>
      'Annulation de l\'importation des lieux demandée. Les données existantes seront conservées.';

  @override
  String geocodingAbortFailed(String error) {
    return 'Échec de l\'annulation : $error';
  }

  @override
  String get geocodingHousenumbersUrlRequired =>
      'L\'URL source des housenumbers est requise.';

  @override
  String get geocodingHousenumbersImportStarted =>
      'Importation des housenumbers démarrée. Cela peut prendre de nombreuses heures.';

  @override
  String geocodingHousenumbersImportFailed(String error) {
    return 'Échec de l\'importation des housenumbers : $error';
  }

  @override
  String get geocodingAddressImportAbortRequested =>
      'Annulation de l\'importation d\'adresses demandée. Les données existantes seront conservées.';

  @override
  String get geocodingPlaceDataExported => 'Données de lieux exportées.';

  @override
  String get geocodingImportPlaceArchiveTitle =>
      'Importer l\'archive de lieux ?';

  @override
  String get geocodingImportPlaceArchiveMessage =>
      'Cela remplace tous les enregistrements de noms de lieux sur le serveur par le fichier d\'archive sélectionné.';

  @override
  String geocodingPlaceArchiveImported(int count) {
    return '$count enregistrement(s) de lieu importé(s).';
  }

  @override
  String geocodingImportFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get geocodingRemoveAllPlacesTitle =>
      'Supprimer tous les enregistrements de lieux ?';

  @override
  String get geocodingRemoveAllPlacesMessage =>
      'Cela supprime définitivement tous les enregistrements de noms de lieux du serveur. Cette action est irréversible.';

  @override
  String geocodingPlacesRemoved(int count) {
    return '$count enregistrement(s) de lieu supprimé(s).';
  }

  @override
  String geocodingRemoveFailed(String error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String get geocodingHousenumberDataExported =>
      'Données housenumbers exportées.';

  @override
  String get geocodingImportHousenumberArchiveTitle =>
      'Importer l\'archive housenumbers ?';

  @override
  String get geocodingImportHousenumberArchiveMessage =>
      'Cela remplace tous les enregistrements d\'adresses sur le serveur par le fichier d\'archive sélectionné.';

  @override
  String geocodingHousenumberArchiveImported(int count) {
    return '$count enregistrement(s) d\'adresse importé(s).';
  }

  @override
  String get geocodingRemoveAllAddressesTitle =>
      'Supprimer tous les enregistrements d\'adresses ?';

  @override
  String get geocodingRemoveAllAddressesMessage =>
      'Cela supprime définitivement tous les enregistrements housenumbers du serveur. Cette action est irréversible.';

  @override
  String geocodingAddressesRemoved(int count) {
    return '$count enregistrement(s) d\'adresse supprimé(s).';
  }

  @override
  String get geocodingPlanetImportWarning =>
      'L\'importation planétaire complète télécharge environ 1,4 Go et peut prendre de nombreuses heures. Pour la plupart des utilisateurs, commencez par l\'échantillon ou un seul pays.';

  @override
  String get geocodingCountryImportDownloadNote =>
      'Les importations par pays téléchargent toujours le fichier OSMNames global (~1,4 Go), mais seul le pays sélectionné est chargé dans la base de données.';

  @override
  String get geocodingHousenumbersImportWarning =>
      'Le fichier housenumbers est distinct des noms de lieux et fait aussi environ 1,4 Go compressé. L\'importation peut prendre de nombreuses heures.';

  @override
  String get geocodingDatasetSample => 'Échantillon (100 k lieux)';

  @override
  String get geocodingDatasetSampleDescription =>
      'Un petit jeu de données d\'aperçu. Idéal pour tester la recherche en quelques minutes.';

  @override
  String get geocodingDatasetPlanet => 'Planète complète (~23 M lieux)';

  @override
  String get geocodingDatasetPlanetDescription =>
      'Importe chaque lieu du fichier planétaire OSMNames. Le téléchargement fait environ 1,4 Go compressé et l\'importation peut prendre de nombreuses heures.';

  @override
  String get geocodingDatasetUs => 'États-Unis';

  @override
  String get geocodingDatasetUsDescription =>
      'Télécharge le fichier OSMNames global mais n\'importe que les lieux des États-Unis.';

  @override
  String get geocodingDatasetCa => 'Canada';

  @override
  String get geocodingDatasetCaDescription =>
      'Télécharge le fichier OSMNames global mais n\'importe que les lieux canadiens.';

  @override
  String get geocodingDatasetMx => 'Mexique';

  @override
  String get geocodingDatasetGb => 'Royaume-Uni';

  @override
  String get geocodingDatasetDe => 'Allemagne';

  @override
  String get geocodingDatasetFr => 'France';

  @override
  String get geocodingDatasetEs => 'Espagne';

  @override
  String get geocodingDatasetIt => 'Italie';

  @override
  String get geocodingDatasetNl => 'Pays-Bas';

  @override
  String get geocodingDatasetAu => 'Australie';

  @override
  String get geocodingDatasetNz => 'Nouvelle-Zélande';

  @override
  String get geocodingDatasetJp => 'Japon';

  @override
  String get geocodingDatasetBr => 'Brésil';

  @override
  String get geocodingDatasetIn => 'Inde';

  @override
  String get geocodingDatasetCustom => 'URL personnalisée…';

  @override
  String get geocodingDatasetCustomDescription =>
      'Fournissez votre propre URL OSMNames .tsv.gz.';

  @override
  String get mapRadialMarker => 'Marqueur';

  @override
  String get mapRadialLine => 'Ligne';

  @override
  String get mapRadialCircle => 'Cercle';

  @override
  String get mapRadialRectCenter => 'Rect. centre';

  @override
  String get mapRadialRectCorners => 'Rect. coins';

  @override
  String get mapRadialPolygon => 'Polygone';

  @override
  String get mapRadialMore => 'Plus';

  @override
  String get mapRadialBack => 'Retour';

  @override
  String get mapRadialCopyCoordinates => 'Copier les coordonnées';

  @override
  String get actionDone => 'Terminé';

  @override
  String get polygonEditingHint =>
      'Glissez un sommet pour déplacer · double-clic sur un bord pour ajouter · double-clic sur un sommet pour retirer (min. 3) · Terminé pour quitter';

  @override
  String get mapRadialDeadReckoning => 'Pas';

  @override
  String get mapRadialViewshed => 'Bassin de vue';

  @override
  String get mapRadialSlope => 'Pente / coût';

  @override
  String get mapRadialRangeRing => 'Anneau de portée';

  @override
  String get mapRadialCoveragePlan => 'Plan de couverture';

  @override
  String get mapRadialSunMoon => 'Soleil / lune';

  @override
  String get mapRadialTides => 'Marées';

  @override
  String get mapRadialSeasonalOverlay => 'Season';

  @override
  String get mapRadialEvacKit => 'Kit d\'évacuation';

  @override
  String get tidesTitle => 'Tables des marées';

  @override
  String get tidesSubtitle =>
      'Station côtière la plus proche depuis les packs sur votre serveur Wayfinder — pour passages en bateau.';

  @override
  String get tidesLocationLabel => 'Lieu';

  @override
  String get tidesAnchorMarker => 'Repère';

  @override
  String get tidesAnchorHome => 'Accueil';

  @override
  String get tidesAnchorMapPoint => 'Point carte';

  @override
  String get tidesDateLabel => 'Date';

  @override
  String get tidesPickDate => 'Choisir la date';

  @override
  String get tidesMissingLocation =>
      'Choisissez un lieu pour consulter les marées.';

  @override
  String tidesQueryFailed(String error) {
    return 'Impossible de charger les marées : $error';
  }

  @override
  String get tidesApproximateBanner =>
      'Hauteurs estimées par harmoniques du pack côtier (pas d\'observations NOAA en direct).';

  @override
  String tidesStationHeading(String name, String id) {
    return '$name ($id)';
  }

  @override
  String tidesStationMeta(String distance, String datum) {
    return 'À $distance · datum $datum';
  }

  @override
  String get tidesExtremesSection => 'Hautes et basses mers';

  @override
  String get tidesCurveSection => 'Courbe de marée';

  @override
  String get tidesNoExtremes => 'Aucun extrême pour ce jour.';

  @override
  String get tidesCrossingHint =>
      'Basse mer pour gués, haute mer pour passages plus profonds. Confirmez sur place.';

  @override
  String get tidesExtremeHigh => 'Haute';

  @override
  String get tidesExtremeLow => 'Basse';

  @override
  String tidesHeightMeters(String value) {
    return '$value m';
  }

  @override
  String tidesHeightFeet(String value) {
    return '$value ft';
  }

  @override
  String get tidesDistanceUnknown => 'distance inconnue';

  @override
  String tidesDistanceMeters(String value) {
    return '$value m';
  }

  @override
  String tidesDistanceKm(String value) {
    return '$value km';
  }

  @override
  String tidesDistanceFeet(String value) {
    return '$value ft';
  }

  @override
  String tidesDistanceMiles(String value) {
    return '$value mi';
  }

  @override
  String get tidesSettingsTitle => 'Packs de marées côtières';

  @override
  String get tidesSettingsSubtitle =>
      'Téléchargez des packs harmoniques NOAA sur ce serveur Wayfinder. L\'outil Marées interroge ces packs hors ligne (le serveur doit joindre NOAA à l\'import). Enregistrez les packs en .wayfinder-tide pour les restaurer sans internet.';

  @override
  String get tidesPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de télécharger, importer ou supprimer des packs de marées côtières.';

  @override
  String get tidesInstalledPacks => 'Packs installés';

  @override
  String get tidesTransferHint =>
      'Téléchargez un pack sur l\'appareil pour le restaurer hors ligne, ou importez un fichier .wayfinder-tide. Les packs de marées ne font pas partie de la sauvegarde cartographique.';

  @override
  String get tidesUploadPack => 'Importer un pack';

  @override
  String get tidesExportPack => 'Enregistrer le fichier du pack';

  @override
  String tidesExportPackSuccess(String name) {
    return 'Pack de marées « $name » enregistré.';
  }

  @override
  String tidesExportPackFailed(String error) {
    return 'Impossible d\'enregistrer le pack de marées : $error';
  }

  @override
  String tidesUploadPackSuccess(String name, int stations) {
    return '« $name » restauré avec $stations stations.';
  }

  @override
  String tidesUploadPackFailed(String error) {
    return 'Impossible d\'importer le pack de marées : $error';
  }

  @override
  String get tidesNoPacksInstalled =>
      'Aucun pack. Téléchargez une région ci-dessous ou importez un fichier .wayfinder-tide.';

  @override
  String tidesPackMeta(int stations, String size, String date) {
    return '$stations stations · $size · $date';
  }

  @override
  String get tidesGetCoastalPacks => 'Obtenir des packs côtiers';

  @override
  String get tidesGetCoastalPacksHint =>
      'Importe jusqu\'à ~80 stations NOAA de la région. Peut prendre plusieurs minutes.';

  @override
  String get tidesDownloadPack => 'Télécharger';

  @override
  String get tidesImportInProgress => 'Téléchargement du pack côtier NOAA…';

  @override
  String tidesImportSuccess(String name, int stations) {
    return '« $name » installé avec $stations stations.';
  }

  @override
  String tidesImportFailed(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String tidesActionFailed(String error) {
    return 'Échec marées : $error';
  }

  @override
  String get tidesDeletePack => 'Supprimer le pack';

  @override
  String tidesDeletePackConfirm(String name) {
    return 'Supprimer le pack côtier « $name » du serveur ?';
  }

  @override
  String tidesRegionBbox(
    String minLat,
    String minLng,
    String maxLat,
    String maxLng,
  ) {
    return '$minLat°, $minLng° → $maxLat°, $maxLng°';
  }

  @override
  String get tidesOpenFromEvac => 'Marées sur l\'itinéraire';

  @override
  String get sunMoonTitle => 'Soleil / lune / crépuscule';

  @override
  String get sunMoonSubtitle =>
      'Lever, coucher, crépuscule, phase lunaire et fenêtres nocturnes hors ligne pour un lieu et une date.';

  @override
  String get sunMoonLocationLabel => 'Lieu';

  @override
  String get sunMoonAnchorMarker => 'Repère';

  @override
  String get sunMoonAnchorHome => 'Accueil';

  @override
  String get sunMoonAnchorMapPoint => 'Point carte';

  @override
  String get sunMoonDateLabel => 'Date';

  @override
  String get sunMoonPickDate => 'Choisir la date';

  @override
  String get sunMoonTimezoneSection => 'Fuseau horaire';

  @override
  String get sunMoonTimezoneHint =>
      'Convertit les heures en heure d\'hiver ou d\'été. Auto suit les règles IANA DST de la date.';

  @override
  String get sunMoonTimeBaseLabel => 'Afficher les heures en';

  @override
  String get sunMoonTimeBaseZone => 'Fuseau';

  @override
  String get sunMoonTimeBaseDevice => 'Appareil';

  @override
  String get sunMoonTimeBaseUtc => 'UTC';

  @override
  String get sunMoonZoneLabel => 'Fuseau';

  @override
  String sunMoonZoneLongitude(String iana) {
    return 'Depuis la longitude ($iana)';
  }

  @override
  String get sunMoonDstLabel => 'Ajustement DST';

  @override
  String get sunMoonDstAuto => 'Auto';

  @override
  String get sunMoonDstStandard => 'Hiver';

  @override
  String get sunMoonDstDaylight => 'Été';

  @override
  String get sunMoonDstAutoHint =>
      'Utiliser les règles DST du fuseau pour chaque événement';

  @override
  String get sunMoonDstStandardHint => 'Forcer le décalage d\'heure d\'hiver';

  @override
  String get sunMoonDstDaylightHint => 'Forcer le décalage d\'heure d\'été';

  @override
  String get sunMoonDstNoDstHint =>
      'Ce fuseau n\'a pas de règles IANA DST. Été applique un décalage de planification de +1 h sur l\'heure d\'hiver.';

  @override
  String get sunMoonTzSummaryUtc => 'Affichage UTC';

  @override
  String sunMoonTzSummaryDevice(String name, String offset) {
    return 'Appareil · $name · $offset';
  }

  @override
  String sunMoonTzSummaryZone(
    String iana,
    String abbr,
    String offset,
    String dst,
  ) {
    return '$iana · $abbr · $offset · $dst';
  }

  @override
  String sunMoonTimeUtc(String time) {
    return '$time UTC';
  }

  @override
  String get sunMoonMissingLocation => 'Choisissez un lieu pour calculer.';

  @override
  String get sunMoonNotApplicable => '—';

  @override
  String get sunMoonPolarDay =>
      'Jour polaire — le soleil ne se couche pas à cette date.';

  @override
  String get sunMoonPolarNight =>
      'Nuit polaire — le soleil ne se lève pas à cette date.';

  @override
  String get sunMoonSunSection => 'Soleil';

  @override
  String get sunMoonSunrise => 'Lever du soleil';

  @override
  String get sunMoonSolarNoon => 'Midi solaire';

  @override
  String get sunMoonSunset => 'Coucher du soleil';

  @override
  String get sunMoonTwilightSection => 'Crépuscule';

  @override
  String get sunMoonCivilDawn => 'Aube civile';

  @override
  String get sunMoonCivilDusk => 'Crépuscule civil';

  @override
  String get sunMoonNauticalDawn => 'Aube nautique';

  @override
  String get sunMoonNauticalDusk => 'Crépuscule nautique';

  @override
  String get sunMoonAstronomicalDawn => 'Aube astronomique';

  @override
  String get sunMoonAstronomicalDusk => 'Crépuscule astronomique';

  @override
  String get sunMoonNightOpsSection => 'Ops de nuit';

  @override
  String get sunMoonNightOpsHint =>
      'Du crépuscule nautique à la prochaine aube nautique (soleil à 12° ou plus sous l\'horizon).';

  @override
  String get sunMoonNightOpsStart => 'Début d\'obscurité';

  @override
  String get sunMoonNightOpsEnd => 'Fin d\'obscurité';

  @override
  String get sunMoonMoonSection => 'Lune';

  @override
  String get sunMoonPhaseLabel => 'Phase';

  @override
  String get sunMoonPhaseNew => 'Nouvelle lune';

  @override
  String get sunMoonPhaseWaxingCrescent => 'Premier croissant';

  @override
  String get sunMoonPhaseFirstQuarter => 'Premier quartier';

  @override
  String get sunMoonPhaseWaxingGibbous => 'Lune gibbeuse croissante';

  @override
  String get sunMoonPhaseFull => 'Pleine lune';

  @override
  String get sunMoonPhaseWaningGibbous => 'Lune gibbeuse décroissante';

  @override
  String get sunMoonPhaseLastQuarter => 'Dernier quartier';

  @override
  String get sunMoonPhaseWaningCrescent => 'Dernier croissant';

  @override
  String get sunMoonIlluminationLabel => 'Illumination';

  @override
  String sunMoonIlluminationValue(int percent) {
    return '$percent%';
  }

  @override
  String get sunMoonAgeLabel => 'Âge';

  @override
  String sunMoonAgeValue(String days) {
    return '$days jours';
  }

  @override
  String get sunMoonMoonrise => 'Lever de la lune';

  @override
  String get sunMoonMoonset => 'Coucher de la lune';

  @override
  String get rangeRingTitle => 'Anneau de portée';

  @override
  String get coveragePlanTitle => 'Plan de couverture';

  @override
  String get coveragePlanSubtitle =>
      'Placez des sites relais ou mesh suggérés avec des cercles de portée. Optionnellement calculez la vue (LOS) sur le site graine. Géométrie de planification uniquement — pas de RF en direct.';

  @override
  String get coveragePlanTemplateLabel => 'Modèle';

  @override
  String get coveragePlanTemplateMesh => 'Mesh / LoRa';

  @override
  String get coveragePlanTemplateRepeater => 'Relais VHF/UHF';

  @override
  String get coveragePlanTemplateShack => 'Ham shack';

  @override
  String get coveragePlanLayoutLabel => 'Disposition';

  @override
  String get coveragePlanLayoutSingle => 'Site unique';

  @override
  String get coveragePlanLayoutHexRing => 'Anneau hexagonal (7)';

  @override
  String get coveragePlanAnchorLabel => 'Centre graine';

  @override
  String get coveragePlanAnchorMarker => 'Marqueur';

  @override
  String coveragePlanAnchorMarkerNamed(String name) {
    return 'Marqueur : $name';
  }

  @override
  String get coveragePlanAnchorHome => 'Accueil';

  @override
  String get coveragePlanAnchorMapPoint => 'Point carte';

  @override
  String get coveragePlanRadiusLabel => 'Rayon de couverture';

  @override
  String get coveragePlanRadiusHelp =>
      'Cercle de portée autour de chaque site.';

  @override
  String get coveragePlanSpacingLabel => 'Espacement des sites';

  @override
  String get coveragePlanSpacingHelp =>
      'Distance centre à centre de l\'anneau hexagonal (défaut ~1,7× le rayon pour un léger chevauchement).';

  @override
  String get coveragePlanCreateMarkers => 'Créer des marqueurs';

  @override
  String get coveragePlanCreateCircles => 'Créer des cercles de portée';

  @override
  String get coveragePlanRunViewshed => 'Calculer la vue sur la graine';

  @override
  String get coveragePlanRunViewshedHelp =>
      'Calcule le LOS terrain depuis la graine avec la hauteur d\'antenne et le rayon du modèle.';

  @override
  String coveragePlanSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crée $count sites',
      one: 'Crée 1 site',
    );
    return '$_temp0';
  }

  @override
  String get coveragePlanCreateAction => 'Créer le plan';

  @override
  String get coveragePlanMissingCenter =>
      'Choisissez un centre graine (marqueur, accueil ou point carte).';

  @override
  String get coveragePlanInvalidRadius =>
      'Entrez un rayon entre 50 m et 100 km.';

  @override
  String get coveragePlanInvalidSpacing =>
      'Entrez un espacement entre 50 m et 100 km.';

  @override
  String get coveragePlanNeedOutput =>
      'Activez les marqueurs et/ou les cercles de portée.';

  @override
  String coveragePlanSiteName(String template, String label) {
    return '$template $label';
  }

  @override
  String coveragePlanCircleNotes(String template) {
    return 'Cercle de couverture du plan ($template)';
  }

  @override
  String coveragePlanRadioNotes(String template) {
    return 'Placé par le plan de couverture ($template)';
  }

  @override
  String coveragePlanCreatedSnack(int markers, int circles) {
    return 'Plan de couverture : $markers marqueur(s), $circles cercle(s).';
  }

  @override
  String get rangeRingHelp =>
      'Calculez un rayon de déplacement ou de carburant depuis le domicile, un marqueur sélectionné (point de ralliement) ou le point de la carte, puis enregistrez-le comme cercle.';

  @override
  String get rangeRingCenterLabel => 'Centre';

  @override
  String get rangeRingCenterMarker => 'Marqueur';

  @override
  String get rangeRingCenterHome => 'Domicile';

  @override
  String get rangeRingCenterMapPoint => 'Point carte';

  @override
  String get rangeRingNoCenter =>
      'Sélectionnez d’abord un marqueur, définissez un domicile ou appuyez longuement sur la carte.';

  @override
  String get rangeRingModeLabel => 'Mode';

  @override
  String get rangeRingBasisLabel => 'Base';

  @override
  String get rangeRingBasisDuration => 'Durée';

  @override
  String get rangeRingBasisFuel => 'Carburant';

  @override
  String get rangeRingDurationHoursLabel => 'Durée (heures)';

  @override
  String rangeRingDurationHelp(String speedKmh) {
    return 'Utilise $speedKmh km/h de vitesse planifiée (modifiable sous Hypothèses).';
  }

  @override
  String get rangeRingFuelAmountLabel => 'Quantité de carburant';

  @override
  String get rangeRingFuelUnitLabel => 'Unité';

  @override
  String get rangeRingFuelUnitLiters => 'L';

  @override
  String get rangeRingFuelUnitGallons => 'gal';

  @override
  String rangeRingFuelTankHelp(String amount, String unit) {
    return 'Réservoir par défaut ≈ $amount $unit.';
  }

  @override
  String get rangeRingAssumptionsTitle => 'Hypothèses';

  @override
  String get rangeRingSpeedKmhLabel => 'Vitesse (km/h)';

  @override
  String get rangeRingEconomyLabel => 'Consommation (L/100 km)';

  @override
  String get rangeRingEconomyHelp =>
      'Plus bas = plus efficace. Les VTT ont une conso plus élevée qu’une voiture.';

  @override
  String rangeRingTankLabel(String unit) {
    return 'Capacité du réservoir ($unit)';
  }

  @override
  String get rangeRingUseFullTank => 'Utiliser le plein';

  @override
  String get rangeRingPreviewEmpty =>
      'Saisissez une durée ou une quantité de carburant pour prévisualiser le rayon.';

  @override
  String rangeRingPreviewRadius(String distance) {
    return 'Rayon ≈ $distance';
  }

  @override
  String get rangeRingContinue => 'Continuer';

  @override
  String get rangeRingInvalidInput =>
      'Saisissez une durée ou une quantité de carburant valide.';

  @override
  String rangeRingSuggestedNameDuration(String mode, String hours) {
    return '$mode · $hours h';
  }

  @override
  String rangeRingSuggestedNameFuel(String mode, String amount, String unit) {
    return '$mode · $amount $unit';
  }

  @override
  String rangeRingSuggestedNameMode(String mode) {
    return 'Portée $mode';
  }

  @override
  String rangeRingDetailDurationHours(String hours) {
    return '$hours h';
  }

  @override
  String rangeRingDetailFuelLiters(String liters) {
    return '$liters L';
  }

  @override
  String get mapRadialAddToGeocoding => 'Ajouter à la recherche';

  @override
  String get viewshedTitle => 'Bassin de vue / RF';

  @override
  String get slopeTitle => 'Pente / tout-terrain';

  @override
  String get slopeRangeLabel => 'Portée';

  @override
  String get slopeOpacityLabel => 'Opacité';

  @override
  String get slopeModeCost => 'Coût';

  @override
  String get slopeModeSlope => 'Pente';

  @override
  String get slopeMobilityWalk => 'Marche';

  @override
  String get slopeMobilityBike => 'Vélo';

  @override
  String get slopeMobilityDrive => 'Voiture';

  @override
  String get slopeComputeAction => 'Calculer';

  @override
  String get slopeStatusReadyToCompute => 'Prêt';

  @override
  String slopeStatusComputing(int percent) {
    return 'Calcul $percent%';
  }

  @override
  String get slopeStatusReady => 'Prêt';

  @override
  String get slopeStatusMissingDem => 'Pas de données DEM d\'élévation';

  @override
  String get slopeStatusError => 'Échec de l\'analyse de pente';

  @override
  String slopeStats(String mean, String max) {
    return 'Pente moyenne $mean° · Max $max°';
  }

  @override
  String get slopeLegendHint =>
      'Vert = doux / plus facile · Rouge = raide / coûteux. Pente DEM seulement — choisissez Marche, Vélo ou Voiture.';

  @override
  String get slopeLegendHintWalk =>
      'Coût à pied : vert = facile · rouge = raide. Pente DEM seulement (pas de sentiers).';

  @override
  String get slopeLegendHintBike =>
      'Coût vélo : vert = facile · rouge = montée raide. Pente DEM seulement (pas de routes).';

  @override
  String get slopeLegendHintDrive =>
      'Coût voiture : vert = pente douce · rouge = raide pour véhicules. Pente DEM seulement (pas de réseau routier).';

  @override
  String get slopeLegendHintSlope =>
      'Angle de pente : vert = plat · rouge = raide (~35°+). Grade DEM brut, pas un coût de déplacement.';

  @override
  String get viewshedInstructions =>
      'Antenne = hauteur de l\'observateur au-dessus du sol (bâtiment + mât). Cible = hauteur AGL du récepteur/œil (0 = sol). Portée = distance à calculer. Les hauteurs et la portée suivent vos unités de mesure (Réglages).';

  @override
  String viewshedAntennaHeightLabel(String unit) {
    return 'Ant. ($unit)';
  }

  @override
  String viewshedTargetHeightLabel(String unit) {
    return 'Cible ($unit)';
  }

  @override
  String get viewshedRangeLabel => 'Portée';

  @override
  String get viewshedComputeAction => 'Calculer';

  @override
  String get viewshedStatusReadyToCompute => 'Prêt';

  @override
  String viewshedStatusComputing(int percent) {
    return 'Calcul… $percent %';
  }

  @override
  String get viewshedStatusReady => 'Prêt';

  @override
  String get viewshedStatusMissingDem => 'Pas de données DEM';

  @override
  String get viewshedStatusMissingElevation =>
      'Pas d\'altitude à l\'observateur';

  @override
  String get viewshedStatusError => 'Échec du bassin de vue';

  @override
  String viewshedObserverElevation(String ground, String eye) {
    return 'Sol $ground · œil $eye';
  }

  @override
  String get mapDeadReckoningTitle => 'Estime';

  @override
  String get mapDeadReckoningModePaces => 'Pas';

  @override
  String get mapDeadReckoningModeDistance => 'Distance';

  @override
  String get mapDeadReckoningHeadingLabel => 'Cap';

  @override
  String get mapDeadReckoningPacesLabel => 'Pas';

  @override
  String get mapDeadReckoningPaceLengthLabel => 'm/pas';

  @override
  String get mapDeadReckoningDistanceLabel => 'Dist';

  @override
  String get mapDeadReckoningPlaceMarker => 'Placer un marqueur';

  @override
  String get mapDeadReckoningCreateLine => 'Créer une ligne';

  @override
  String get mapDeadReckoningMarkerName => 'Estimation DR';

  @override
  String get mapAddToGeocodingSearch => 'Ajouter à la recherche géographique';

  @override
  String get mapCoordinatesCopied =>
      'Coordonnées copiées dans le presse-papiers.';

  @override
  String get mapMgrsCopyTooltip => 'Copier le MGRS';

  @override
  String get mapMgrsCopied => 'MGRS copié dans le presse-papiers.';

  @override
  String get mapMarkerShareUrlLabel => 'Lien';

  @override
  String get mapMarkerCopyUrlTooltip => 'Copier le lien du marqueur';

  @override
  String get mapMarkerQrButton => 'Code QR';

  @override
  String get mapMarkerQrTitle => 'Code QR du marqueur';

  @override
  String get mapMarkerQrSavePng => 'Enregistrer l\'image';

  @override
  String get mapMarkerQrSaveSvg => 'Enregistrer le vecteur';

  @override
  String get mapMarkerQrSavedPng => 'Image du code QR enregistrée.';

  @override
  String get mapMarkerQrSavedSvg => 'Vecteur du code QR enregistré.';

  @override
  String mapMarkerQrSaveFailed(String error) {
    return 'Impossible d\'enregistrer le code QR : $error';
  }

  @override
  String get mapMarkerUrlCopied =>
      'Lien du marqueur copié dans le presse-papiers.';

  @override
  String get mapMarkerIdLabel => 'ID du marqueur';

  @override
  String get mapMarkerCopyIdTooltip => 'Copier l\'ID du marqueur';

  @override
  String get mapMarkerIdCopied =>
      'ID du marqueur copié dans le presse-papiers.';

  @override
  String get mapRelativeAngleLabel => 'Rel°';

  @override
  String get sortName => 'Nom';

  @override
  String get sortCreated => 'Création';

  @override
  String get sortHue => 'Teinte';

  @override
  String get sidebarMergeLines => 'Fusionner les lignes';

  @override
  String get sidebarMergeLinesNeedTwo =>
      'Sélectionnez au moins deux lignes à fusionner.';

  @override
  String get sidebarMergeLinesDone =>
      'Lignes fusionnées. Les points de contrôle sont conservés dans l\'ordre du parcours.';

  @override
  String sidebarMergeLinesFailed(String error) {
    return 'Impossible de fusionner les lignes : $error';
  }

  @override
  String get sortIcon => 'Icône';

  @override
  String get sortVisibility => 'Visibilité';

  @override
  String get sortType => 'Type';

  @override
  String get sortGroupVisible => 'Visible';

  @override
  String get sortGroupHidden => 'Masqué';

  @override
  String get sortGroupOther => 'Autre';

  @override
  String get sidebarSortMarkers => 'Trier les marqueurs';

  @override
  String get sidebarSortZones => 'Trier les zones';

  @override
  String get rectangleSizeDimensions => 'Dimensions';

  @override
  String get rectangleSizeArea => 'Surface';

  @override
  String get rectangleSizeNone => 'Aucune';

  @override
  String get rectangleSizeDimensionsShort => 'L×H';

  @override
  String get rectangleModeCenter => 'Rectangle centré';

  @override
  String get rectangleModeCorners => 'Rectangle par coins';

  @override
  String get mapObjectTypeRectangle => 'Rectangle';

  @override
  String get mapObjectTypePolygon => 'Polygone';

  @override
  String get mapObjectTypeEvacKit => 'Kit de routes d\'évacuation';

  @override
  String get evacKitCreateTitle => 'Créer un kit de routes d\'évacuation';

  @override
  String get evacKitEditTitle => 'Modifier le kit de routes d\'évacuation';

  @override
  String get evacKitDefaultName => 'Kit d\'évacuation';

  @override
  String get evacKitNameHint => 'Point de ralliement → abri…';

  @override
  String evacKitFormHelp(int count) {
    return '$count points sur la route principale';
  }

  @override
  String evacKitEtaPreview(String mode, String eta) {
    return '$mode: $eta';
  }

  @override
  String get evacKitPrimaryRouteName => 'Principale';

  @override
  String get evacKitPrimaryRouteNameLabel => 'Nom de la route principale';

  @override
  String get evacKitDefaultModeLabel => 'Mode de déplacement par défaut';

  @override
  String get evacKitShowNameLabel => 'Afficher le nom sur la carte';

  @override
  String get evacKitAddAlternateTitle => 'Ajouter une route alternative';

  @override
  String get evacKitRouteNameLabel => 'Nom de la route';

  @override
  String evacKitAlternateRouteName(int index) {
    return 'Alternative $index';
  }

  @override
  String get evacKitDrawingHint =>
      'Touchez pour ajouter des points (ou touchez des marqueurs). Double-touche ou Terminer (2+). Annuler retire le dernier point.';

  @override
  String get evacKitDrawingFinish => 'Terminer';

  @override
  String get evacKitDrawingUndo => 'Annuler';

  @override
  String get evacKitDrawingCancel => 'Annuler';

  @override
  String get evacKitRoutesLabel => 'Routes';

  @override
  String get evacKitPrimaryBadge => 'Principale';

  @override
  String get evacKitAlternateBadge => 'Alternative';

  @override
  String get evacKitWaypointsLabel => 'Points';

  @override
  String get evacKitDistanceLabel => 'Distance';

  @override
  String get evacKitEtaLabel => 'ETA';

  @override
  String get evacKitAddAlternate => 'Ajouter une route alternative';

  @override
  String get evacKitRemoveAlternate => 'Supprimer l\'alternative';

  @override
  String get evacKitRemoveAlternateConfirm =>
      'Supprimer cette route alternative du kit ?';

  @override
  String get evacKitRemoveRoute => 'Supprimer la route';

  @override
  String get evacKitRemovePrimaryConfirm =>
      'Supprimer la route principale ? Choisissez quelle alternative devient la nouvelle principale.';

  @override
  String evacKitRemovePrimarySingleConfirm(String name) {
    return 'Supprimer la route principale ? « $name » deviendra la principale.';
  }

  @override
  String get evacKitChooseNewPrimary => 'Nouvelle route principale';

  @override
  String get evacKitMakePrimary => 'Définir comme principale';

  @override
  String evacKitMakePrimaryConfirm(String name) {
    return 'Définir « $name » comme route principale ? L\'actuelle devient une alternative.';
  }

  @override
  String get evacKitCannotRemoveLastRoute =>
      'Un kit doit conserver au moins une route.';

  @override
  String get evacKitEditRouteOnMap => 'Modifier la route sur la carte';

  @override
  String get evacKitEditingHint =>
      'Glisser un waypoint ou un point de contrôle pour déplacer · toucher un segment pour ajouter un point de contrôle · double-tapper un point intermédiaire pour convertir waypoint ↔ contrôle · toucher le dernier waypoint pour prolonger · appui long pour retirer (min. 2 waypoints) · Terminé quand fini';

  @override
  String get evacKitExtendingHint =>
      'Touchez la carte ou des marqueurs pour ajouter des points à la fin. Terminé arrête le prolongement.';

  @override
  String get sidebarEditEvacKit => 'Modifier le kit d\'évacuation';

  @override
  String get sidebarDeleteEvacKit => 'Supprimer le kit d\'évacuation';

  @override
  String get polygonCreateTitle => 'Créer un polygone AOI';

  @override
  String get polygonEditTitle => 'Modifier le polygone AOI';

  @override
  String get polygonDefaultName => 'Polygone';

  @override
  String get polygonNameHint =>
      'Limite, secteur de patrouille, zone interdite…';

  @override
  String polygonVertexCount(int count) {
    return '$count sommets';
  }

  @override
  String get polygonDrawingHint =>
      'Touchez pour ajouter des sommets. Double-touche ou Terminer (3+). Annuler retire le dernier point.';

  @override
  String get polygonFinishAction => 'Terminer';

  @override
  String get polygonUndoAction => 'Annuler';

  @override
  String get sidebarHidePolygon => 'Masquer le polygone';

  @override
  String get sidebarShowPolygon => 'Afficher le polygone';

  @override
  String get sidebarEditPolygon => 'Modifier le polygone';

  @override
  String get sidebarDeletePolygon => 'Supprimer le polygone';

  @override
  String get mapObjectDetailVertices => 'Sommets';

  @override
  String get searchSubtitleCoordinates => 'Coordonnées';

  @override
  String get searchSubtitleMgrs => 'MGRS';

  @override
  String get searchSubtitleMarker => 'Marqueur';

  @override
  String searchSubtitleZone(String type) {
    return 'Zone ($type)';
  }

  @override
  String searchHint(String example) {
    return 'Rechercher des lieux, marqueurs, zones, lat/lng ou MGRS (p. ex. $example)';
  }

  @override
  String get sortGroupDigits => '0-9';

  @override
  String get markerIconPlace => 'Lieu';

  @override
  String get markerIconHome => 'Maison';

  @override
  String get markerIconHouse => 'Habitation';

  @override
  String get markerIconApartment => 'Appartement';

  @override
  String get markerIconCity => 'Ville';

  @override
  String get markerIconTown => 'Bourg';

  @override
  String get markerIconWork => 'Travail';

  @override
  String get markerIconSchool => 'École';

  @override
  String get markerIconStore => 'Magasin';

  @override
  String get markerIconFood => 'Restaurant';

  @override
  String get markerIconCafe => 'Café';

  @override
  String get markerIconHotel => 'Hôtel';

  @override
  String get markerIconChurch => 'Église';

  @override
  String get markerIconMosque => 'Mosquée';

  @override
  String get markerIconCommunity => 'Communauté';

  @override
  String get markerIconMedical => 'Hôpital';

  @override
  String get markerIconVehicle => 'Véhicule';

  @override
  String get markerIconBike => 'Vélo';

  @override
  String get markerIconTrail => 'Sentier';

  @override
  String get markerIconPark => 'Parc';

  @override
  String get markerIconMonument => 'Monument';

  @override
  String get markerIconGeocache => 'Géocache';

  @override
  String get markerIconFlag => 'Drapeau';

  @override
  String get markerIconStar => 'Étoile';

  @override
  String get markerIconFavorite => 'Favori';

  @override
  String get markerIconWarning => 'Avertissement';

  @override
  String get markerIconInfo => 'Info';

  @override
  String get markerIconLocation => 'Position';

  @override
  String get markerIconPhoto => 'Caméra';

  @override
  String get markerIconPets => 'Animaux';

  @override
  String get markerIconMan => 'Homme';

  @override
  String get markerIconWoman => 'Femme';

  @override
  String get markerIconBoy => 'Garçon';

  @override
  String get markerIconGirl => 'Fille';

  @override
  String get markerIconCat => 'Chat';

  @override
  String get markerIconDog => 'Chien';

  @override
  String get markerIconRadioTower => 'Tour radio';

  @override
  String get markerIconCellTower => 'Tour cellulaire';

  @override
  String get markerIconRadioStation => 'Station radio';

  @override
  String get markerIconRadioRepeater => 'Répéteur radio';

  @override
  String get markerIconMeshNetworkNode => 'Nœud maillé';

  @override
  String get markerIconWater => 'Eau';

  @override
  String get markerIconSupplyCache => 'Cache de ravitaillement';

  @override
  String get markerIconRetreat => 'Retraite';

  @override
  String get markerIconCamp => 'Camp';

  @override
  String get markerIconFuel => 'Carburant';

  @override
  String get markerIconGate => 'Portail';

  @override
  String get markerIconCrossing => 'Traversée';

  @override
  String get markerIconLookout => 'Poste d\'observation';

  @override
  String get markerIconPower => 'Énergie';

  @override
  String get markerIconPowerPlant => 'Centrale électrique';

  @override
  String get markerIconNuclear => 'Nucléaire';

  @override
  String get markerIconNuclearPowerPlant => 'Centrale nucléaire';

  @override
  String get markerIconNuclearWeaponsFacility =>
      'Installation nucléaire d\'armes';

  @override
  String get markerIconGarden => 'Jardin';

  @override
  String get markerIconStaging => 'Zone de rassemblement';

  @override
  String get markerIconHazard => 'Danger';

  @override
  String get markerIconRestricted => 'Interdit';

  @override
  String get markerIconRally => 'Point de rendez-vous';

  @override
  String get markerIconWorkshop => 'Atelier';

  @override
  String get markerIconBoat => 'Bateau';

  @override
  String get markerIconPort => 'Port';

  @override
  String get markerIconDock => 'Quai';

  @override
  String get markerIconFerry => 'Ferry';

  @override
  String get markerIconYacht => 'Yacht';

  @override
  String get markerIconSailboat => 'Voilier';

  @override
  String get markerIconRiverBoat => 'Bateau fluvial';

  @override
  String get markerIconAirstrip => 'Piste / Aéroport';

  @override
  String get markerIconDefense => 'Défense';

  @override
  String get markerIconArmyBase => 'Base de l\'Armée';

  @override
  String get markerIconNavyBase => 'Base navale';

  @override
  String get markerIconMarineCorpsBase => 'Base du Corps des Marines';

  @override
  String get markerIconAirForceBase => 'Base de l\'Armée de l\'air';

  @override
  String get markerIconSpaceForceBase => 'Base de l\'espace';

  @override
  String get markerIconCoastGuardBase => 'Base de la Garde côtière';

  @override
  String get markerIconHunting => 'Chasse';

  @override
  String get markerIconFishing => 'Pêche';

  @override
  String get markerIconForaging => 'Cueillette';

  @override
  String get markerIconCave => 'Grotte';

  @override
  String get markerIconDeadZone => 'Zone sans signal';

  @override
  String get markerIconEvacRoute => 'Route d\'évacuation';

  @override
  String get markerIconLivestock => 'Bétail';

  @override
  String get markerIconPharmacy => 'Pharmacie';

  @override
  String get markerIconClinic => 'Clinique';

  @override
  String get markerIconDentist => 'Dentiste';

  @override
  String get markerIconDoctorsOffice => 'Cabinet médical';

  @override
  String get markerIconEyeDoctor => 'Ophtalmologue';

  @override
  String get markerIconOnFoot => 'À pied';

  @override
  String get markerIconHorse => 'Cheval';

  @override
  String get markerIconMotorcycle => 'Moto';

  @override
  String get markerIconAtv => 'VTT';

  @override
  String get markerIconTruck => 'Camion';

  @override
  String get markerIconBus => 'Bus';

  @override
  String get markerIconRv => 'Camping-car';

  @override
  String get markerIconTrain => 'Train';

  @override
  String get markerIconAmbulance => 'Ambulance';

  @override
  String get markerIconFireTruck => 'Camion de pompiers';

  @override
  String get markerIconFarmVehicle => 'Véhicule agricole';

  @override
  String get markerIconCanoe => 'Canoë';

  @override
  String get markerIconHelicopter => 'Hélicoptère';

  @override
  String get markerIconAirplane => 'Avion';

  @override
  String get markerIconGlider => 'Planeur';

  @override
  String get markerIconBalloon => 'Montgolfière';

  @override
  String get markerIconFalloutShelter => 'Abri antiatomique';

  @override
  String get markerIconStormShelter => 'Abri anti-tempête';

  @override
  String get markerIconBunker => 'Bunker';

  @override
  String get markerIconWaterWell => 'Puits';

  @override
  String get markerIconCistern => 'Citerne';

  @override
  String get markerIconRootCellar => 'Cellier';

  @override
  String get markerIconGreenhouse => 'Serre';

  @override
  String get markerIconFuelDepot => 'Dépôt de carburant';

  @override
  String get markerIconTruckStop => 'Relais routier';

  @override
  String get markerIconRestStop => 'Aire de repos';

  @override
  String get markerIconEvChargingStation => 'Borne de recharge VE';

  @override
  String get markerIconWindTurbine => 'Éolienne';

  @override
  String get markerIconHamShack => 'Station radioamateur';

  @override
  String get markerIconSecurityPost => 'Poste de sécurité';

  @override
  String get markerIconMedicalCache => 'Cache médical';

  @override
  String get markerIconFirewoodCache => 'Réserve de bois';

  @override
  String get markerIconGrainSilo => 'Silo à grains';

  @override
  String get markerIconSafeRoom => 'Pièce sécurisée';

  @override
  String get markerIconDeconStation => 'Station de décontamination';

  @override
  String get markerIconPublicRestroom => 'Toilettes publiques';

  @override
  String get markerIconOuthouse => 'Cabane sanitaire';

  @override
  String get markerIconLatrine => 'Latrine';

  @override
  String get markerIconCompostingToilet => 'Toilettes à compost';

  @override
  String get markerIconHandWashStation => 'Station de lavage des mains';

  @override
  String get markerIconSepticTank => 'Fosse septique';

  @override
  String get markerIconPortableToilet => 'Toilettes portables';

  @override
  String get markerIconAmmoCache => 'Cache de munitions';

  @override
  String get markerIconPoliceDepartment => 'Commissariat';

  @override
  String get markerIconPostOffice => 'Bureau de poste';

  @override
  String get markerIconArmory => 'Armurerie';

  @override
  String get markerIconPrison => 'Prison';

  @override
  String get markerIconJail => 'Geôle';

  @override
  String get markerIconCollege => 'Université';

  @override
  String get markerIconFireStation => 'Caserne de pompiers';

  @override
  String get markerIconCourthouse => 'Palais de justice';

  @override
  String get markerIconLibrary => 'Bibliothèque';

  @override
  String get markerIconBank => 'Banque';

  @override
  String get markerIconCemetery => 'Cimetière';

  @override
  String get markerIconWildfire => 'Feu de forêt';

  @override
  String get markerIconTornado => 'Tornade';

  @override
  String get markerIconHurricane => 'Ouragan';

  @override
  String get markerIconFlood => 'Inondation';

  @override
  String get markerIconStorm => 'Tempête';

  @override
  String get markerIconEarthquake => 'Tremblement de terre';

  @override
  String get markerIconVolcano => 'Volcan';

  @override
  String get markerIconTsunami => 'Tsunami';

  @override
  String get markerIconLandslide => 'Glissement de terrain';

  @override
  String get markerIconDrought => 'Sécheresse';

  @override
  String get markerIconBlizzard => 'Blizzard';

  @override
  String get markerIconHail => 'Grêle';

  @override
  String get markerIconSnow => 'Neige';

  @override
  String get markerIconIcyRoad => 'Route verglacée';

  @override
  String get markerIconTreeDown => 'Arbre tombé';

  @override
  String get markerIconPowerLineDown => 'Ligne électrique tombée';

  @override
  String get markerIconHighWind => 'Vent fort';

  @override
  String get markerIconIceStorm => 'Tempête de verglas';

  @override
  String get markerIconRoadBlocked => 'Route bloquée';

  @override
  String get markerIconPowerOutage => 'Panne de courant';

  @override
  String get markerIconWeatherStation => 'Station météo';

  @override
  String get settingsRestApiTitle => 'Accès à l\'API REST';

  @override
  String get settingsRestApiPermissionDenied =>
      'Vous n\'avez pas l\'autorisation de gérer les clés d\'API REST.';

  @override
  String get settingsRestApiDescription =>
      'Protégez les endpoints REST /api avec des clés nommées. Créez une clé distincte pour chaque app ou appareil afin de pouvoir en révoquer une sans affecter les autres.';

  @override
  String get settingsRestApiStatusLabel => 'Protection';

  @override
  String get settingsRestApiStatusEnabled => 'Activée';

  @override
  String get settingsRestApiStatusDisabled => 'Désactivée';

  @override
  String get settingsRestApiKeysTitle => 'Clés API';

  @override
  String get settingsRestApiKeysEmpty =>
      'Aucune clé API pour l\'instant. Créez-en une pour chaque app ou appareil qui appelle l\'API REST.';

  @override
  String get settingsRestApiCreateAction => 'Créer une clé API';

  @override
  String get settingsRestApiCreateNameLabel => 'Nom de l\'application';

  @override
  String get settingsRestApiCreateNameHint => 'p. ex. Traceur GPS, Domotique';

  @override
  String get settingsRestApiDeleteAction => 'Supprimer';

  @override
  String get settingsRestApiDeleteConfirmTitle => 'Supprimer la clé API ?';

  @override
  String settingsRestApiDeleteConfirmMessage(String name) {
    return 'La clé « $name » cessera de fonctionner immédiatement. Les autres clés ne sont pas affectées.';
  }

  @override
  String get settingsRestApiDeleted => 'Clé API supprimée.';

  @override
  String get settingsRestApiEnvKeyNote =>
      'Une clé API d\'environnement est aussi configurée sur le serveur. Elle ne peut pas être supprimée depuis cet écran.';

  @override
  String get settingsRestApiClearAction => 'Supprimer toutes les clés';

  @override
  String get settingsRestApiClearConfirmTitle =>
      'Supprimer toutes les clés API ?';

  @override
  String get settingsRestApiClearConfirmMessage =>
      'Toutes les clés stockées seront supprimées. L\'API REST sera ouverte sauf si une clé d\'environnement est configurée.';

  @override
  String get settingsRestApiCleared =>
      'Toutes les clés stockées ont été supprimées.';

  @override
  String get settingsRestApiGeneratedTitle => 'Nouvelle clé API';

  @override
  String settingsRestApiGeneratedFor(String name) {
    return 'Créée pour $name.';
  }

  @override
  String get settingsRestApiGeneratedMessage =>
      'Copiez cette clé maintenant. Elle n\'est affichée qu\'une fois. Utilisez-la comme X-API-Key ou Authorization: Bearer <clé>.';

  @override
  String get settingsRestApiCopyAction => 'Copier la clé';

  @override
  String get settingsRestApiCopied => 'Clé API copiée.';

  @override
  String settingsRestApiLoadFailed(String error) {
    return 'Impossible de charger les paramètres de l\'API REST : $error';
  }

  @override
  String get settingsRestApiClientKeyTitle => 'Clé sur cet appareil';

  @override
  String get settingsRestApiClientKeyDescription =>
      'Enregistrez la clé ici pour que cette app puisse utiliser les replis REST (restauration de sauvegarde, sync des paramètres, etc.).';

  @override
  String get settingsRestApiClientKeyLabel => 'Clé API';

  @override
  String get settingsRestApiSaveClientKeyAction =>
      'Enregistrer la clé sur cet appareil';

  @override
  String get settingsRestApiKeySaved => 'Clé API enregistrée sur cet appareil.';

  @override
  String get seasonalOverlayCreateTitle => 'Create seasonal overlay';

  @override
  String get seasonalOverlayEditTitle => 'Edit seasonal overlay';

  @override
  String get seasonalOverlayDefaultName => 'Seasonal area';

  @override
  String seasonalOverlayVertexCount(int count) {
    return '$count vertices';
  }

  @override
  String get seasonalOverlayDrawingHint =>
      'Tap to add vertices for this seasonal area. Double-tap or Finish when you have 3+ points.';

  @override
  String get seasonalOverlayDateMode => 'Date mode';

  @override
  String get seasonalOverlayDateModeAbsolute => 'Absolute';

  @override
  String get seasonalOverlayDateModeRecurring => 'Recurring';

  @override
  String get seasonalOverlayWindows => 'Date windows';

  @override
  String get seasonalOverlayAddWindow => 'Add window';

  @override
  String get seasonalOverlayEditWindow => 'Edit date window';

  @override
  String get seasonalOverlayStartDate => 'Start date';

  @override
  String get seasonalOverlayEndDate => 'End date';

  @override
  String get seasonalOverlayStartMonth => 'Start month';

  @override
  String get seasonalOverlayStartDay => 'Start day';

  @override
  String get seasonalOverlayEndMonth => 'End month';

  @override
  String get seasonalOverlayEndDay => 'End day';

  @override
  String get seasonalOverlayRecurringHint =>
      'Month/day each year. Ranges may wrap across New Year.';

  @override
  String get seasonalOverlayStatusActive => 'In season';

  @override
  String get seasonalOverlayStatusInactive => 'Out of season';

  @override
  String seasonalOverlayWindowCount(int count) {
    return '$count window(s)';
  }

  @override
  String get seasonalOverlayHide => 'Hide overlay';

  @override
  String get seasonalOverlayShow => 'Show overlay';

  @override
  String get seasonalOverlayZoomTo => 'Zoom to overlay';

  @override
  String get seasonalOverlayDeleteTitle => 'Delete seasonal overlay?';

  @override
  String seasonalOverlayDeleteConfirm(String name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get seasonalOverlaysSettingsTitle => 'Seasonal overlays';

  @override
  String get seasonalOverlaysSettingsSubtitle =>
      'Dated polygon layers for hunting seasons, freeze/thaw windows, and other recurring or one-time map seasons. Stored on the server and included in map backups.';

  @override
  String get seasonalOverlaysShowInactive => 'Show out-of-season overlays';

  @override
  String get seasonalOverlaysShowInactiveHint =>
      'When off, overlays outside their date windows stay hidden even if enabled.';

  @override
  String get seasonalOverlaysDrawHint =>
      'Long-press the map → More → More → Season, then draw a polygon and set date windows.';

  @override
  String get seasonalOverlaysInstalled => 'Overlays';

  @override
  String get seasonalOverlaysEmpty => 'No seasonal overlays yet.';

  @override
  String seasonalOverlaysLoadFailed(String error) {
    return 'Could not load seasonal overlays: $error';
  }

  @override
  String get sidebarSeasonalOverlays => 'Seasonal overlays';

  @override
  String get sidebarSeasonalOverlaysLoading => 'Loading…';

  @override
  String sidebarSeasonalOverlaysCount(int count) {
    return '$count overlay(s)';
  }

  @override
  String get routingTitle => 'Itinéraires';

  @override
  String get routingPermissionDenied =>
      'Vous n\'avez pas la permission de configurer le serveur d\'itinéraires.';

  @override
  String get routingServerConnectionTitle => 'Serveur d\'itinéraires';

  @override
  String get routingServerConnectionDescription =>
      'Serveur de calcul d\'itinéraires OSM hors ligne (GraphHopper), séparé de votre serveur principal. Importez une région une fois, puis les clients du réseau local peuvent calculer des itinéraires depuis cet hôte sans accès internet.';

  @override
  String get routingServerUrlLabel => 'URL web du serveur d\'itinéraires';

  @override
  String get routingSaveServerUrl =>
      'Enregistrer l\'URL du serveur d\'itinéraires';

  @override
  String get routingServerUrlSaved =>
      'URL du serveur d\'itinéraires enregistrée.';

  @override
  String get routingStatusTitle => 'État de l\'import';

  @override
  String get routingStatusIdle => 'Non importé';

  @override
  String get routingStatusChecking => 'Vérification du serveur d\'itinéraires…';

  @override
  String get routingStatusDownloading => 'Téléchargement…';

  @override
  String routingImportProgressPercent(String percent) {
    return '$percent %';
  }

  @override
  String get routingStatusBuilding => 'Construction du graphe d\'itinéraires…';

  @override
  String get routingStatusReady => 'Prêt';

  @override
  String get routingStatusFailed => 'Échec';

  @override
  String get routingStatusCancelled => 'Annulé';

  @override
  String get routingImportTitle => 'Importer les données cartographiques';

  @override
  String get routingImportDescription =>
      'Importez une ou plusieurs régions OSM et construisez le graphe hors ligne. Préférez des États américains ; sélectionnez plusieurs États frontaliers (ex. Virginie + Virginie-Occidentale) pour les fusionner en un seul graphe.';

  @override
  String get routingMultiStateHint =>
      'Recherchez et ajoutez des États un par un. Plusieurs États sont téléchargés, fusionnés avec Osmium, puis construits en un seul graphe — inutile d\'importer tous les États-Unis.';

  @override
  String get routingSelectedStatesLabel => 'États sélectionnés';

  @override
  String routingMultiStateMergeHint(int count) {
    return '$count États seront fusionnés en un seul graphe.';
  }

  @override
  String routingImportMultiAction(int count) {
    return 'Importer $count États';
  }

  @override
  String get routingRegionSearchHint => 'Rechercher un État ou une région…';

  @override
  String get routingLocalOsmHint =>
      'Pour les gros extraits nationaux, téléchargez ailleurs puis copiez osm.pbf dans le dossier de données du serveur, ou téléversez-le ici. Le graphe est stocké sur le disque de ce serveur (MMAP) — pas de base Postgres.';

  @override
  String routingOsmOnServerHint(String size) {
    return 'Extrait OSM sur le serveur : $size';
  }

  @override
  String get routingUploadOsmAction => 'Téléverser un fichier OSM';

  @override
  String get routingBuildFromLocalAction =>
      'Construire depuis le fichier serveur';

  @override
  String get routingOsmUploadStarted =>
      'Téléversement OSM démarré ; la construction du graphe suivra.';

  @override
  String routingOsmUploadFailed(String error) {
    return 'Échec du téléversement OSM : $error';
  }

  @override
  String get routingRegionLabel => 'Région';

  @override
  String get routingCustomRegionLabel => 'Région personnalisée';

  @override
  String get routingCustomUrlLabel => 'URL d\'extrait OSM personnalisée';

  @override
  String get routingRegionOrUrlRequired =>
      'Choisissez une ou plusieurs régions, ou saisissez une URL d\'extrait OSM personnalisée.';

  @override
  String get routingImportAction => 'Importer la région';

  @override
  String get routingCancelImport => 'Annuler l\'import';

  @override
  String get routingImportStarted => 'Import d\'itinéraires démarré.';

  @override
  String routingImportFailed(String error) {
    return 'L\'import d\'itinéraires a échoué : $error';
  }

  @override
  String routingAbortFailed(String error) {
    return 'Échec de l\'annulation : $error';
  }

  @override
  String get routingServerUnreachable =>
      'Impossible de joindre le serveur d\'itinéraires. Vérifiez qu\'il est en cours d\'exécution et accessible depuis votre navigateur.';

  @override
  String get routingNotConfigured =>
      'Configurez une URL de serveur d\'itinéraires pour activer le calcul d\'itinéraires.';

  @override
  String get routingNotReady =>
      'Le serveur d\'itinéraires n\'a pas encore terminé l\'import des données cartographiques.';

  @override
  String get routingReadyHint =>
      'Prêt pour le calcul d\'itinéraires. Les clients du réseau local peuvent calculer des itinéraires depuis cet hôte sans accès internet.';

  @override
  String get routingRouteHereAction => 'Itinéraire vers ici';

  @override
  String get routingProfilePickerTitle => 'Mode de déplacement';

  @override
  String get routingProfilePickerDescription =>
      'Choisissez comment calculer l\'itinéraire depuis votre position actuelle jusqu\'à cet endroit.';

  @override
  String get routingProfileFoot => 'À pied';

  @override
  String get routingProfileBike => 'Vélo';

  @override
  String get routingProfileCar => 'Voiture';

  @override
  String routingRouteRequestFailed(String error) {
    return 'La demande d\'itinéraire a échoué : $error';
  }

  @override
  String routingRouteSummary(String distance, String duration) {
    return '$distance · $duration';
  }

  @override
  String routingRouteSummaryWithProfile(
    String profile,
    String distance,
    String duration,
  ) {
    return '$profile · $distance · $duration';
  }

  @override
  String get routingClearRouteAction => 'Effacer l\'itinéraire';

  @override
  String get routingDirectionsTitle => 'Itinéraire';

  @override
  String get routingDirectionsEmpty =>
      'Aucune instruction pas à pas n\'a été renvoyée pour cet itinéraire.';

  @override
  String get commsPlanTitle => 'Plan de communications';

  @override
  String get commsPlanSidebarLoading => 'Chargement…';

  @override
  String get commsPlanSidebarEmpty => 'Aucun plan actif';

  @override
  String get commsPlanSidebarLoadFailed => 'Impossible de charger les plans';

  @override
  String commsPlanSidebarSubtitle(String name, int count) {
    return '$name · $count canal(aux)';
  }

  @override
  String get commsPlanOfflineHint =>
      'Les plans de communications ne sont pas encore disponibles hors ligne.';

  @override
  String get commsPlanAddPlan => 'Ajouter un plan';

  @override
  String get commsPlanEditPlan => 'Modifier le tableau';

  @override
  String get commsPlanEmpty =>
      'Aucun plan de communications pour l\'instant. Ajoutez un tableau pour les horaires de nets, fréquences et canaux go/no-go.';

  @override
  String commsPlanLoadFailed(String error) {
    return 'Impossible de charger les plans : $error';
  }

  @override
  String commsPlanBoardHeader(String name, String timezone) {
    return '$name ($timezone)';
  }

  @override
  String get commsPlanOtherPlans => 'Autres plans';

  @override
  String commsPlanChannelsCount(int count) {
    return '$count canal(aux)';
  }

  @override
  String get commsPlanMakeActive => 'Définir comme tableau actif';

  @override
  String get commsPlanDeleteConfirmTitle =>
      'Supprimer le plan de communications ?';

  @override
  String commsPlanDeleteConfirmMessage(String name) {
    return 'Supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String get commsPlanUnscheduled => 'Non planifié';

  @override
  String commsPlanNextNet(String when) {
    return 'Prochain $when';
  }

  @override
  String get commsPlanCreateTitle => 'Nouveau plan de communications';

  @override
  String get commsPlanEditTitle => 'Modifier le plan de communications';

  @override
  String get commsPlanNameLabel => 'Nom du plan';

  @override
  String get commsPlanNameRequired => 'Saisissez un nom de plan.';

  @override
  String get commsPlanTimezoneLabel => 'Fuseau horaire';

  @override
  String get commsPlanTimezoneHint =>
      'Nom IANA pour les horaires (ex. America/New_York)';

  @override
  String get commsPlanActiveLabel => 'Tableau actif';

  @override
  String get commsPlanActiveHint =>
      'Afficher ce plan comme tableau opérationnel du TOC';

  @override
  String get commsPlanNotesLabel => 'Notes du plan';

  @override
  String get commsPlanChannelsHeading => 'Canaux';

  @override
  String get commsPlanChannelsEmpty => 'Aucun canal pour l\'instant.';

  @override
  String get commsPlanAddChannel => 'Ajouter un canal';

  @override
  String commsPlanSaveFailed(String error) {
    return 'Impossible d\'enregistrer le plan : $error';
  }

  @override
  String get commsPlanChannelCreateTitle => 'Ajouter un canal';

  @override
  String get commsPlanChannelEditTitle => 'Modifier le canal';

  @override
  String get commsPlanChannelLabel => 'Libellé du canal';

  @override
  String get commsPlanChannelLabelRequired => 'Saisissez un libellé de canal.';

  @override
  String get commsPlanChannelNetName => 'Nom du net';

  @override
  String get commsPlanChannelRole => 'Rôle';

  @override
  String get commsPlanChannelDays => 'Jours de net';

  @override
  String get commsPlanChannelDaysHint =>
      'Laissez tout désélectionné pour tous les jours (si une heure de début est définie).';

  @override
  String get commsPlanChannelStartTime => 'Début (local)';

  @override
  String get commsPlanChannelDuration => 'Durée (min)';

  @override
  String get commsPlanChannelAvailability => 'Go / no-go';

  @override
  String get commsPlanChannelStatusNote => 'Note d\'état';

  @override
  String get commsPlanChannelLinkedMarker => 'Marqueur lié';

  @override
  String get commsPlanChannelNoMarker => 'Aucun';

  @override
  String get commsPlanChannelNotes => 'Notes';

  @override
  String get commsPlanRolePrimary => 'Principal';

  @override
  String get commsPlanRoleAlternate => 'Alternatif';

  @override
  String get commsPlanRoleEmergency => 'Urgence';

  @override
  String get commsPlanRoleTactical => 'Tactique';

  @override
  String get commsPlanRoleLiaison => 'Liaison';

  @override
  String get commsPlanAvailabilityGo => 'Go';

  @override
  String get commsPlanAvailabilityNoGo => 'No-go';

  @override
  String get commsPlanAvailabilityConditional => 'Conditionnel';

  @override
  String get commsPlanAvailabilityUnknown => 'Inconnu';

  @override
  String get commsPlanWeekdayMon => 'Lun';

  @override
  String get commsPlanWeekdayTue => 'Mar';

  @override
  String get commsPlanWeekdayWed => 'Mer';

  @override
  String get commsPlanWeekdayThu => 'Jeu';

  @override
  String get commsPlanWeekdayFri => 'Ven';

  @override
  String get commsPlanWeekdaySat => 'Sam';

  @override
  String get commsPlanWeekdaySun => 'Dim';
}
