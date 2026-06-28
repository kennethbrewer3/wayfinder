// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Wayfinder';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabMapTiles => 'Mosaicos del mapa';

  @override
  String get settingsTabGeocoding => 'Geocodificación';

  @override
  String get settingsTabBackup => 'Copia de seguridad';

  @override
  String get settingsTabAbout => 'Acerca de';

  @override
  String get settingsAboutTitle => 'Acerca de Wayfinder';

  @override
  String get settingsAboutDescription =>
      'Detalles de compilación y conexión de solo lectura para este cliente. Use el commit de git para confirmar si se está ejecutando la compilación más reciente.';

  @override
  String get settingsAboutLoading => 'Cargando información de la app…';

  @override
  String settingsAboutLoadFailed(String error) {
    return 'No se pudo cargar la información de la app: $error';
  }

  @override
  String get settingsAboutAppSection => 'Aplicación';

  @override
  String get settingsAboutConnectionSection => 'Conexión';

  @override
  String get settingsAboutDeploymentSection => 'Despliegue';

  @override
  String get settingsAboutDockerImageId => 'ID de imagen Docker';

  @override
  String get settingsAboutDockerImageIdUnavailable =>
      'No disponible — recree el contenedor después de hacer pull para registrar el ID de imagen al iniciar.';

  @override
  String get settingsAboutDockerImageRef => 'Referencia de imagen Docker';

  @override
  String get settingsAboutContainerStarted => 'Contenedor iniciado';

  @override
  String settingsAboutDockerImageIdHint(String imageIdPrefix) {
    return 'El ID de imagen Docker cambia cada vez que descarga una compilación nueva. Debería empezar con $imageIdPrefix y coincidir con la columna IMAGE ID de docker compose images o docker image inspect.';
  }

  @override
  String get settingsAboutDockerImageIdHintUnavailable =>
      'Después de docker compose pull, ejecute docker compose up -d --force-recreate para que el contenedor registre aquí el ID de imagen actual. El ID cambia en cada compilación nueva aunque la etiqueta siga siendo :latest.';

  @override
  String get settingsAboutAppName => 'Nombre de la app';

  @override
  String get settingsAboutVersion => 'Versión';

  @override
  String get settingsAboutGitCommit => 'Commit de git';

  @override
  String get settingsAboutGitCommitUnavailable =>
      'No disponible (compilación local de desarrollo)';

  @override
  String get settingsAboutBuildTime => 'Compilada';

  @override
  String get settingsAboutPlatform => 'Plataforma';

  @override
  String get settingsAboutPackage => 'Paquete';

  @override
  String get settingsAboutApiServer => 'Servidor API';

  @override
  String get settingsAboutWebServer => 'Servidor web';

  @override
  String get settingsAboutGeocodingServer => 'Servidor de geocodificación';

  @override
  String get settingsAboutGeocodingServerNotConfigured => 'No configurado';

  @override
  String settingsAboutCommitHint(String commit) {
    return 'Las compilaciones desplegadas incluyen un commit de git (por ejemplo $commit). Compárelo con el último commit en main o con la etiqueta de imagen que descargó.';
  }

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionReset => 'Restablecer';

  @override
  String get actionLater => 'Más tarde';

  @override
  String get actionOk => 'Aceptar';

  @override
  String get actionReloadNow => 'Recargar ahora';

  @override
  String get actionSaving => 'Guardando…';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionImport => 'Importar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionRemoveAll => 'Eliminar todo';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionTryAgain => 'Reintentar';

  @override
  String get actionOpenSettings => 'Abrir configuración';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get actionSignOut => 'Cerrar sesión';

  @override
  String get actionUploading => 'Subiendo…';

  @override
  String get actionExporting => 'Exportando…';

  @override
  String get actionRestoring => 'Restaurando…';

  @override
  String get actionAborting => 'Cancelando…';

  @override
  String get statusLoading => 'Cargando…';

  @override
  String get statusWorking => 'Procesando…';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get settingsAppearanceTitle => 'Apariencia';

  @override
  String get settingsAppearanceDescription =>
      'Elija un tema de color para la aplicación. Los temas militares usan tonos oliva, arena y verde bosque. Se guarda en el servidor para que cada navegador use el mismo tema.';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageDescription =>
      'Elija el idioma de la aplicación. Se guarda en el servidor para que cada navegador use el mismo idioma.';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get settingsThemeStyle => 'Estilo del tema';

  @override
  String get settingsBrightness => 'Brillo';

  @override
  String get settingsMapHomeTitle => 'Inicio del mapa';

  @override
  String get settingsMapHomeDescription =>
      'Coordenadas y zoom del botón de inicio en el mapa. Se guarda en el servidor para que todos los clientes compartan la misma ubicación de inicio.';

  @override
  String get settingsLatitude => 'Latitud';

  @override
  String get settingsLongitude => 'Longitud';

  @override
  String get settingsZoom => 'Zoom';

  @override
  String settingsZoomHelper(String maxZoom) {
    return '0–$maxZoom';
  }

  @override
  String get settingsSaveHome => 'Guardar inicio';

  @override
  String get settingsUseCurrentMapView => 'Usar vista actual del mapa';

  @override
  String get settingsResetToDefault => 'Restablecer valores predeterminados';

  @override
  String get settingsServerConnectionTitle => 'Conexión al servidor';

  @override
  String get settingsServerConnectionDescription =>
      'URL del servidor API de Wayfinder, incluido host y puerto. La URL del servidor web se deriva automáticamente (puerto API + 2). Reinicie la aplicación después de cambiarla.';

  @override
  String get settingsServerUrl => 'URL del servidor';

  @override
  String settingsCurrentWebServer(String webUrl) {
    return 'Servidor web actual: $webUrl';
  }

  @override
  String get settingsSaveServerUrl => 'Guardar URL del servidor';

  @override
  String get settingsMeasurementsTitle => 'Medidas';

  @override
  String get settingsMeasurementsDescription =>
      'Elija cómo se muestran las distancias de las líneas en el mapa. Se guarda en el servidor para que cada navegador use las mismas unidades.';

  @override
  String get settingsAnglesTitle => 'Ángulos';

  @override
  String get settingsAnglesDescription =>
      'Elija cómo se muestran los ángulos relativos en el mapa y en los gráficos de rumbo.';

  @override
  String get lineArrowDensityLabel => 'Frecuencia de flechas';

  @override
  String get lineArrowDensitySparse => 'Escaso';

  @override
  String get lineArrowDensityLight => 'Ligero';

  @override
  String get lineArrowDensityBalanced => 'Equilibrado';

  @override
  String get lineArrowDensityFrequent => 'Frecuente';

  @override
  String get lineArrowDensityDense => 'Denso';

  @override
  String get settingsCirclesTitle => 'Círculos';

  @override
  String get settingsCirclesDescription =>
      'Elija la etiqueta de tamaño predeterminada mostrada en las nuevas zonas circulares.';

  @override
  String get settingsMapDebugTitle => 'Depuración del mapa';

  @override
  String get settingsMapDebugDescription =>
      'Ayudas visuales guardadas solo en este navegador.';

  @override
  String get settingsMapViewportDebugBorderTitle =>
      'Mostrar borde del viewport del mapa';

  @override
  String get settingsMapViewportDebugBorderDescription =>
      'Dibuja un contorno rojo alrededor del lienzo del mapa con detalles del archivo, zoom y tile central.';

  @override
  String get settingsMapTileBorderDebugTitle => 'Mostrar bordes de tiles';

  @override
  String get settingsMapTileBorderDebugDescription =>
      'Dibuja bordes verdes alrededor de cada tile del mapa. Requiere la superposición de depuración del viewport anterior.';

  @override
  String get mapDebugOverlayCopyTooltip => 'Copiar información de depuración';

  @override
  String get mapDebugOverlayCopied =>
      'Información de depuración copiada al portapapeles.';

  @override
  String get mapDebugOverlayCopyFailedTitle =>
      'Copia bloqueada — seleccione y copie manualmente';

  @override
  String get settingsHomeLocationSaved => 'Ubicación de inicio guardada.';

  @override
  String get settingsHomeLocationReset =>
      'Ubicación de inicio restablecida a los valores predeterminados.';

  @override
  String get settingsOpenMapFirst =>
      'Abra el mapa primero para capturar su vista.';

  @override
  String get settingsHomeLocationInvalid =>
      'Introduzca números válidos para latitud, longitud y zoom.';

  @override
  String settingsHomeLocationSaveFailed(String error) {
    return 'No se pudo guardar la ubicación de inicio: $error';
  }

  @override
  String get settingsRestartRequiredTitle => 'Reinicio requerido';

  @override
  String settingsRestartRequiredMessage(String apiUrl, String webUrl) {
    return 'URL del servidor guardada.\n\nAPI: $apiUrl\nWeb: $webUrl\n\nReinicie la aplicación para conectarse al nuevo servidor.';
  }

  @override
  String get settingsServerUrlReset =>
      'URL del servidor restablecida. Reinicie la aplicación para aplicar los cambios.';

  @override
  String settingsServerUrlSaveFailed(String error) {
    return 'No se pudo guardar la URL del servidor: $error';
  }

  @override
  String get themePreviewPrimary => 'Primario';

  @override
  String get themePreviewSecondary => 'Secundario';

  @override
  String get themePreviewSurface => 'Superficie';

  @override
  String get themePreviewAccent => 'Acento';

  @override
  String get themePreviewButton => 'Botón';

  @override
  String get themePreviewOutline => 'Contorno';

  @override
  String get themeFamilyStandard => 'Estándar';

  @override
  String get themeFamilyMilitary => 'Militar';

  @override
  String get themeBrightnessLight => 'Claro';

  @override
  String get themeBrightnessDark => 'Oscuro';

  @override
  String get themeChoiceMilitaryLight => 'Militar claro';

  @override
  String get themeChoiceMilitaryDark => 'Militar oscuro';

  @override
  String get measurementMetric => 'Métrico';

  @override
  String get measurementImperial => 'Imperial';

  @override
  String get measurementNautical => 'Náutico';

  @override
  String get measurementMetricShort => 'm/km';

  @override
  String get measurementImperialShort => 'pi/mi';

  @override
  String get measurementNauticalShort => 'mn';

  @override
  String get angleFormatDecimal => 'Grados decimales';

  @override
  String get angleFormatDms => 'Grados, minutos, segundos';

  @override
  String get angleFormatDecimalShort => 'DD';

  @override
  String get angleFormatDmsShort => 'DMS';

  @override
  String get circleSizeRadius => 'Radio';

  @override
  String get circleSizeDiameter => 'Diámetro';

  @override
  String get circleSizeNone => 'Ninguno';

  @override
  String get circleSizeToggleRadius =>
      'Radio visible en el mapa · toque para diámetro';

  @override
  String get circleSizeToggleDiameter =>
      'Diámetro visible en el mapa · toque para ocultar';

  @override
  String get circleSizeToggleNone =>
      'Tamaño oculto en el mapa · toque para radio';

  @override
  String get backupTitle => 'Copia de seguridad de datos del mapa';

  @override
  String get backupDescription =>
      'Exporte o restaure todas las capas, marcadores y zonas. También puede hacer copia de seguridad con curl: GET /api/map-data';

  @override
  String get backupExportButton => 'Exportar datos del mapa (.json)';

  @override
  String get backupRestoreButton => 'Restaurar desde copia de seguridad';

  @override
  String get backupExportSuccess =>
      'Copia de seguridad de datos del mapa guardada.';

  @override
  String backupExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get backupRestoreConfirmTitle => '¿Restaurar datos del mapa?';

  @override
  String get backupRestoreConfirmMessage =>
      'Esto reemplaza todas las capas, marcadores y zonas en el servidor con el archivo seleccionado. Esta acción no se puede deshacer.';

  @override
  String backupRestoreSuccess(int layers, int markers, int zones) {
    return 'Restauradas $layers capa(s), $markers marcador(es) y $zones zona(s).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get mapTilesFolderTitle => 'Carpeta PMTiles';

  @override
  String get mapTilesFolderDescription =>
      'Carpeta en el servidor que contiene archivos .pmtiles. Se guarda en la base de datos para que cada cliente use la misma biblioteca de mosaicos.';

  @override
  String get mapTilesStoragePathLabel => 'Ruta de almacenamiento PMTiles';

  @override
  String get mapTilesStoragePathRequired =>
      'La ruta de almacenamiento PMTiles es obligatoria.';

  @override
  String get mapTilesSaveAndRescan => 'Guardar y volver a escanear carpeta';

  @override
  String mapTilesFolderSaved(String path) {
    return 'Carpeta PMTiles guardada. Resincronizada desde $path.';
  }

  @override
  String mapTilesFolderSaveFailed(String error) {
    return 'Error al guardar la carpeta PMTiles: $error';
  }

  @override
  String get mapTilesMapsTitle => 'Mapas PMTiles';

  @override
  String get mapTilesMapsDescription =>
      'Organice archivos cartográficos sin conexión en grupos y elija cuáles se dibujan en el mapa.';

  @override
  String get mapTilesUploadButton => 'Subir archivo .pmtiles';

  @override
  String mapTilesUploadSuccess(String name) {
    return 'Archivo PMTiles subido: $name';
  }

  @override
  String mapTilesUploadFailed(String error) {
    return 'Error al subir: $error';
  }

  @override
  String get mapTilesAllHidden => 'Todos los mosaicos del mapa están ocultos.';

  @override
  String get mapTilesNewGroupTitle => 'Nuevo grupo de mosaicos';

  @override
  String get mapTilesGroupNameLabel => 'Nombre del grupo';

  @override
  String get mapTilesGroupNameHint => 'p. ej. Estados del Atlántico Medio';

  @override
  String mapTilesGroupCreated(String name) {
    return 'Grupo «$name» creado.';
  }

  @override
  String mapTilesGroupCreateFailed(String error) {
    return 'No se pudo crear el grupo: $error';
  }

  @override
  String get mapTilesDeleteGroupTitle => '¿Eliminar grupo de mosaicos?';

  @override
  String mapTilesDeleteGroupMessage(String name) {
    return '¿Eliminar «$name»? Los archivos de este grupo quedarán sin agrupar.';
  }

  @override
  String get mapTilesDeleteFileTitle => '¿Eliminar archivo PMTiles?';

  @override
  String mapTilesDeleteFileMessage(String name) {
    return '¿Quitar «$name» del servidor?';
  }

  @override
  String get mapTilesFileDeleted => 'Archivo PMTiles eliminado.';

  @override
  String mapTilesFilesLoadFailed(String error) {
    return 'Error al cargar archivos: $error';
  }

  @override
  String mapTilesGroupsLoadFailed(String error) {
    return 'Error al cargar grupos: $error';
  }

  @override
  String get mapTilesNoFiles => 'Aún no se han subido archivos PMTiles.';

  @override
  String mapTilesShownOnMapCount(int shown, int total) {
    return '$shown de $total visibles en el mapa';
  }

  @override
  String get mapTilesUngrouped => 'Sin agrupar';

  @override
  String get mapTilesNoFilesAssigned => 'Sin archivos asignados';

  @override
  String get mapTilesShowUngroupedOnMap => 'Mostrar sin agrupar en el mapa';

  @override
  String get mapTilesShowGroupOnMap => 'Mostrar grupo en el mapa';

  @override
  String get mapTilesDeleteGroupTooltip => 'Eliminar grupo';

  @override
  String get mapTilesUngroupedEmptyMessage =>
      'Los archivos sin grupo aparecen aquí.';

  @override
  String get mapTilesGroupEmptyMessage =>
      'Asigne archivos a este grupo desde el menú de cada mosaico.';

  @override
  String get mapTilesNoGroups => 'Sin grupos';

  @override
  String mapTilesGroupCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String get mapTilesManageGroupsTooltip => 'Administrar grupos';

  @override
  String get mapTilesNewGroup => 'Nuevo grupo';

  @override
  String get mapTilesShowAllOnMap => 'Mostrar todo en el mapa';

  @override
  String get mapTilesHideAllFromMap => 'Ocultar todo del mapa';

  @override
  String get layerLabel => 'Capa';

  @override
  String get layerUnassigned => 'Sin asignar';

  @override
  String get layerUnknown => 'Capa desconocida';

  @override
  String get formNameLabel => 'Nombre';

  @override
  String get formColorLabel => 'Color';

  @override
  String get formNotesLabel => 'Notas';

  @override
  String get formNotesPlaceholder =>
      'Añadir notas (guardadas como Markdown)...';

  @override
  String get formPreviewLabel => 'Vista previa';

  @override
  String get formShowNameOnMap => 'Mostrar nombre en el mapa';

  @override
  String get formBorderColorLabel => 'Color del borde';

  @override
  String get formFillColorLabel => 'Color de relleno';

  @override
  String get formFillOpacityHelp =>
      'Ajuste la opacidad para controlar la transparencia del relleno.';

  @override
  String get coordinatesTitle => 'Coordenadas';

  @override
  String get markerCreateTitle => 'Crear marcador';

  @override
  String get markerEditTitle => 'Editar marcador';

  @override
  String get markerDefaultName => 'Nuevo marcador';

  @override
  String get markerNameHint => 'p. ej. Casa, Trabajo, Inicio de sendero';

  @override
  String get markerElevationLabel => 'Elevación (m)';

  @override
  String get markerIconLabel => 'Icono';

  @override
  String get markerIconHelp =>
      'Elija un icono para el pin del mapa, como Casa para su vivienda.';

  @override
  String get markerSaveSearchedCoordinatesTitle =>
      'Guardar coordenadas buscadas';

  @override
  String get markerSaveSearchedCoordinatesConfirm => 'Guardar marcador';

  @override
  String get lineCreateTitle => 'Crear línea';

  @override
  String get lineEditTitle => 'Editar línea';

  @override
  String get lineDefaultName => 'Nueva línea';

  @override
  String get lineNameHint => 'p. ej. Ruta al campamento, Límite de propiedad';

  @override
  String get lineDistanceLabel => 'Distancia';

  @override
  String get lineStartPointLabel => 'Punto inicial';

  @override
  String get lineEndPointLabel => 'Punto final';

  @override
  String get lineStyleLabel => 'Estilo de línea';

  @override
  String get lineBorderSolid => 'Sólida';

  @override
  String get lineBorderDashed => 'Discontinua';

  @override
  String get lineDirectionArrowsTitle => 'Flechas de dirección';

  @override
  String get lineDirectionArrowsSubtitle =>
      'Las flechas apuntan del primer punto hacia el segundo.';

  @override
  String get circleCreateTitle => 'Crear círculo';

  @override
  String get circleEditTitle => 'Editar círculo';

  @override
  String get circleDefaultName => 'Nuevo círculo';

  @override
  String get circleNameHint => 'p. ej. Área de búsqueda, Límite de propiedad';

  @override
  String get circleMeasurementsLabel => 'Medidas';

  @override
  String get circleCenterLabel => 'Centro';

  @override
  String get circleSizeLabelOnMap => 'Etiqueta de tamaño en el mapa';

  @override
  String get circleCenterMarkerLabel => 'Marcador central';

  @override
  String get rectangleCreateTitle => 'Crear rectángulo';

  @override
  String get rectangleEditTitle => 'Editar rectángulo';

  @override
  String get rectangleDefaultName => 'Nuevo rectángulo';

  @override
  String get rectangleCornerALabel => 'Esquina A';

  @override
  String get rectangleCornerBLabel => 'Esquina B';

  @override
  String get rectangleCenterMoveHelp =>
      'Mover el centro desplaza todo el rectángulo en el mapa.';

  @override
  String get mapHomeTooltip => 'Inicio';

  @override
  String get mapSettingsTooltip => 'Configuración';

  @override
  String get mapShowObjectsTooltip => 'Mostrar objetos del mapa';

  @override
  String mapLoadFailed(String error) {
    return 'Error al cargar el mapa: $error';
  }

  @override
  String get mapNoOfflineMapTitle =>
      'No hay mapa sin conexión instalado o visible';

  @override
  String get mapNoOfflineMapMessage =>
      'Suba un archivo .pmtiles en Configuración o active la visibilidad de mosaicos en el servidor.';

  @override
  String get mapObjectDetailsTitle => 'Objeto del mapa';

  @override
  String get mapObjectDetailsLoading => 'Cargando detalles…';

  @override
  String get mapObjectDetailsNotFound => 'No se encontró este objeto.';

  @override
  String get mapObjectDetailType => 'Tipo';

  @override
  String get mapObjectTypeMarker => 'Marcador';

  @override
  String get mapObjectTypeLine => 'Línea';

  @override
  String get mapObjectTypeCircle => 'Círculo';

  @override
  String get mapObjectDetailCoordinates => 'Coordenadas';

  @override
  String get mapObjectDetailElevation => 'Elevación';

  @override
  String get mapObjectDetailVisibility => 'Visibilidad';

  @override
  String get mapObjectVisibilityVisible => 'Visible';

  @override
  String get mapObjectVisibilityHidden => 'Oculto';

  @override
  String get mapObjectDetailLength => 'Longitud';

  @override
  String get mapObjectDetailStart => 'Inicio';

  @override
  String get mapObjectDetailEnd => 'Fin';

  @override
  String get mapObjectDetailRadius => 'Radio';

  @override
  String get mapObjectDetailDiameter => 'Diámetro';

  @override
  String get mapObjectDetailCenter => 'Centro';

  @override
  String get mapObjectDetailMapLabel => 'Etiqueta en el mapa';

  @override
  String get mapObjectMapLabelNone => 'Ninguna';

  @override
  String get mapObjectDetailDimensions => 'Dimensiones';

  @override
  String get mapObjectDetailArea => 'Área';

  @override
  String get mapObjectsErrorServerUnreachable =>
      'No se pudo contactar con el servidor Wayfinder. Inicie el servidor para sincronizar marcadores y zonas.';

  @override
  String get mapObjectsErrorSignInRequired =>
      'Inicie sesión para cargar sus objetos del mapa.';

  @override
  String get mapObjectsErrorGeneric =>
      'Algo salió mal al cargar los objetos del mapa. Compruebe su conexión e inténtelo de nuevo.';

  @override
  String get mapObjectsErrorRetry =>
      'Algo salió mal al cargar los objetos del mapa. Inténtelo de nuevo.';

  @override
  String get layersErrorTableMissing =>
      'Falta la tabla de capas del mapa. Reinicie el servidor Wayfinder con las migraciones aplicadas.';

  @override
  String get layersErrorEndpointUnavailable =>
      'Reinicie el servidor Wayfinder con el código más reciente.';

  @override
  String get layersErrorGeneric =>
      'Algo salió mal al cargar las capas. Inténtelo de nuevo.';

  @override
  String get sidebarTitle => 'Objetos del mapa';

  @override
  String get sidebarCollapsePanel => 'Contraer panel';

  @override
  String get sidebarExpandPanel => 'Expandir panel';

  @override
  String get sidebarLayerOrderHint =>
      'Las capas superiores se dibujan encima de las inferiores. Use ▼ para expandir o contraer el contenido de una capa.';

  @override
  String get sidebarLayersUnavailable => 'Capas no disponibles';

  @override
  String get sidebarMarkersUnavailable => 'Marcadores no disponibles';

  @override
  String get sidebarZonesUnavailable => 'Zonas no disponibles';

  @override
  String get sidebarAddLayer => 'Añadir capa';

  @override
  String get sidebarKeepOneLayer => 'Debe conservar al menos una capa.';

  @override
  String get sidebarNewLayerTitle => 'Nueva capa';

  @override
  String get sidebarRenameLayerTitle => 'Renombrar capa';

  @override
  String get sidebarLayerNameLabel => 'Nombre de la capa';

  @override
  String get sidebarDeleteLayerTitle => '¿Eliminar capa?';

  @override
  String sidebarDeleteLayerMessage(String name) {
    return '¿Eliminar «$name»? Sus marcadores y zonas se moverán a otra capa.';
  }

  @override
  String get sidebarCollapseLayer => 'Contraer capa';

  @override
  String get sidebarExpandLayer => 'Expandir capa';

  @override
  String get sidebarHideLayer => 'Ocultar capa';

  @override
  String get sidebarShowLayer => 'Mostrar capa';

  @override
  String sidebarObjectCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetos',
      one: '1 objeto',
    );
    return '$_temp0';
  }

  @override
  String get sidebarSelectedForNewObjects =>
      '· seleccionado para nuevos objetos';

  @override
  String get sidebarMoveUp => 'Subir';

  @override
  String get sidebarMoveDown => 'Bajar';

  @override
  String get sidebarTabMarkers => 'Marcadores';

  @override
  String get sidebarTabZones => 'Zonas';

  @override
  String get sidebarViewList => 'Lista';

  @override
  String get sidebarViewTree => 'Árbol';

  @override
  String get sidebarNoMatchingMarkers => 'No hay marcadores coincidentes';

  @override
  String get sidebarNoMatchingZones => 'No hay zonas coincidentes';

  @override
  String get sidebarTryDifferentSearch =>
      'Pruebe con otro término de búsqueda.';

  @override
  String get sidebarNoMarkersOnLayer => 'No hay marcadores en esta capa';

  @override
  String get sidebarAddMarkerHint =>
      'Mantenga pulsado el mapa para añadir un marcador.';

  @override
  String get sidebarNoZonesOnLayer => 'No hay zonas en esta capa';

  @override
  String get sidebarAddZoneHint =>
      'Mantenga pulsado el mapa y elija Línea para dibujar una.';

  @override
  String get sidebarHideMarker => 'Ocultar marcador';

  @override
  String get sidebarShowMarker => 'Mostrar marcador';

  @override
  String get sidebarEditMarker => 'Editar marcador';

  @override
  String get sidebarDeleteMarker => 'Eliminar marcador';

  @override
  String get sidebarHideNameOnMap => 'Ocultar nombre en el mapa';

  @override
  String get sidebarShowNameOnMap => 'Mostrar nombre en el mapa';

  @override
  String get sidebarHideDistanceOnMap => 'Ocultar distancia en el mapa';

  @override
  String get sidebarShowDistanceOnMap => 'Mostrar distancia en el mapa';

  @override
  String get sidebarHideLine => 'Ocultar línea';

  @override
  String get sidebarShowLine => 'Mostrar línea';

  @override
  String get sidebarEditLine => 'Editar línea';

  @override
  String get sidebarDeleteLine => 'Eliminar línea';

  @override
  String get sidebarHideCircle => 'Ocultar círculo';

  @override
  String get sidebarShowCircle => 'Mostrar círculo';

  @override
  String get sidebarEditCircle => 'Editar círculo';

  @override
  String get sidebarDeleteCircle => 'Eliminar círculo';

  @override
  String get sidebarHideRectangle => 'Ocultar rectángulo';

  @override
  String get sidebarShowRectangle => 'Mostrar rectángulo';

  @override
  String get sidebarEditRectangle => 'Editar rectángulo';

  @override
  String get sidebarDeleteRectangle => 'Eliminar rectángulo';

  @override
  String get sidebarHideZone => 'Ocultar zona';

  @override
  String get sidebarShowZone => 'Mostrar zona';

  @override
  String get sidebarDeleteZone => 'Eliminar zona';

  @override
  String get searchReadinessReadySnackBar =>
      'Búsqueda completa lista — lugares y direcciones.';

  @override
  String get searchReadinessCheckingTooltip =>
      'Comprobando disponibilidad de búsqueda…';

  @override
  String get searchReadinessUnavailableTooltip =>
      'Disponibilidad de búsqueda no disponible';

  @override
  String get searchReadinessFullReadyTooltip => 'Búsqueda completa lista';

  @override
  String get searchReadinessBuildingTooltip =>
      'Construyendo índices de búsqueda…';

  @override
  String get searchReadinessNotReadyTooltip => 'Búsqueda completa no lista';

  @override
  String get searchReadinessGeocodingNotConfiguredTooltip =>
      'Servidor de geocodificación no configurado';

  @override
  String get searchReadinessGeocodingUnavailableTooltip =>
      'Servidor de geocodificación no disponible';

  @override
  String searchReadinessImportInProgressTooltip(String phase) {
    return 'Importación en curso: $phase';
  }

  @override
  String get searchReadinessImportPlacesDialogTitle =>
      'Importación de datos de lugares';

  @override
  String get searchReadinessImportAddressesDialogTitle =>
      'Importación de datos de direcciones';

  @override
  String get searchReadinessFullReadyTitle => 'Búsqueda completa lista';

  @override
  String get searchReadinessPlacesReadyTitle => 'Búsqueda de lugares lista';

  @override
  String get searchReadinessAddressReadyTitle =>
      'Búsqueda de direcciones lista';

  @override
  String get searchReadinessWaitingForDataTitle =>
      'Esperando datos de geocodificación';

  @override
  String get searchReadinessNotReadyTitle => 'Búsqueda aún no lista';

  @override
  String searchReadinessIndexesBuilt(int ready, int total) {
    return 'Índices de búsqueda: $ready de $total';
  }

  @override
  String get searchReadinessCheckingStatus => 'Comprobando estado de búsqueda…';

  @override
  String get searchReadinessFullReadyMessage =>
      'Puede buscar lugares y direcciones postales desde la barra de búsqueda del mapa.';

  @override
  String get searchReadinessPlacesOnlyMessage =>
      'Puede buscar nombres de lugares desde la barra de búsqueda del mapa. Importe datos de direcciones en Ajustes → Geocodificación para buscar direcciones.';

  @override
  String get searchReadinessAddressOnlyMessage =>
      'Puede buscar direcciones postales desde la barra de búsqueda del mapa. Importe datos de lugares en Ajustes → Geocodificación para buscar nombres de lugares.';

  @override
  String get searchReadinessWaitingForDataMessage =>
      'Los índices de búsqueda están listos. Importe los conjuntos de datos que faltan en Ajustes → Geocodificación para habilitar la búsqueda.';

  @override
  String get searchReadinessRequirementsTitle => 'Requisitos de búsqueda';

  @override
  String get searchReadinessRequirementPlacesData =>
      'Datos de lugares importados';

  @override
  String get searchReadinessRequirementAddressData =>
      'Datos de direcciones importados';

  @override
  String get searchReadinessRequirementIndexes =>
      'Índices de búsqueda construidos';

  @override
  String get searchReadinessRequirementReady => 'Listo';

  @override
  String get searchReadinessRequirementMissing => 'No listo';

  @override
  String get searchReadinessPartialReadyTooltip => 'Búsqueda parcial lista';

  @override
  String get searchReadinessPlacesOnlyTooltip => 'Búsqueda de lugares lista';

  @override
  String searchReadinessPercentComplete(int percent) {
    return '$percent % completado';
  }

  @override
  String searchReadinessEta(String eta) {
    return 'Tiempo restante estimado: $eta';
  }

  @override
  String searchReadinessCurrentIndex(String name) {
    return 'Índice actual: $name';
  }

  @override
  String get searchReadinessServerUnreachable =>
      'No se pudo contactar con el servidor para comprobar el estado de búsqueda.';

  @override
  String get mapTilesReadyTooltip => 'Mosaicos del mapa listos';

  @override
  String get mapTilesLoadingTooltip => 'Cargando mosaicos del mapa';

  @override
  String get mapTilesNotReadyTooltip => 'Mosaicos del mapa no listos';

  @override
  String get mapTilesLoadingTitle => 'Cargando mosaicos del mapa';

  @override
  String get mapTilesCatalogLoadFailed =>
      'Error al cargar el catálogo de mosaicos.';

  @override
  String mapTilesOpeningLayer(String name) {
    return 'Abriendo: $name';
  }

  @override
  String get mapTilesLargeArchiveHelp =>
      'Los archivos .pmtiles grandes pueden tardar varios minutos en abrirse antes de que aparezcan los mosaicos.';

  @override
  String mapTilesLayersPrepared(int loaded, int enabled) {
    return 'Capas preparadas: $loaded de $enabled';
  }

  @override
  String mapTilesActiveLayer(String name) {
    return 'Capa activa: $name';
  }

  @override
  String get mapTilesReadyHelp =>
      'Los mosaicos para la vista actual deberían ser visibles. Si el mapa sigue en blanco, intente acercar al área de cobertura.';

  @override
  String mapTilesOpeningProgress(String name) {
    return 'Abriendo $name…';
  }

  @override
  String get greetingsConnected => 'Está conectado';

  @override
  String get greetingsNameHint => 'Introduzca su nombre';

  @override
  String get greetingsSendToServer => 'Enviar al servidor';

  @override
  String get greetingsNoResponse => 'Aún no hay respuesta del servidor.';

  @override
  String get authSuccess => 'Usuario autenticado.';

  @override
  String authFailed(String error) {
    return 'Error de autenticación: $error';
  }

  @override
  String couldNotOpenLink(String url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String get geocodingAbortImport => 'Cancelar importación';

  @override
  String get geocodingTitle => 'Geocodificación';

  @override
  String get geocodingDescription =>
      'Descargue datos OSMNames al servidor de geocodificación para búsqueda sin conexión. Los nombres de lugares y las direcciones se importan por separado.';

  @override
  String get geocodingServerConnectionTitle => 'Servidor de geocodificación';

  @override
  String get geocodingServerConnectionDescription =>
      'Separado del servidor principal de Wayfinder. Ejecute la pila de geocodificación en otra máquina cuando las importaciones necesiten una base de datos grande.';

  @override
  String get geocodingServerUrlLabel =>
      'URL web del servidor de geocodificación';

  @override
  String get geocodingSaveServerUrl =>
      'Guardar URL del servidor de geocodificación';

  @override
  String get geocodingServerNotConfiguredMessage =>
      'Configure la URL del servidor de geocodificación para habilitar la búsqueda de lugares y direcciones. Reinicie la aplicación después de guardar.';

  @override
  String get geocodingServerUrlSavedRestart =>
      'URL del servidor de geocodificación guardada. Reinicie la aplicación para conectar.';

  @override
  String get geocodingPlacesSectionTitle => 'Nombres de lugares (geonames.tsv)';

  @override
  String get geocodingPlaceDatasetLabel => 'Conjunto de datos de lugares';

  @override
  String get geocodingCustomPlaceUrlLabel =>
      'URL de datos de lugares personalizada';

  @override
  String geocodingStatusLabel(String status) {
    return 'Estado: $status';
  }

  @override
  String geocodingLastSelection(String dataset) {
    return 'Última selección: $dataset';
  }

  @override
  String geocodingLastImport(String dateTime) {
    return 'Última importación: $dateTime';
  }

  @override
  String get geocodingPlacesArchiveDescription =>
      'Archive datos de lugares como JSON, restaure desde una exportación anterior o elimine todos los registros del servidor.';

  @override
  String get geocodingPlaceImportInProgress =>
      'Importación de lugares en curso…';

  @override
  String get geocodingDownloadImportPlaces => 'Descargar e importar lugares';

  @override
  String get geocodingAddressesSectionTitle =>
      'Direcciones postales (housenumbers.tsv)';

  @override
  String get geocodingHousenumbersUrlLabel => 'URL de datos housenumbers';

  @override
  String get geocodingAddressesArchiveDescription =>
      'Archive datos de direcciones en un archivo JSON separado, restaure o elimine todos los registros del servidor.';

  @override
  String get geocodingAddressImportInProgress =>
      'Importación de direcciones en curso…';

  @override
  String get geocodingDownloadImportHousenumbers =>
      'Descargar e importar housenumbers';

  @override
  String geocodingSettingsLoadFailed(String error) {
    return 'Error al cargar la configuración de geocodificación: $error';
  }

  @override
  String get geocodingStatusNotImported => 'No importado';

  @override
  String get geocodingStatusDownloading => 'Descargando…';

  @override
  String get geocodingStatusImporting => 'Importando…';

  @override
  String geocodingStatusReady(String count, String label) {
    return 'Listo ($count $label)';
  }

  @override
  String get geocodingStatusFailed => 'Error';

  @override
  String get geocodingStatusCancelled => 'Cancelado';

  @override
  String get geocodingCustomUrlLabel => 'URL personalizada';

  @override
  String get geocodingRowLabelPlaces => 'lugares';

  @override
  String get geocodingRowLabelAddresses => 'direcciones';

  @override
  String get geocodingRowLabelRows => 'filas';

  @override
  String geocodingImportProgress(
    String percent,
    String count,
    String rowLabel,
  ) {
    return '$percent % · $count $rowLabel importado(s)';
  }

  @override
  String get geocodingImportPhaseDownloadingTitle =>
      'Descargando conjunto de datos';

  @override
  String get geocodingImportPhaseDownloadingDetail =>
      'Obteniendo el archivo comprimido de nombres de lugares desde internet.';

  @override
  String get geocodingImportPhaseImportingTitle => 'Leyendo nombres de lugares';

  @override
  String get geocodingImportPhaseImportingDetail =>
      'Guardando lugares en el servidor a medida que se leen del archivo.';

  @override
  String get geocodingImportPhaseImportingAddressesTitle =>
      'Leyendo direcciones';

  @override
  String get geocodingImportPhaseImportingAddressesDetail =>
      'Guardando direcciones en el servidor a medida que se leen del archivo.';

  @override
  String get geocodingImportPhaseFinalizingTitle => 'Finalizando';

  @override
  String get geocodingImportPhaseFinalizingDetail =>
      'Guardando el último lote antes del paso final.';

  @override
  String get geocodingImportPhaseCommittingTitle => 'Casi listo';

  @override
  String geocodingImportPhaseCommittingDetail(String count, String rowLabel) {
    return 'Se han leído todos los $count $rowLabel. El servidor ahora los guarda para la búsqueda. Esto puede tardar de una a tres horas y la barra de progreso puede detenerse aquí.';
  }

  @override
  String get geocodingImportDoNotRestartTitle =>
      'Mantenga el servidor en ejecución';

  @override
  String get geocodingImportDoNotRestartMessage =>
      'No reinicie ni detenga el servidor durante este paso. Si lo hace, la importación se cancelará y tendrá que empezar de nuevo desde el principio.';

  @override
  String get geocodingSourceUrlRequired =>
      'La URL de origen de geocodificación es obligatoria.';

  @override
  String get geocodingPlanetImportStarted =>
      'Importación planetaria de lugares iniciada. Puede tardar muchas horas.';

  @override
  String get geocodingPlaceImportStarted =>
      'Importación de nombres de lugares iniciada.';

  @override
  String geocodingPlaceImportFailed(String error) {
    return 'Error al importar lugares: $error';
  }

  @override
  String get geocodingPlaceImportAbortRequested =>
      'Cancelación de importación de lugares solicitada. Se conservarán los datos existentes.';

  @override
  String geocodingAbortFailed(String error) {
    return 'Error al cancelar: $error';
  }

  @override
  String get geocodingHousenumbersUrlRequired =>
      'La URL de origen de housenumbers es obligatoria.';

  @override
  String get geocodingHousenumbersImportStarted =>
      'Importación de housenumbers iniciada. Puede tardar muchas horas.';

  @override
  String geocodingHousenumbersImportFailed(String error) {
    return 'Error al importar housenumbers: $error';
  }

  @override
  String get geocodingAddressImportAbortRequested =>
      'Cancelación de importación de direcciones solicitada. Se conservarán los datos existentes.';

  @override
  String get geocodingPlaceDataExported => 'Datos de lugares exportados.';

  @override
  String get geocodingImportPlaceArchiveTitle =>
      '¿Importar archivo de lugares?';

  @override
  String get geocodingImportPlaceArchiveMessage =>
      'Esto reemplaza todos los registros de nombres de lugares en el servidor con el archivo seleccionado.';

  @override
  String geocodingPlaceArchiveImported(int count) {
    return 'Importados $count registro(s) de lugar.';
  }

  @override
  String geocodingImportFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get geocodingRemoveAllPlacesTitle =>
      '¿Eliminar todos los registros de lugares?';

  @override
  String get geocodingRemoveAllPlacesMessage =>
      'Esto elimina permanentemente todos los registros de nombres de lugares del servidor. Esta acción no se puede deshacer.';

  @override
  String geocodingPlacesRemoved(int count) {
    return 'Eliminados $count registro(s) de lugar.';
  }

  @override
  String geocodingRemoveFailed(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get geocodingHousenumberDataExported =>
      'Datos housenumbers exportados.';

  @override
  String get geocodingImportHousenumberArchiveTitle =>
      '¿Importar archivo housenumbers?';

  @override
  String get geocodingImportHousenumberArchiveMessage =>
      'Esto reemplaza todos los registros de direcciones en el servidor con el archivo seleccionado.';

  @override
  String geocodingHousenumberArchiveImported(int count) {
    return 'Importados $count registro(s) de dirección.';
  }

  @override
  String get geocodingRemoveAllAddressesTitle =>
      '¿Eliminar todos los registros de direcciones?';

  @override
  String get geocodingRemoveAllAddressesMessage =>
      'Esto elimina permanentemente todos los registros housenumbers del servidor. Esta acción no se puede deshacer.';

  @override
  String geocodingAddressesRemoved(int count) {
    return 'Eliminados $count registro(s) de dirección.';
  }

  @override
  String get geocodingPlanetImportWarning =>
      'La importación planetaria completa descarga unos 1,4 GB y puede tardar muchas horas.';

  @override
  String get geocodingCountryImportDownloadNote =>
      'Las importaciones por país aún descargan el archivo OSMNames global (~1,4 GB), pero solo se carga el país seleccionado.';

  @override
  String get geocodingHousenumbersImportWarning =>
      'El archivo housenumbers es independiente de los nombres de lugares y también pesa unos 1,4 GB comprimidos.';

  @override
  String get geocodingDatasetSample => 'Muestra (100 k lugares)';

  @override
  String get geocodingDatasetSampleDescription =>
      'Un conjunto de datos pequeño para pruebas. Ideal para probar la búsqueda en pocos minutos.';

  @override
  String get geocodingDatasetPlanet => 'Planeta completo (~23 M lugares)';

  @override
  String get geocodingDatasetPlanetDescription =>
      'Importa cada lugar del archivo planetario OSMNames. La descarga pesa unos 1,4 GB comprimidos.';

  @override
  String get geocodingDatasetUs => 'Estados Unidos';

  @override
  String get geocodingDatasetUsDescription =>
      'Descarga el archivo OSMNames global pero solo importa lugares de Estados Unidos.';

  @override
  String get geocodingDatasetCa => 'Canadá';

  @override
  String get geocodingDatasetCaDescription =>
      'Descarga el archivo OSMNames global pero solo importa lugares canadienses.';

  @override
  String get geocodingDatasetMx => 'México';

  @override
  String get geocodingDatasetGb => 'Reino Unido';

  @override
  String get geocodingDatasetDe => 'Alemania';

  @override
  String get geocodingDatasetFr => 'Francia';

  @override
  String get geocodingDatasetEs => 'España';

  @override
  String get geocodingDatasetIt => 'Italia';

  @override
  String get geocodingDatasetNl => 'Países Bajos';

  @override
  String get geocodingDatasetAu => 'Australia';

  @override
  String get geocodingDatasetNz => 'Nueva Zelanda';

  @override
  String get geocodingDatasetJp => 'Japón';

  @override
  String get geocodingDatasetBr => 'Brasil';

  @override
  String get geocodingDatasetIn => 'India';

  @override
  String get geocodingDatasetCustom => 'URL personalizada…';

  @override
  String get geocodingDatasetCustomDescription =>
      'Proporcione su propia URL OSMNames .tsv.gz.';

  @override
  String get mapRadialMarker => 'Marcador';

  @override
  String get mapRadialLine => 'Línea';

  @override
  String get mapRadialCircle => 'Círculo';

  @override
  String get mapRadialRectCenter => 'Rect. centro';

  @override
  String get mapRadialRectCorners => 'Rect. esquinas';

  @override
  String get mapRadialCopyCoordinates => 'Copiar coordenadas';

  @override
  String get mapCoordinatesCopied => 'Coordenadas copiadas al portapapeles.';

  @override
  String get mapMarkerShareUrlLabel => 'Enlace';

  @override
  String get mapMarkerCopyUrlTooltip => 'Copiar enlace del marcador';

  @override
  String get mapMarkerUrlCopied =>
      'Enlace del marcador copiado al portapapeles.';

  @override
  String get mapRelativeAngleLabel => 'Rel°';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortHue => 'Tono';

  @override
  String get sortIcon => 'Icono';

  @override
  String get sortVisibility => 'Visibilidad';

  @override
  String get sortType => 'Tipo';

  @override
  String get sortGroupVisible => 'Visible';

  @override
  String get sortGroupHidden => 'Oculto';

  @override
  String get sortGroupOther => 'Otro';

  @override
  String get sidebarSortMarkers => 'Ordenar marcadores';

  @override
  String get sidebarSortZones => 'Ordenar zonas';

  @override
  String get rectangleSizeDimensions => 'Dimensiones';

  @override
  String get rectangleSizeArea => 'Área';

  @override
  String get rectangleSizeNone => 'Ninguna';

  @override
  String get rectangleSizeDimensionsShort => 'A×H';

  @override
  String get rectangleModeCenter => 'Rectángulo centrado';

  @override
  String get rectangleModeCorners => 'Rectángulo por esquinas';

  @override
  String get mapObjectTypeRectangle => 'Rectángulo';

  @override
  String get searchSubtitleCoordinates => 'Coordenadas';

  @override
  String get searchSubtitleMarker => 'Marcador';

  @override
  String searchSubtitleZone(String type) {
    return 'Zona ($type)';
  }

  @override
  String searchHint(String example) {
    return 'Buscar lugares, marcadores, zonas o lat, lng (p. ej. $example)';
  }

  @override
  String get sortGroupDigits => '0-9';

  @override
  String get markerIconPlace => 'Lugar';

  @override
  String get markerIconHome => 'Casa';

  @override
  String get markerIconHouse => 'Vivienda';

  @override
  String get markerIconApartment => 'Apartamento';

  @override
  String get markerIconWork => 'Trabajo';

  @override
  String get markerIconSchool => 'Escuela';

  @override
  String get markerIconStore => 'Tienda';

  @override
  String get markerIconFood => 'Comida';

  @override
  String get markerIconCafe => 'Café';

  @override
  String get markerIconHotel => 'Hotel';

  @override
  String get markerIconChurch => 'Iglesia';

  @override
  String get markerIconMosque => 'Mezquita';

  @override
  String get markerIconCommunity => 'Comunidad';

  @override
  String get markerIconMedical => 'Médico';

  @override
  String get markerIconVehicle => 'Vehículo';

  @override
  String get markerIconBike => 'Bicicleta';

  @override
  String get markerIconTrail => 'Sendero';

  @override
  String get markerIconPark => 'Parque';

  @override
  String get markerIconMonument => 'Monumento';

  @override
  String get markerIconGeocache => 'Geocaché';

  @override
  String get markerIconFlag => 'Bandera';

  @override
  String get markerIconStar => 'Estrella';

  @override
  String get markerIconFavorite => 'Favorito';

  @override
  String get markerIconWarning => 'Advertencia';

  @override
  String get markerIconInfo => 'Info';

  @override
  String get markerIconLocation => 'Ubicación';

  @override
  String get markerIconPhoto => 'Foto';

  @override
  String get markerIconPets => 'Mascotas';

  @override
  String get markerIconRadioTower => 'Torre de radio';

  @override
  String get markerIconRadioRepeater => 'Repetidor de radio';

  @override
  String get markerIconWater => 'Agua';

  @override
  String get markerIconSupplyCache => 'Alijo de suministros';

  @override
  String get markerIconRetreat => 'Refugio';

  @override
  String get markerIconCamp => 'Campamento';

  @override
  String get markerIconFuel => 'Combustible';

  @override
  String get markerIconGate => 'Portón';

  @override
  String get markerIconCrossing => 'Cruce';

  @override
  String get markerIconLookout => 'Observación';

  @override
  String get markerIconPower => 'Energía';

  @override
  String get markerIconGarden => 'Huerto';

  @override
  String get markerIconStaging => 'Área de espera';

  @override
  String get markerIconHazard => 'Peligro';

  @override
  String get markerIconRestricted => 'Restringido';

  @override
  String get markerIconRally => 'Punto de reunión';

  @override
  String get markerIconWorkshop => 'Taller';

  @override
  String get markerIconBoat => 'Barco';

  @override
  String get markerIconAirstrip => 'Pista de aterrizaje';

  @override
  String get markerIconDefense => 'Defensa';

  @override
  String get markerIconHunting => 'Caza';

  @override
  String get markerIconFishing => 'Pesca';

  @override
  String get markerIconCave => 'Cueva';

  @override
  String get markerIconDeadZone => 'Zona sin señal';

  @override
  String get markerIconEvacRoute => 'Ruta de evacuación';

  @override
  String get markerIconLivestock => 'Ganado';

  @override
  String get markerIconPharmacy => 'Farmacia';
}
