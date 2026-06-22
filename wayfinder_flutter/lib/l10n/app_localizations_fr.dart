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
  String get settingsTabGeocoding => 'Géocodage';

  @override
  String get settingsTabBackup => 'Sauvegarde';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionReset => 'Réinitialiser';

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
      'Choisissez un thème de couleur pour l\'application. Les thèmes militaires utilisent des tons olive, sable et vert forêt. Enregistré sur le serveur pour que chaque navigateur utilise le même thème.';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageDescription =>
      'Choisissez la langue utilisée dans l\'application. Enregistrée sur le serveur pour que chaque navigateur utilise la même langue.';

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
      'URL du serveur API Wayfinder, y compris l\'hôte et le port. L\'URL du serveur web (API REST et PMTiles) est dérivée automatiquement (port API + 2). Redémarrez l\'application après modification.';

  @override
  String get settingsServerUrl => 'URL du serveur';

  @override
  String settingsCurrentWebServer(String webUrl) {
    return 'Serveur web actuel : $webUrl';
  }

  @override
  String get settingsSaveServerUrl => 'Enregistrer l\'URL du serveur';

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
  String get settingsCirclesTitle => 'Cercles';

  @override
  String get settingsCirclesDescription =>
      'Choisissez l\'étiquette de taille par défaut affichée sur les nouvelles zones circulaires. Enregistré sur le serveur pour que chaque navigateur utilise la même valeur par défaut.';

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
  String get backupTitle => 'Sauvegarde des données cartographiques';

  @override
  String get backupDescription =>
      'Exporter ou restaurer toutes les couches, marqueurs et zones. Vous pouvez aussi sauvegarder avec curl : GET /api/map-data';

  @override
  String get backupExportButton => 'Exporter les données (.json)';

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
      'Cela remplace toutes les couches, marqueurs et zones sur le serveur par le fichier de sauvegarde sélectionné. Cette action est irréversible.';

  @override
  String backupRestoreSuccess(int layers, int markers, int zones) {
    return '$layers couche(s), $markers marqueur(s) et $zones zone(s) restauré(s).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

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
      'Organisez les archives cartographiques hors ligne en groupes et choisissez lesquelles sont affichées sur la carte. Une seule archive activée correspondante est affichée à la fois pour garder la carte réactive.';

  @override
  String get mapTilesUploadButton => 'Téléverser un fichier .pmtiles';

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
  String get circleDefaultName => 'Nouveau cercle';

  @override
  String get circleNameHint => 'p. ex. Zone de recherche, Limite de propriété';

  @override
  String get circleMeasurementsLabel => 'Mesures';

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
  String get mapSettingsTooltip => 'Paramètres';

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
  String get mapObjectTypeCircle => 'Cercle';

  @override
  String get mapObjectDetailCoordinates => 'Coordonnées';

  @override
  String get mapObjectDetailElevation => 'Altitude';

  @override
  String get mapObjectDetailVisibility => 'Visibilité';

  @override
  String get mapObjectVisibilityVisible => 'Visible';

  @override
  String get mapObjectVisibilityHidden => 'Masqué';

  @override
  String get mapObjectDetailLength => 'Longueur';

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
  String get searchReadinessFullReadyTitle => 'Recherche complète prête';

  @override
  String get searchReadinessAddressReadyTitle => 'Recherche d\'adresses prête';

  @override
  String get searchReadinessNotReadyTitle => 'Recherche pas encore prête';

  @override
  String searchReadinessIndexesBuilt(int ready, int total) {
    return 'Index construits : $ready sur $total';
  }

  @override
  String get searchReadinessCheckingStatus =>
      'Vérification de l\'état de la recherche…';

  @override
  String get searchReadinessFullReadyMessage =>
      'Vous pouvez rechercher des lieux et des adresses postales depuis la barre de recherche de la carte.';

  @override
  String get searchReadinessAddressOnlyMessage =>
      'La recherche d\'adresses est prête. La recherche de noms de lieux est encore en préparation.';

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
      'Téléchargez les données OSMNames sur le serveur pour la recherche hors ligne. Les noms de lieux et les adresses postales sont importés séparément.';

  @override
  String get geocodingPlacesSectionTitle => 'Noms de lieux (geonames.tsv)';

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
  String get mapRelativeAngleLabel => 'Rel°';

  @override
  String get sortName => 'Nom';

  @override
  String get sortHue => 'Teinte';

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
  String get searchSubtitleCoordinates => 'Coordonnées';

  @override
  String get searchSubtitleMarker => 'Marqueur';

  @override
  String searchSubtitleZone(String type) {
    return 'Zone ($type)';
  }

  @override
  String searchHint(String example) {
    return 'Rechercher des lieux, marqueurs, zones ou lat, lng (p. ex. $example)';
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
  String get markerIconMedical => 'Médical';

  @override
  String get markerIconVehicle => 'Véhicule';

  @override
  String get markerIconBike => 'Vélo';

  @override
  String get markerIconTrail => 'Sentier';

  @override
  String get markerIconPark => 'Parc';

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
  String get markerIconPhoto => 'Photo';

  @override
  String get markerIconPets => 'Animaux';

  @override
  String get markerIconRadioTower => 'Tour radio';

  @override
  String get markerIconRadioRepeater => 'Répéteur radio';
}
