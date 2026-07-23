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
  String get settingsTabMarkerIcons => 'Iconos de marcadores';

  @override
  String get settingsTabGeocoding => 'Geocodificación';

  @override
  String get settingsTabTides => 'Mareas';

  @override
  String get settingsTabSeasonalOverlays => 'Seasons';

  @override
  String get settingsTabUsers => 'Usuarios y roles';

  @override
  String get settingsTabTrash => 'Papelera';

  @override
  String get settingsTabBackup => 'Copia de seguridad';

  @override
  String get settingsTabAbout => 'Acerca de';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get mapObjectDeletedSnackbar => 'Movido a la papelera';

  @override
  String mapObjectDeletedNamedSnackbar(String name) {
    return '“$name” movido a la papelera';
  }

  @override
  String get mapObjectCreatedBy => 'Creado por';

  @override
  String get mapObjectUpdatedBy => 'Última edición por';

  @override
  String get mapObjectAttributionUnknown => 'Desconocido';

  @override
  String get mapObjectTrashTitle => 'Papelera';

  @override
  String get mapObjectTrashHelp =>
      'Los marcadores y zonas eliminados se pueden restaurar o borrar definitivamente. El borrado permanente no se puede deshacer.';

  @override
  String get mapObjectTrashEmpty => 'La papelera está vacía.';

  @override
  String mapObjectTrashLoadFailed(String error) {
    return 'No se pudo cargar la papelera: $error';
  }

  @override
  String get mapObjectTrashMarkersSection => 'Marcadores';

  @override
  String get mapObjectTrashZonesSection => 'Zonas';

  @override
  String get mapObjectTrashRestore => 'Restaurar';

  @override
  String get mapObjectTrashPurge => 'Eliminar definitivamente';

  @override
  String mapObjectTrashDeletedBy(String user) {
    return 'Eliminado por $user';
  }

  @override
  String get mapObjectTrashPurgeConfirmTitle => '¿Eliminar definitivamente?';

  @override
  String mapObjectTrashPurgeConfirmBody(String name) {
    return '“$name” se eliminará para siempre, incluidas las adjuntos.';
  }

  @override
  String get mapObjectTrashPermissionDenied =>
      'No tienes permiso para restaurar o eliminar definitivamente elementos de la papelera.';

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
  String get accessDeleteUser => 'Delete user';

  @override
  String get accessDeleteUserTitle => 'Delete user?';

  @override
  String accessDeleteUserConfirm(String email) {
    return 'Delete $email? This cannot be undone.';
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
  String get settingsAboutTitle => 'Acerca de Wayfinder';

  @override
  String get settingsAboutDescription =>
      'Detalles de compilación y conexión de solo lectura para este cliente. Use el commit de git para confirmar si se está ejecutando la compilación más reciente.';

  @override
  String get settingsAboutOpenManual => 'Open user manual';

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
  String get actionRefresh => 'Refresh';

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
  String get actionImporting => 'Importando…';

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
      'Elija un tema de color para la aplicación. Los temas militares usan tonos oliva, arena y verde bosque. Se guarda en tu cuenta para seguirte en cualquier estación.';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageDescription =>
      'Elija el idioma de la aplicación. Se guarda en tu cuenta para seguirte en cualquier estación.';

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
  String get settingsMapHomePermissionDenied =>
      'No tienes permiso para cambiar la ubicación de inicio compartida del mapa.';

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
  String get settingsServerConnectionPermissionDenied =>
      'No tienes permiso para cambiar la URL del servidor Wayfinder de este dispositivo.';

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
  String get settingsBearingsTitle => 'Rumbos';

  @override
  String get settingsBearingsDescription =>
      'Muestre los rumbos absolutos como norte verdadero (°T) o norte magnético (°M) con la declinación WMM2025 en su GPS o el centro del mapa. La rosa de los vientos sigue marcando el norte verdadero; la variación aparece debajo.';

  @override
  String get bearingReferenceTrue => 'Norte verdadero';

  @override
  String get bearingReferenceMagnetic => 'Norte magnético';

  @override
  String get bearingReferenceTrueShort => 'Verdadero';

  @override
  String get bearingReferenceMagneticShort => 'Magnético';

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
  String get settingsMapEditingTitle => 'Edición del mapa';

  @override
  String get settingsMapEditingDescription =>
      'Ajuste al editar vértices de polígonos y capas estacionales. El imán se suelta si sigue arrastrando más allá del punto de ajuste.';

  @override
  String get settingsPolygonSnapRightAnglesTitle =>
      'Ajustar a ángulos rectos (90°)';

  @override
  String get settingsPolygonSnapRightAnglesDescription =>
      'Al arrastrar un vértice, ajusta suavemente a esquinas cuadradas — también puede cuadrar las esquinas adyacentes para rectángulos más limpios.';

  @override
  String get settingsPolygonSnap45AnglesTitle => 'Ajustar a ángulos de 45°';

  @override
  String get settingsPolygonSnap45AnglesDescription =>
      'También ajusta la esquina arrastrada hacia ángulos de 45° y 135°.';

  @override
  String get settingsMapDisplayTitle => 'Visualización del mapa';

  @override
  String get settingsMapDisplayDescription =>
      'Rosa de los vientos y cuadrícula MGRS de tu cuenta. Se guarda en tu cuenta para seguirte en cualquier estación de trabajo.';

  @override
  String get settingsMapCompassRoseTitle => 'Mostrar rosa de los vientos';

  @override
  String get settingsMapCompassRoseDescription =>
      'Muestra una brújula abajo a la izquierda del mapa (encima de la barra de estado GPS si está visible). Doble toque restablece la rotación; pulsación larga alterna norte verdadero/magnético; botones ±5° rotan el mapa. Variación WMM2025.';

  @override
  String get settingsMapMgrsGridTitle => 'Mostrar cuadrícula MGRS';

  @override
  String get settingsMapMgrsGridDescription =>
      'Superpone una cuadrícula MGRS real (basada en UTM). El espaciado sigue el zoom. Las uniones entre zonas y una ligera curvatura en el mapa Web Mercator son normales: los cuadrados MGRS no son rectángulos de lat/lng.';

  @override
  String get settingsMapZoomRangeTitle => 'Rango de zoom del mapa';

  @override
  String get settingsMapZoomRangeDescription =>
      'Zoom mínimo y máximo compartidos para todos los clientes. Se guarda en el servidor. Subir el máximo puede afectar el rendimiento si las teselas sin conexión no cubren esos niveles.';

  @override
  String get settingsMapZoomRangePermissionDenied =>
      'No tienes permiso para cambiar el rango de zoom compartido del mapa.';

  @override
  String get settingsMapZoomRangeWarning =>
      'Cambiar el rango de zoom puede ralentizar el mapa, aumentar el uso de memoria o mostrar teselas estiradas cuando sus datos sin conexión no incluyen detalle en esos niveles. Solo suba el máximo si sus archivos de mapa lo admiten.';

  @override
  String get settingsMapMinZoom => 'Zoom mínimo';

  @override
  String get settingsMapMaxZoom => 'Zoom máximo';

  @override
  String settingsMapZoomLimitHelper(String min, String max) {
    return '$min–$max';
  }

  @override
  String get settingsMapZoomRangeSave => 'Guardar rango de zoom';

  @override
  String get settingsMapZoomRangeSaved => 'Rango de zoom del mapa guardado.';

  @override
  String get settingsMapZoomRangeInvalid =>
      'Introduzca valores de zoom mínimo y máximo válidos.';

  @override
  String settingsMapZoomRangeSaveFailed(String error) {
    return 'No se pudo guardar el rango de zoom del mapa: $error';
  }

  @override
  String get settingsMapDebugTitle => 'Depuración del mapa';

  @override
  String get settingsMapDebugDescription =>
      'Ayudas visuales guardadas solo en este navegador.';

  @override
  String get settingsMapMarkerSizeTitle => 'Tamaño de marcadores';

  @override
  String get settingsMapMarkerSizeDescription =>
      'Ajuste el tamaño de los marcadores en el mapa. Se guarda en tu cuenta para seguirte en cualquier estación de trabajo.';

  @override
  String settingsMapMarkerSizeValue(int percent) {
    return '$percent %';
  }

  @override
  String get settingsMapMarkerSizeMinLabel => 'Más pequeño';

  @override
  String get settingsMapMarkerSizeMaxLabel => 'Más grande';

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
  String get watchLogTitle => 'Registro de incidentes / guardia';

  @override
  String get watchLogSubtitle =>
      'Eventos con marca de tiempo para revisión posterior. Solo notas de planificación.';

  @override
  String get watchLogPermissionDenied =>
      'No tienes permiso para ver el registro de incidentes / guardia.';

  @override
  String get watchLogAddPermissionDenied =>
      'No tienes permiso para añadir o editar entradas del registro de incidentes / guardia.';

  @override
  String get watchLogObjectHint =>
      'Entradas vinculadas a este objeto del mapa.';

  @override
  String get watchLogSidebarHint =>
      'Más recientes primero en todos los objetos';

  @override
  String get watchLogAddEntry => 'Añadir entrada';

  @override
  String get watchLogAddEntryTitle => 'Añadir entrada al registro';

  @override
  String get watchLogEditEntryTitle => 'Editar entrada del registro';

  @override
  String get watchLogEmpty => 'Aún no hay entradas en el registro.';

  @override
  String get watchLogEmptyForObject =>
      'Aún no hay entradas vinculadas a este objeto.';

  @override
  String watchLogMoreEntries(int count) {
    return '$count más…';
  }

  @override
  String watchLogLoadFailed(String error) {
    return 'No se pudo cargar el registro: $error';
  }

  @override
  String get watchLogOccurredAtLabel => 'Ocurrió a las';

  @override
  String get watchLogAuthorLabel => 'Operador / indicativo';

  @override
  String get watchLogAuthorHint => 'Opcional';

  @override
  String get watchLogSeverityLabel => 'Severidad';

  @override
  String get watchLogSeverityInfo => 'Info';

  @override
  String get watchLogSeverityNotice => 'Aviso';

  @override
  String get watchLogSeverityWarning => 'Advertencia';

  @override
  String get watchLogSeverityCritical => 'Crítico';

  @override
  String get watchLogTextLabel => 'Evento';

  @override
  String get watchLogTextHint => '¿Qué ocurrió?';

  @override
  String get watchLogTextRequired => 'Introduzca el texto del evento.';

  @override
  String get backupTitle => 'Copia de seguridad de datos del mapa';

  @override
  String get backupPermissionDenied =>
      'No tienes permiso para exportar o restaurar copias de seguridad del mapa.';

  @override
  String get backupDescription =>
      'Exporte o restaure datos del mapa Wayfinder: capas, marcadores, zonas, capas estacionales, iconos personalizados y ajustes. Las copias son .zip con backup.json y marker-icons/*.svg. Los paquetes de mareas y PMTiles no se incluyen (transfiéralos desde Mareas / Azulejos). Todavía puede restaurar copias .json antiguas.';

  @override
  String get backupExportButton => 'Exportar datos del mapa (.zip)';

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
      'Esto reemplaza todas las capas, marcadores, zonas, capas estacionales, entradas del registro de guardia e iconos personalizados en el servidor con el archivo seleccionado. Esta acción no se puede deshacer.';

  @override
  String backupRestoreSuccess(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
  ) {
    return 'Restauradas $layers capa(s), $markers marcador(es), $zones zona(s), $seasonalOverlays capa(s) estacional(es) y $watchLogEntries entrada(s) del registro.';
  }

  @override
  String backupRestoreSuccessWithIcons(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int icons,
  ) {
    return 'Restauradas $layers capa(s), $markers marcador(es), $zones zona(s), $seasonalOverlays capa(s) estacional(es), $watchLogEntries entrada(s) del registro y $icons icono(s) personalizado(s).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get markerAttachmentsTitle => 'Fotos';

  @override
  String get markerAttachmentsEmpty =>
      'Aún no hay fotos. Añade una imagen JPEG, PNG o WebP.';

  @override
  String get markerAttachmentsEmptyReadOnly => 'No hay fotos en este marcador.';

  @override
  String get markerAttachmentAdd => 'Añadir foto';

  @override
  String get markerAttachmentUploading => 'Subiendo…';

  @override
  String get markerAttachmentUploadSuccess => 'Foto añadida.';

  @override
  String markerAttachmentUploadFailed(String error) {
    return 'Error al subir la foto: $error';
  }

  @override
  String markerAttachmentLoadFailed(String error) {
    return 'No se pudieron cargar las fotos: $error';
  }

  @override
  String get markerAttachmentDeleteConfirmTitle => '¿Eliminar foto?';

  @override
  String markerAttachmentDeleteConfirmMessage(String fileName) {
    return '¿Quitar \"$fileName\" de este marcador?';
  }

  @override
  String markerAttachmentDeleteFailed(String error) {
    return 'No se pudo eliminar la foto: $error';
  }

  @override
  String get kioskModeTitle => 'Modo kiosco / visor';

  @override
  String get kioskModeDescription =>
      'Convierte este portátil en un visor TOC: oculta Ajustes y herramientas de creación, bloquea ediciones y usa un sondeo más suave para la batería. Úsalo en portátiles de reserva apuntando a tu servidor Wayfinder. Para un servidor de reserva que deba rechazar todas las escrituras, configura WAYFINDER_READ_ONLY=1 en el servidor.';

  @override
  String get kioskModeEnter => 'Entrar en modo kiosco';

  @override
  String get kioskModeExit => 'Salir del kiosco';

  @override
  String get kioskModeEntered =>
      'Modo kiosco activado: este dispositivo es de solo lectura.';

  @override
  String get kioskModeEnterConfirmTitle => '¿Entrar en modo kiosco?';

  @override
  String get kioskModeEnterConfirmMessage =>
      'Los ajustes y la edición del mapa se ocultarán en este dispositivo hasta que salgas del modo kiosco. Otros dispositivos no se ven afectados.';

  @override
  String get kioskModeBannerTitle => 'Modo visor';

  @override
  String get kioskModeBannerHint =>
      'Este portátil es de solo lectura. Puedes desplazar, ampliar, buscar e inspeccionar objetos del mapa.';

  @override
  String get kioskModeBannerServerEnforced =>
      'Este servidor Wayfinder está en solo lectura (WAYFINDER_READ_ONLY). Las escrituras están bloqueadas para todos los clientes.';

  @override
  String get kioskModeSettingsLockedMessage =>
      'Los ajustes están ocultos mientras este dispositivo está en modo kiosco / visor.';

  @override
  String get kioskModeBackToMap => 'Volver al mapa';

  @override
  String get fieldPackTitle => 'Paquete de campo';

  @override
  String get fieldPackDescription =>
      'Un archivo para un servidor o portátil de reserva: objetos del mapa, iconos personalizados y las regiones PMTiles que elijas. Relacionado con los paquetes sin conexión, pero pensado para transferir una instancia completa de Wayfinder en lugar de almacenar teselas en este dispositivo.';

  @override
  String get fieldPackExportButton => 'Exportar paquete de campo';

  @override
  String get fieldPackRestoreButton => 'Restaurar paquete de campo';

  @override
  String get fieldPackSelectPmtilesTitle => 'Incluir PMTiles';

  @override
  String get fieldPackSelectPmtilesMessage =>
      'Elige qué archivos de teselas incluir. Los archivos regionales grandes pueden hacer que el paquete ocupe varios GB.';

  @override
  String get fieldPackSelectPmtilesEmpty =>
      'No hay PMTiles instalados en este servidor. El paquete incluirá solo datos del mapa e iconos.';

  @override
  String get fieldPackSelectAll => 'Seleccionar todo';

  @override
  String get fieldPackSelectNone => 'Seleccionar ninguno';

  @override
  String get fieldPackExportConfirm => 'Exportar';

  @override
  String get fieldPackExportSuccess => 'Paquete de campo guardado.';

  @override
  String fieldPackExportFailed(String error) {
    return 'Error al exportar el paquete de campo: $error';
  }

  @override
  String get fieldPackRestoreConfirmTitle => '¿Restaurar paquete de campo?';

  @override
  String get fieldPackRestoreConfirmMessage =>
      'Esto reemplaza todos los datos del mapa e iconos personalizados en el servidor e instala los archivos PMTiles del paquete (los IDs coincidentes se sobrescriben). Esta acción no se puede deshacer.';

  @override
  String fieldPackRestoreSuccess(
    int layers,
    int markers,
    int zones,
    int seasonalOverlays,
    int watchLogEntries,
    int icons,
    int pmtiles,
  ) {
    return 'Restauradas $layers capa(s), $markers marcador(es), $zones zona(s), $seasonalOverlays capa(s) estacional(es), $watchLogEntries entrada(s) del registro, $icons icono(s) personalizado(s) y $pmtiles archivo(s) PMTiles.';
  }

  @override
  String fieldPackRestoreFailed(String error) {
    return 'Error al restaurar el paquete de campo: $error';
  }

  @override
  String get geoExchangeTitle => 'GPX / KML / GeoJSON';

  @override
  String get geoExchangeDescription =>
      'Importe waypoints y tracks desde GPX, KML o GeoJSON. Si el mapa ya tiene marcadores o zonas, puede añadirlos, reemplazarlos o cancelar. Exporte marcadores como waypoints y líneas/tracks como rutas.';

  @override
  String get geoExchangeImportButton => 'Importar archivo geográfico';

  @override
  String get geoExchangeExportButton => 'Exportar archivo geográfico';

  @override
  String get geoExchangeExportFormatTitle => 'Formato de exportación';

  @override
  String get geoExchangeImportConfirmTitle => '¿Importar datos geográficos?';

  @override
  String geoExchangeImportConfirmMessage(int markers, int zones) {
    return 'El mapa ya tiene $markers marcador(es) y $zones zona(s). Elija Añadir para conservarlos e importar junto a ellos, Reemplazar para eliminar todos los marcadores y zonas primero, o Cancelar para abortar.';
  }

  @override
  String get geoExchangeImportAdd => 'Añadir a existentes';

  @override
  String get geoExchangeImportReplace => 'Reemplazar existentes';

  @override
  String geoExchangeImportSuccess(int markers, int lines) {
    return 'Importados $markers marcador(es) y $lines línea(s).';
  }

  @override
  String get geoExchangeImportEmpty =>
      'No se encontraron waypoints ni tracks en ese archivo.';

  @override
  String geoExchangeImportFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get geoExchangeExportSuccess => 'Exportación geográfica guardada.';

  @override
  String get geoExchangeExportEmpty =>
      'Nada que exportar — añada marcadores o líneas primero.';

  @override
  String geoExchangeExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get geoExchangeFormatGpx => 'GPX';

  @override
  String get geoExchangeFormatKml => 'KML';

  @override
  String get geoExchangeFormatGeojson => 'GeoJSON';

  @override
  String get mapAtlasTitle => 'Atlas cartográfico imprimible';

  @override
  String get mapAtlasDescription =>
      'Exporte un PDF de varias páginas del área actual del mapa (o de todos los marcadores) con el basemap PMTiles habilitado, cuadrícula lat/lng, marcadores, zonas, barra de escala y flecha norte. Las hojas se solapan ligeramente para uso en campo.';

  @override
  String get mapAtlasExportButton => 'Exportar atlas imprimible (PDF)';

  @override
  String get mapAtlasDialogTitle => 'Exportar atlas imprimible';

  @override
  String get mapAtlasDialogDescription =>
      'Elija cobertura, tamaño de página y cuántas hojas imprimir. Las hojas incluyen el basemap PMTiles habilitado más las superposiciones. Cada hoja tiene una etiqueta MGRS aproximada de su centro.';

  @override
  String get mapAtlasTitleLabel => 'Título del atlas';

  @override
  String get mapAtlasCoverageLabel => 'Cobertura';

  @override
  String get mapAtlasCoverageMapView => 'Vista actual del mapa';

  @override
  String get mapAtlasCoverageMarkers => 'Ajustar a marcadores';

  @override
  String get mapAtlasGridLabel => 'Cuadrícula de hojas';

  @override
  String get mapAtlasPageSizeLabel => 'Tamaño de página';

  @override
  String get mapAtlasPageLetter => 'Carta EE. UU. horizontal';

  @override
  String get mapAtlasPageA4 => 'A4 horizontal';

  @override
  String get mapAtlasIncludeMarkerIndex =>
      'Incluir lista de marcadores en cada hoja';

  @override
  String get mapAtlasSheetCountHint => 'Hojas';

  @override
  String get mapAtlasExportSuccess => 'PDF del atlas imprimible guardado.';

  @override
  String mapAtlasExportFailed(String error) {
    return 'Error al exportar el atlas: $error';
  }

  @override
  String get mapAtlasExportNoCoverage =>
      'No se pudo determinar la cobertura del atlas. Abra el mapa primero, o añada marcadores visibles y elija Ajustar a marcadores.';

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
      'Organice archivos cartográficos sin conexión en grupos y elija cuáles se dibujan en el mapa. Los DEM de elevación (nombre con dem, terrarium, terrain-rgb o elevation) se usan para altura puntual y perfiles — actívelos aquí, pero no se dibujan como basemap.';

  @override
  String get mapTilesPermissionDenied =>
      'No tienes permiso para añadir, actualizar u organizar teselas del mapa.';

  @override
  String get mapTilesDemBadge => 'DEM de elevación';

  @override
  String get mapTilesUploadButton => 'Subir archivo .pmtiles';

  @override
  String get mapTilesGetMapsButton => 'Obtener mapas';

  @override
  String get offlinePackPrepareTitle => 'Preparar para sin conexión';

  @override
  String get offlinePackPrepareDescription =>
      'Copie capas seleccionadas y almacene en caché teselas del mapa base para la vista actual, para seguir trabajando si el servidor Wayfinder no está disponible.';

  @override
  String get offlinePackPrepareAction => 'Preparar paquete sin conexión';

  @override
  String get offlinePackPrepareTooltip => 'Preparar para sin conexión';

  @override
  String get offlinePackPrepareTooltipReady =>
      'Paquete listo — toque para actualizar';

  @override
  String get offlinePackNameLabel => 'Nombre del paquete';

  @override
  String get offlinePackDefaultName => 'Paquete sin conexión';

  @override
  String get offlinePackLayersLabel => 'Capas a incluir';

  @override
  String get offlinePackIncludeSeasonalOverlays =>
      'Incluir superposiciones estacionales';

  @override
  String get offlinePackIncludeSeasonalOverlaysHint =>
      'Empaquete todas las superposiciones estacionales solo para verlas sin conexión (aparte de las capas del mapa).';

  @override
  String get offlinePackSeasonalOverlaysNotIncluded =>
      'No hay superposiciones estacionales en este paquete. Vuelva a prepararlo con “Incluir superposiciones estacionales” estando en línea.';

  @override
  String get offlinePackNoLayers => 'No hay capas de mapa disponibles.';

  @override
  String get offlinePackSelectLayersRequired => 'Seleccione al menos una capa.';

  @override
  String offlinePackZoomLabel(int minZoom, int maxZoom) {
    return 'Detalle de teselas (z$minZoom–z$maxZoom)';
  }

  @override
  String get offlinePackZoomRangeInvalid =>
      'El zoom mínimo debe ser menor o igual que el máximo.';

  @override
  String offlinePackEstimate(int tileCount, int archiveCount) {
    return 'Unas $tileCount teselas en $archiveCount mapa(s) base habilitado(s). Los rangos grandes pueden tardar varios minutos y usar mucho almacenamiento en la web.';
  }

  @override
  String offlinePackExistingSummary(
    String name,
    int tileCount,
    int markerCount,
  ) {
    return 'Paquete actual “$name”: $tileCount teselas, $markerCount marcadores.';
  }

  @override
  String get offlinePackPreparing => 'Preparando paquete sin conexión…';

  @override
  String get offlinePackClear => 'Borrar paquete';

  @override
  String offlinePackSynced(int count) {
    return 'Se sincronizaron $count cambio(s) sin conexión al servidor.';
  }

  @override
  String offlineModeBannerTitle(String packName) {
    return 'Sin conexión — $packName';
  }

  @override
  String get offlineModeBannerReadWriteHint =>
      'Mostrando capas del paquete. Puede añadir marcadores, cambiar su capa, borrar marcadores sin sincronizar, grabar tracks GPS y añadir entradas del registro de guardia.';

  @override
  String get offlineDeleteUnsyncedMarker => 'Borrar marcador sin sincronizar';

  @override
  String get offlineDeleteSyncedMarkerDisabled =>
      'Solo se pueden borrar marcadores sin sincronizar hasta que vuelva el servidor';

  @override
  String get offlineGeocodingUnavailable =>
      'Las contribuciones de geocodificación no están disponibles sin conexión.';

  @override
  String offlineModeBannerPending(int count) {
    return '$count cambio(s) pendientes de sincronizar.';
  }

  @override
  String get mapTilesGetMapsTitle => 'Obtener mapas';

  @override
  String get mapTilesGetMapsDescription =>
      'Descargue basemaps regionales Protomaps de Project NOMAD, o un DEM Terrarium de Mapterhorn. El servidor Wayfinder descarga o extrae el archivo; mantenga este diálogo abierto hasta que termine.';

  @override
  String get mapTilesGetMapsBasemapDescription =>
      'Basemaps vectoriales por estado de EE. UU. (Project NOMAD, unos cientos de MB). Busque su estado e Importar: el servidor lo descarga al almacenamiento de mosaicos.';

  @override
  String get mapTilesGetMapsDemDescription =>
      'DEM Terrarium por estado (Mapterhorn). Extraer ejecuta un recorte regional en el servidor Wayfinder; mantenga el diálogo abierto (los estados grandes pueden tardar varios minutos). Prefiera un estado a la opción de planeta al final de la lista.';

  @override
  String get mapTilesGetMapsSearchHint => 'Buscar estados…';

  @override
  String get mapTilesGetMapsImportAction => 'Importar';

  @override
  String get mapTilesGetMapsExtractAction => 'Extraer';

  @override
  String mapTilesGetMapsImporting(String title) {
    return 'Importando $title…';
  }

  @override
  String mapTilesGetMapsExtracting(String title) {
    return 'Extrayendo $title en el servidor…';
  }

  @override
  String mapTilesGetMapsImported(String title) {
    return 'Importado $title.';
  }

  @override
  String mapTilesGetMapsCatalogFailed(String error) {
    return 'No se pudo cargar el catálogo: $error';
  }

  @override
  String get mapTilesGetMapsEmpty => 'Ningún paquete coincide con la búsqueda.';

  @override
  String get mapTilesGetMapsSizeUnknown => 'tamaño desconocido';

  @override
  String get mapTilesGetMapsSizeRegional => 'extracto regional';

  @override
  String get mapTilesGetMapsBasemapBadge => 'Basemap';

  @override
  String mapTilesUploadProgress(String sent, String total) {
    return 'Subiendo $sent / $total';
  }

  @override
  String get mapTilesUploadProgressHint =>
      'Los archivos grandes se suben por partes para que los registros del servidor muestren progreso. Mantén esta pestaña abierta hasta que termine.';

  @override
  String get elevationDemLabel => 'Elevación DEM';

  @override
  String get elevationDemUnavailable => 'Sin cobertura DEM';

  @override
  String get elevationNoDemAvailable =>
      'No hay un DEM de elevación activado. Suba un .pmtiles Terrarium o Terrain-RGB con dem/terrarium/elevation en el nombre y actívelo en Mosaicos del mapa.';

  @override
  String get elevationProfileTitle => 'Perfil de elevación';

  @override
  String get elevationProfileButton => 'Perfil de elevación';

  @override
  String get elevationProfileEmpty =>
      'No se pudieron muestrear elevaciones en esta ruta.';

  @override
  String elevationProfileFailed(String error) {
    return 'No se pudo crear el perfil de elevación: $error';
  }

  @override
  String get elevationProfileFlatHint =>
      'Poco cambio de elevación en esta ruta: el gráfico puede verse casi plano.';

  @override
  String elevationProfileCombinedLegs(int count) {
    return 'Combinado de $count tramos (orden de selección; cada tramo puede invertirse para conectar).';
  }

  @override
  String elevationProfileSelectionCount(int count) {
    return '$count rutas seleccionadas para el perfil de elevación';
  }

  @override
  String get elevationProfileClearSelection => 'Borrar';

  @override
  String get elevationProfileMin => 'Mín';

  @override
  String get elevationProfileMax => 'Máx';

  @override
  String get elevationProfileGain => 'Ascenso';

  @override
  String get elevationProfileLoss => 'Descenso';

  @override
  String elevationClimbToMarker(String name, String delta) {
    return 'Ascenso a $name: $delta';
  }

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
  String get mapTilesDownloadTooltip => 'Descargar archivo';

  @override
  String mapTilesDownloadStarted(String name) {
    return 'Descargando \"$name\"…';
  }

  @override
  String mapTilesDownloadSaved(String name) {
    return 'Se guardó \"$name\".';
  }

  @override
  String mapTilesDownloadFailed(String error) {
    return 'Error al descargar: $error';
  }

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
  String get markerIconsTitle => 'Iconos de marcadores';

  @override
  String get markerIconsDescription =>
      'Sube iconos SVG de marcadores al servidor. Los clientes los cargan en tiempo de ejecución para poder añadir o actualizar iconos sin volver a desplegar la app. Las subidas pueden requerir autenticación REST — configure una clave en Configuración → Acerca de.';

  @override
  String get markerIconsPermissionDenied =>
      'No tienes permiso para gestionar categorías de iconos ni iconos de marcadores personalizados.';

  @override
  String get markerIconsAddButton => 'Añadir icono personalizado';

  @override
  String get markerIconsServerCatalogTitle => 'Catálogo del servidor';

  @override
  String get markerIconsNoServerEntries =>
      'Aún no hay iconos gestionados por el servidor. Añada un icono personalizado o suba un SVG para reemplazar un icono integrado abajo.';

  @override
  String markerIconsLoadFailed(String error) {
    return 'No se pudieron cargar los iconos: $error';
  }

  @override
  String markerIconsEntryCustomSvg(String key) {
    return '$key • SVG personalizado';
  }

  @override
  String markerIconsEntryMaterialFallback(String key) {
    return '$key • icono Material de respaldo';
  }

  @override
  String get markerIconsUploadSvgAction => 'Subir SVG';

  @override
  String get markerIconsEditAction => 'Editar metadatos';

  @override
  String get markerIconsBuiltInTitle => 'Reemplazar iconos integrados';

  @override
  String get markerIconsBuiltInDescription =>
      'Suba un SVG para una clave integrada para reemplazar el arte empaquetado en todos los clientes conectados.';

  @override
  String get markerIconsBuiltInExpandTitle => 'Iconos SVG integrados';

  @override
  String markerIconsBuiltInExpandSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count iconos',
      one: '1 icono',
    );
    return '$_temp0';
  }

  @override
  String markerIconsUploadSuccess(String key) {
    return 'SVG subido para $key';
  }

  @override
  String markerIconsUploadFailed(String error) {
    return 'Error al subir SVG: $error';
  }

  @override
  String get markerIconsCreateTitle => 'Añadir icono de marcador';

  @override
  String markerIconsCreateSuccess(String label) {
    return 'Icono añadido: $label';
  }

  @override
  String markerIconsCreateFailed(String error) {
    return 'No se pudo añadir el icono: $error';
  }

  @override
  String markerIconsUpdateSuccess(String label) {
    return 'Icono actualizado: $label';
  }

  @override
  String markerIconsUpdateFailed(String error) {
    return 'No se pudo actualizar el icono: $error';
  }

  @override
  String get markerIconsDeleteTitle => '¿Eliminar icono de marcador?';

  @override
  String markerIconsDeleteMessage(String label, String key) {
    return '¿Eliminar \"$label\" ($key) del servidor? Los clientes volverán al icono integrado si existe.';
  }

  @override
  String get markerIconsDeleteSuccess => 'Icono eliminado.';

  @override
  String markerIconsDeleteFailed(String error) {
    return 'No se pudo eliminar el icono: $error';
  }

  @override
  String get markerIconsKeyLabel => 'Clave del icono';

  @override
  String get markerIconsKeyHint => 'custom_drone';

  @override
  String get markerIconsKeyRequired => 'La clave del icono es obligatoria.';

  @override
  String get markerIconsKeyInvalid =>
      'Use letras minúsculas, dígitos y guiones bajos (máx. 64).';

  @override
  String get markerIconsLabelField => 'Etiqueta visible';

  @override
  String get markerIconsLabelRequired => 'La etiqueta visible es obligatoria.';

  @override
  String get markerIconsColoredAssetLabel => 'Conservar colores del SVG';

  @override
  String get markerIconsColoredAssetHelp =>
      'Mantener los colores originales en lugar de teñir con el color del marcador.';

  @override
  String markerIconsGlyphScaleLabel(String value) {
    return 'Escala del icono: $value';
  }

  @override
  String get markerIconsPickSvgOptional => 'Elegir SVG (opcional)';

  @override
  String markerIconsPickSvgSelected(String name) {
    return 'SVG: $name';
  }

  @override
  String get markerIconsEditTitle => 'Editar icono de marcador';

  @override
  String get markerIconsCategoryLabel => 'Categoría';

  @override
  String get markerIconBackgroundColorTitle => 'Fondo del icono';

  @override
  String get markerIconBackgroundColorDescription =>
      'Elige el color de relleno detrás de los iconos de marcador en el mapa. Los SVG transparentes se muestran sobre este fondo — ajústalo para mejorar el contraste con tus capas del mapa.';

  @override
  String get markerIconBackgroundColorLabel => 'Color de fondo';

  @override
  String get markerIconCategoryGeneral => 'General';

  @override
  String get markerIconCategoryPlaces => 'Lugares y edificios';

  @override
  String get markerIconCategoryTransportation => 'Transporte';

  @override
  String get markerIconCategoryPeopleAnimals => 'Personas y animales';

  @override
  String get markerIconCategoryInfrastructure => 'Infraestructura';

  @override
  String get markerIconCategoryMilitary => 'Militar y defensa';

  @override
  String get markerIconCategoryEmergency => 'Emergencia y médico';

  @override
  String get markerIconCategorySanitation => 'Saneamiento e higiene';

  @override
  String get markerIconCategoryNaturalDisasters =>
      'Clima y desastres naturales';

  @override
  String get markerIconCategoryShelterPreparedness => 'Refugio y preparación';

  @override
  String get markerIconCategoryRecreation => 'Caza y recolección';

  @override
  String get markerIconCategoryAgriculture => 'Agricultura';

  @override
  String get markerIconCategoryCustom => 'Personnalizado';

  @override
  String get markerIconCategoriesTitle => 'Categorías de iconos';

  @override
  String get markerIconCategoriesDescription =>
      'Organiza los iconos de marcadores en categorías. Las categorías aparecen en el selector de iconos y en los listados de configuración. Al eliminar una categoría, sus iconos pasan a Personalizado.';

  @override
  String markerIconCategoriesExpandSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorías',
      one: '1 categoría',
    );
    return '$_temp0';
  }

  @override
  String get markerIconCategoriesAddButton => 'Añadir categoría';

  @override
  String get markerIconCategoriesCreateTitle => 'Añadir categoría';

  @override
  String get markerIconCategoriesEditTitle => 'Editar categoría';

  @override
  String get markerIconCategoriesKeyLabel => 'Clave de categoría';

  @override
  String get markerIconCategoriesKeyHint => 'mi_categoria';

  @override
  String get markerIconCategoriesKeyRequired =>
      'La clave de categoría es obligatoria.';

  @override
  String get markerIconCategoriesKeyInvalid =>
      'Use letras minúsculas, dígitos y guiones bajos (máx. 64).';

  @override
  String get markerIconCategoriesLabelField => 'Etiqueta visible';

  @override
  String get markerIconCategoriesLabelRequired =>
      'La etiqueta visible es obligatoria.';

  @override
  String markerIconCategoriesCreateSuccess(String label) {
    return 'Categoría añadida: $label';
  }

  @override
  String markerIconCategoriesUpdateSuccess(String label) {
    return 'Categoría actualizada: $label';
  }

  @override
  String get markerIconCategoriesDeleteTitle => '¿Eliminar categoría?';

  @override
  String markerIconCategoriesDeleteMessage(String label, String key) {
    return '¿Eliminar \"$label\" ($key)? Los iconos de esta categoría pasarán a Personalizado.';
  }

  @override
  String get markerIconCategoriesDeleteSuccess => 'Categoría eliminada.';

  @override
  String markerIconCategoriesCreateFailed(String error) {
    return 'No se pudo añadir la categoría: $error';
  }

  @override
  String markerIconCategoriesUpdateFailed(String error) {
    return 'No se pudo actualizar la categoría: $error';
  }

  @override
  String markerIconCategoriesDeleteFailed(String error) {
    return 'No se pudo eliminar la categoría: $error';
  }

  @override
  String get markerIconCategoriesProtectedHint =>
      'Categoría de respaldo integrada (no se puede eliminar)';

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
  String get formUnitLabel => 'Unidad';

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
  String get markerCoordinatesHelp =>
      'Edite la latitud y la longitud para mover el marcador en el mapa.';

  @override
  String get markerRadioTitle => 'Red de radio / ficha de contacto';

  @override
  String get markerRadioEmptyHelp =>
      'Indicativo, frecuencia y modo opcionales para shack / repetidor (no es radio en vivo).';

  @override
  String get markerRadioStructuredHint =>
      'Solo datos estructurados — Wayfinder no transmite ni sintoniza radios.';

  @override
  String markerRadioSummary(String callsign) {
    return '$callsign';
  }

  @override
  String get markerRadioNoCallsign => 'Ficha de contacto';

  @override
  String get markerRadioCallsignLabel => 'Indicativo';

  @override
  String get markerRadioRoleLabel => 'Rol';

  @override
  String get markerRadioRoleShack => 'Ham shack';

  @override
  String get markerRadioRoleRepeater => 'Repetidor';

  @override
  String get markerRadioRoleStation => 'Estación';

  @override
  String get markerRadioRoleNet => 'Red';

  @override
  String get markerRadioRoleOther => 'Otro';

  @override
  String get markerRadioNetNameLabel => 'Red / grupo';

  @override
  String get markerRadioNetNameHint => 'p. ej. ARES del condado';

  @override
  String get markerRadioFrequencyLabel => 'Frecuencia';

  @override
  String get markerRadioModeLabel => 'Modo';

  @override
  String get markerRadioModeFm => 'FM';

  @override
  String get markerRadioModeAm => 'AM';

  @override
  String get markerRadioModeSsb => 'SSB';

  @override
  String get markerRadioModeCw => 'CW';

  @override
  String get markerRadioModeDigi => 'Digital';

  @override
  String get markerRadioModeDmr => 'DMR';

  @override
  String get markerRadioModeOther => 'Otro';

  @override
  String get markerRadioToneLabel => 'Tono / CTCSS';

  @override
  String get markerRadioOffsetLabel => 'Desplazamiento';

  @override
  String get markerRadioNotesLabel => 'Notas de radio';

  @override
  String get markerRadioNotesHint =>
      'Hora de red, cobertura, tip PL — notas breves';

  @override
  String get markerRadioClear => 'Borrar ficha de contacto';

  @override
  String get sidebarFilterRadioContacts => 'Contactos de radio';

  @override
  String get markerInventoryTitle => 'Inventario del alijo';

  @override
  String get markerInventoryEmptyHelp =>
      'Registre suministros en este marcador: cantidad, unidad, caducidad y última auditoría.';

  @override
  String markerInventoryItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get markerInventoryAddItem => 'Añadir artículo';

  @override
  String get markerInventoryRemoveItem => 'Eliminar artículo';

  @override
  String get markerInventoryItemHeading => 'Artículo de inventario';

  @override
  String get markerInventoryNameLabel => 'Nombre del artículo';

  @override
  String get markerInventoryQuantityLabel => 'Cantidad';

  @override
  String get markerInventoryUnitLabel => 'Unidad';

  @override
  String get markerInventoryCategoryLabel => 'Categoría';

  @override
  String get markerInventoryCategoryFood => 'Comida';

  @override
  String get markerInventoryCategoryWater => 'Agua';

  @override
  String get markerInventoryCategoryMedical => 'Médico';

  @override
  String get markerInventoryCategoryAmmo => 'Munición';

  @override
  String get markerInventoryCategoryOther => 'Otro';

  @override
  String get markerInventoryExpiryLabel => 'Fecha de caducidad';

  @override
  String get markerInventorySetExpiry => 'Establecer caducidad';

  @override
  String markerInventoryExpiryValue(String date) {
    return 'Caduca $date';
  }

  @override
  String get markerInventoryClearExpiry => 'Borrar caducidad';

  @override
  String get markerInventoryLastAuditedLabel => 'Última auditoría';

  @override
  String get markerInventorySetLastAudited => 'Establecer última auditoría';

  @override
  String markerInventoryLastAuditedValue(String date) {
    return 'Auditado $date';
  }

  @override
  String get markerInventoryMarkAuditedNow => 'Marcar auditado ahora';

  @override
  String markerInventoryDetailQuantity(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String markerInventoryDetailCategory(String category) {
    return 'Categoría: $category';
  }

  @override
  String get markerInventoryDetailNoExpiry => 'Sin fecha de caducidad';

  @override
  String markerInventoryDetailExpiry(String date) {
    return 'Caduca $date';
  }

  @override
  String get markerInventoryDetailNeverAudited => 'Nunca auditado';

  @override
  String markerInventoryDetailLastAudited(String date) {
    return 'Última auditoría $date';
  }

  @override
  String get markerChecklistsTitle => 'Listas de verificación / SOP';

  @override
  String get markerChecklistsEmptyHelp =>
      'SOP y auditorías del lugar — p. ej. revisión de la mochila de emergencia en el refugio.';

  @override
  String markerChecklistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas',
      one: '1 lista',
    );
    return '$_temp0';
  }

  @override
  String get markerChecklistsAddChecklist => 'Añadir lista';

  @override
  String get markerChecklistsRemoveChecklist => 'Eliminar lista';

  @override
  String get markerChecklistsChecklistHeading => 'Lista de verificación';

  @override
  String get markerChecklistsNameLabel => 'Nombre de la lista';

  @override
  String get markerChecklistsNotesLabel => 'Notas';

  @override
  String get markerChecklistsLastAuditedNever => 'Nunca auditada';

  @override
  String markerChecklistsLastAudited(String date) {
    return 'Última auditoría $date';
  }

  @override
  String get markerChecklistsMarkAudited => 'Marcar auditada ahora';

  @override
  String get markerChecklistsAddItem => 'Añadir elemento';

  @override
  String get markerChecklistsRemoveItem => 'Eliminar elemento';

  @override
  String get markerChecklistsItemLabel => 'Elemento';

  @override
  String get markerChecklistsItemNotesLabel => 'Notas del elemento';

  @override
  String markerChecklistsProgress(int done, int total) {
    return '$done de $total hechos';
  }

  @override
  String get markerTrackingLabel => 'Marcador de seguimiento';

  @override
  String get markerTrackingHelp =>
      'Registre el historial de movimiento como un rastro en el mapa.';

  @override
  String get markerTrackingStatusActive => 'Activo';

  @override
  String get weatherStationCurrentConditions => 'Condiciones actuales';

  @override
  String get weatherDisplayUnitsLabel => 'Unidades';

  @override
  String get weatherNoData =>
      'Aún no hay lecturas meteorológicas. Los datos se almacenan en el servidor cuando llegan desde APRS u otras integraciones locales.';

  @override
  String get weatherFeelsLike => 'Sensación térmica';

  @override
  String get weatherHumidity => 'Humedad';

  @override
  String get weatherWind => 'Viento';

  @override
  String get weatherPrecipitation => 'Precipitación';

  @override
  String get weatherPressure => 'Presión';

  @override
  String get weatherDewPoint => 'Punto de rocío';

  @override
  String get weatherLuminosity => 'Luminosidad';

  @override
  String get weatherSolarRadiation => 'Radiación solar';

  @override
  String get weatherUvIndex => 'Índice UV';

  @override
  String get weatherSnowfall => 'Nevadas';

  @override
  String get weatherWaterLevel => 'Nivel del agua';

  @override
  String get weatherSoilTemperature => 'Temperatura del suelo';

  @override
  String get weatherSoilMoisture => 'Humedad del suelo';

  @override
  String get weatherLeafWetness => 'Humedad foliar';

  @override
  String get weatherIndoorTemperature => 'Temperatura interior';

  @override
  String get weatherIndoorHumidity => 'Humedad interior';

  @override
  String get weatherBatteryVoltage => 'Voltaje de batería';

  @override
  String get weatherWindRun => 'Recorrido del viento';

  @override
  String get weatherStationStatus => 'Estado de la estación';

  @override
  String get weatherSensorHealth => 'Salud del sensor';

  @override
  String get weatherHistoryTitle => 'Lecturas recientes';

  @override
  String weatherSource(String source) {
    return 'Fuente: $source';
  }

  @override
  String weatherUpdatedAt(String time) {
    return 'Actualizado $time';
  }

  @override
  String get weatherConditionClear => 'Despejado';

  @override
  String get weatherConditionPartlyCloudy => 'Parcialmente nublado';

  @override
  String get weatherConditionOvercast => 'Nublado';

  @override
  String get weatherConditionFog => 'Niebla';

  @override
  String get weatherConditionDrizzle => 'Llovizna';

  @override
  String get weatherConditionRain => 'Lluvia';

  @override
  String get weatherConditionSnow => 'Nieve';

  @override
  String get weatherConditionShowers => 'Chubascos';

  @override
  String get weatherConditionThunderstorm => 'Tormenta';

  @override
  String get weatherConditionUnknown => 'Desconocido';

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
  String get trackEditTitle => 'Editar rastro';

  @override
  String get trackTransportationModeLabel => 'Transporte';

  @override
  String get trackTransportationModeOnFoot => 'A pie';

  @override
  String get trackTransportationModeHorse => 'Caballo';

  @override
  String get trackTransportationModeBike => 'Bicicleta';

  @override
  String get trackTransportationModeMotorcycle => 'Motocicleta';

  @override
  String get trackTransportationModeAtv => 'ATV';

  @override
  String get trackTransportationModeLandVehicle => 'Vehículo terrestre';

  @override
  String get trackTransportationModeTruck => 'Camión';

  @override
  String get trackTransportationModeBus => 'Autobús';

  @override
  String get trackTransportationModeRv => 'Vehículo recreativo';

  @override
  String get trackTransportationModeTrain => 'Tren';

  @override
  String get trackTransportationModeAmbulance => 'Ambulancia';

  @override
  String get trackTransportationModeFireTruck => 'Camión de bomberos';

  @override
  String get trackTransportationModeFarmVehicle => 'Vehículo agrícola';

  @override
  String get trackTransportationModeCanoe => 'Canoa';

  @override
  String get trackTransportationModeWatercraft => 'Embarcación';

  @override
  String get trackTransportationModeSailboat => 'Velero';

  @override
  String get trackTransportationModeAircraft => 'Aeronave';

  @override
  String get trackTransportationModeHelicopter => 'Helicóptero';

  @override
  String get trackTransportationModeGlider => 'Planeador';

  @override
  String get trackTransportationModeBalloon => 'Globo';

  @override
  String get trackShowFootstepsLabel => 'Mostrar rastro en el mapa';

  @override
  String get trackShowFootstepsHelp =>
      'Muestra iconos de transporte a lo largo del rastro de movimiento.';

  @override
  String get circleDefaultName => 'Nuevo círculo';

  @override
  String get circleNameHint => 'p. ej. Área de búsqueda, Límite de propiedad';

  @override
  String get circleMeasurementsLabel => 'Medidas';

  @override
  String get circleCenterMoveHelp =>
      'Edite la latitud y la longitud para mover el centro, por ejemplo para que coincida con un marcador.';

  @override
  String get circleInvalidSize =>
      'Introduzca un tamaño válido de al menos 1 m de radio.';

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
  String get mapAtlasTooltip => 'Atlas cartográfico imprimible';

  @override
  String get mapSettingsTooltip => 'Configuración';

  @override
  String get mapManualTooltip => 'User manual';

  @override
  String get mapDeviceLocationTooltip => 'Mi ubicación';

  @override
  String get mapDeviceLocationFollowingTooltip =>
      'Siguiendo tu ubicación (desplaza para detener)';

  @override
  String get mapDeviceLocationStopTooltip =>
      'Mi ubicación (mantén pulsado para ocultar)';

  @override
  String get mapDeviceLocationServiceDisabled =>
      'Los servicios de ubicación están desactivados en este dispositivo.';

  @override
  String get mapDeviceLocationPermissionDenied =>
      'Se denegó el permiso de ubicación.';

  @override
  String get mapDeviceLocationPermissionDeniedForever =>
      'El permiso de ubicación está bloqueado. Actívalo en los ajustes del sistema o del navegador.';

  @override
  String get mapDeviceLocationUnavailable =>
      'No se pudo determinar tu ubicación. En la web, usa HTTPS o localhost.';

  @override
  String get mapDeviceLocationSelectedMarker => 'Marcador seleccionado';

  @override
  String get mapDeviceLocationSelectMarkerHint =>
      'Selecciona un marcador para distancia y rumbo';

  @override
  String mapDeviceLocationToMarker(String name, String range) {
    return 'A $name: $range';
  }

  @override
  String get mapMgrsGridShowTooltip => 'Mostrar cuadrícula MGRS';

  @override
  String get mapMgrsGridHideTooltip => 'Ocultar cuadrícula MGRS';

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
  String get mapObjectTypeTrack => 'Rastro';

  @override
  String get mapObjectTypeCircle => 'Círculo';

  @override
  String get mapObjectTypeRangeRing => 'Anillo de alcance';

  @override
  String get mapObjectDetailCoordinates => 'Coordenadas';

  @override
  String get mapObjectDetailMgrs => 'MGRS';

  @override
  String get mapObjectDetailMgrsUnavailable =>
      'No disponible (fuera de cobertura MGRS)';

  @override
  String get mapObjectDetailElevation => 'Altitud almacenada';

  @override
  String get mapObjectDetailVisibility => 'Visibilidad';

  @override
  String get mapObjectVisibilityVisible => 'Visible';

  @override
  String get mapObjectVisibilityHidden => 'Oculto';

  @override
  String get mapObjectDetailLength => 'Longitud';

  @override
  String get mapObjectDetailPointCount => 'Puntos';

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
  String get sidebarFilterFoodExpiring90Days => 'Comida que caduca en 90 días';

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
  String get sidebarEditTrack => 'Editar rastro';

  @override
  String get sidebarDeleteTrack => 'Eliminar rastro';

  @override
  String get sidebarShowTrack => 'Mostrar rastro';

  @override
  String get sidebarHideTrack => 'Ocultar rastro';

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
  String get geocodingPermissionDenied =>
      'No tienes permiso para configurar el servidor de geocodificación ni gestionar ubicaciones personalizadas.';

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
  String get geocodingServerUrlSaved => 'Geocoding server URL saved.';

  @override
  String get geocodingPlacesSectionTitle => 'Nombres de lugares (geonames.tsv)';

  @override
  String get geocodingDownloadedDatasetsSectionTitle =>
      'Downloaded datasets (OSMNames)';

  @override
  String get geocodingDownloadedDatasetsSectionDescription =>
      'Large planet or regional imports from OSMNames. Custom locations above work without importing these.';

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
  String get mapRadialPolygon => 'Polígono';

  @override
  String get mapRadialMore => 'Más';

  @override
  String get mapRadialBack => 'Atrás';

  @override
  String get mapRadialCopyCoordinates => 'Copiar coordenadas';

  @override
  String get actionDone => 'Listo';

  @override
  String get polygonEditingHint =>
      'Arrastra un vértice para mover · doble clic en un borde para añadir · doble clic en un vértice para quitar (mín. 3) · Listo al terminar';

  @override
  String get mapRadialDeadReckoning => 'Pasos';

  @override
  String get mapRadialViewshed => 'Cuenca visual';

  @override
  String get mapRadialSlope => 'Pendiente / coste';

  @override
  String get mapRadialRangeRing => 'Anillo de alcance';

  @override
  String get mapRadialCoveragePlan => 'Plan de cobertura';

  @override
  String get mapRadialSunMoon => 'Sol / luna';

  @override
  String get mapRadialTides => 'Mareas';

  @override
  String get mapRadialSeasonalOverlay => 'Season';

  @override
  String get mapRadialEvacKit => 'Kit de evacuación';

  @override
  String get tidesTitle => 'Tablas de mareas';

  @override
  String get tidesSubtitle =>
      'Estación costera más cercana desde los paquetes en tu servidor Wayfinder — para cruces en barco.';

  @override
  String get tidesLocationLabel => 'Ubicación';

  @override
  String get tidesAnchorMarker => 'Marcador';

  @override
  String get tidesAnchorHome => 'Inicio';

  @override
  String get tidesAnchorMapPoint => 'Punto del mapa';

  @override
  String get tidesDateLabel => 'Fecha';

  @override
  String get tidesPickDate => 'Elegir fecha';

  @override
  String get tidesMissingLocation =>
      'Elige una ubicación para consultar mareas.';

  @override
  String tidesQueryFailed(String error) {
    return 'No se pudieron cargar las mareas: $error';
  }

  @override
  String get tidesApproximateBanner =>
      'Alturas estimadas por armónicos del paquete costero (no son observaciones NOAA en vivo).';

  @override
  String tidesStationHeading(String name, String id) {
    return '$name ($id)';
  }

  @override
  String tidesStationMeta(String distance, String datum) {
    return 'A $distance · datum $datum';
  }

  @override
  String get tidesExtremesSection => 'Pleamares y bajamares';

  @override
  String get tidesCurveSection => 'Curva de marea';

  @override
  String get tidesNoExtremes => 'No hay extremos para este día.';

  @override
  String get tidesCrossingHint =>
      'Usa bajamar para vados y pleamar para pasos más profundos. Confirma en el lugar.';

  @override
  String get tidesExtremeHigh => 'Pleamar';

  @override
  String get tidesExtremeLow => 'Bajamar';

  @override
  String tidesHeightMeters(String value) {
    return '$value m';
  }

  @override
  String tidesHeightFeet(String value) {
    return '$value ft';
  }

  @override
  String get tidesDistanceUnknown => 'distancia desconocida';

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
  String get tidesSettingsTitle => 'Paquetes de mareas costeras';

  @override
  String get tidesSettingsSubtitle =>
      'Descarga paquetes armónicos NOAA a este servidor Wayfinder. La herramienta Mareas consulta esos paquetes sin conexión (el servidor debe alcanzar NOAA al importar). Guarde paquetes como .wayfinder-tide para restaurarlos sin internet.';

  @override
  String get tidesPermissionDenied =>
      'No tienes permiso para descargar, subir o eliminar paquetes de mareas costeras.';

  @override
  String get tidesInstalledPacks => 'Paquetes instalados';

  @override
  String get tidesTransferHint =>
      'Descargue un paquete a su dispositivo para restaurarlo sin conexión, o suba un archivo .wayfinder-tide. Los paquetes de mareas no forman parte del zip de copia de seguridad del mapa.';

  @override
  String get tidesUploadPack => 'Subir paquete';

  @override
  String get tidesExportPack => 'Guardar archivo del paquete';

  @override
  String tidesExportPackSuccess(String name) {
    return 'Paquete de mareas “$name” guardado.';
  }

  @override
  String tidesExportPackFailed(String error) {
    return 'No se pudo guardar el paquete de mareas: $error';
  }

  @override
  String tidesUploadPackSuccess(String name, int stations) {
    return 'Restaurado “$name” con $stations estaciones.';
  }

  @override
  String tidesUploadPackFailed(String error) {
    return 'No se pudo subir el paquete de mareas: $error';
  }

  @override
  String get tidesNoPacksInstalled =>
      'Aún no hay paquetes. Descarga una región abajo o sube un archivo .wayfinder-tide.';

  @override
  String tidesPackMeta(int stations, String size, String date) {
    return '$stations estaciones · $size · $date';
  }

  @override
  String get tidesGetCoastalPacks => 'Obtener paquetes costeros';

  @override
  String get tidesGetCoastalPacksHint =>
      'Importa hasta ~80 estaciones NOAA de la región. Puede tardar varios minutos.';

  @override
  String get tidesDownloadPack => 'Descargar';

  @override
  String get tidesImportInProgress => 'Descargando paquete costero de NOAA…';

  @override
  String tidesImportSuccess(String name, int stations) {
    return 'Instalado “$name” con $stations estaciones.';
  }

  @override
  String tidesImportFailed(String error) {
    return 'Error de importación: $error';
  }

  @override
  String tidesActionFailed(String error) {
    return 'Error de mareas: $error';
  }

  @override
  String get tidesDeletePack => 'Eliminar paquete';

  @override
  String tidesDeletePackConfirm(String name) {
    return '¿Eliminar el paquete costero “$name” del servidor?';
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
  String get tidesOpenFromEvac => 'Mareas en la ruta';

  @override
  String get sunMoonTitle => 'Sol / luna / crepúsculo';

  @override
  String get sunMoonSubtitle =>
      'Salida y puesta del sol, crepúsculo, fase lunar y ventanas nocturnas sin API, para un lugar y fecha.';

  @override
  String get sunMoonLocationLabel => 'Ubicación';

  @override
  String get sunMoonAnchorMarker => 'Marcador';

  @override
  String get sunMoonAnchorHome => 'Inicio';

  @override
  String get sunMoonAnchorMapPoint => 'Punto del mapa';

  @override
  String get sunMoonDateLabel => 'Fecha';

  @override
  String get sunMoonPickDate => 'Elegir fecha';

  @override
  String get sunMoonTimezoneSection => 'Zona horaria';

  @override
  String get sunMoonTimezoneHint =>
      'Convierte las horas con horario estándar o de verano. Auto sigue las reglas IANA DST de la fecha.';

  @override
  String get sunMoonTimeBaseLabel => 'Mostrar horas como';

  @override
  String get sunMoonTimeBaseZone => 'Zona';

  @override
  String get sunMoonTimeBaseDevice => 'Dispositivo';

  @override
  String get sunMoonTimeBaseUtc => 'UTC';

  @override
  String get sunMoonZoneLabel => 'Zona';

  @override
  String sunMoonZoneLongitude(String iana) {
    return 'Por longitud ($iana)';
  }

  @override
  String get sunMoonDstLabel => 'Ajuste DST';

  @override
  String get sunMoonDstAuto => 'Auto';

  @override
  String get sunMoonDstStandard => 'Estándar';

  @override
  String get sunMoonDstDaylight => 'Verano';

  @override
  String get sunMoonDstAutoHint =>
      'Usar las reglas DST de la zona en cada evento';

  @override
  String get sunMoonDstStandardHint => 'Forzar el desfase estándar (sin DST)';

  @override
  String get sunMoonDstDaylightHint => 'Forzar el desfase de horario de verano';

  @override
  String get sunMoonDstNoDstHint =>
      'Esta zona no tiene reglas IANA DST. Verano aplica +1 hora de planificación al horario estándar.';

  @override
  String get sunMoonTzSummaryUtc => 'Mostrando UTC';

  @override
  String sunMoonTzSummaryDevice(String name, String offset) {
    return 'Dispositivo · $name · $offset';
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
  String get sunMoonMissingLocation => 'Elige una ubicación para calcular.';

  @override
  String get sunMoonNotApplicable => '—';

  @override
  String get sunMoonPolarDay => 'Día polar: el sol no se pone en esta fecha.';

  @override
  String get sunMoonPolarNight => 'Noche polar: el sol no sale en esta fecha.';

  @override
  String get sunMoonSunSection => 'Sol';

  @override
  String get sunMoonSunrise => 'Salida del sol';

  @override
  String get sunMoonSolarNoon => 'Mediodía solar';

  @override
  String get sunMoonSunset => 'Puesta del sol';

  @override
  String get sunMoonTwilightSection => 'Crepúsculo';

  @override
  String get sunMoonCivilDawn => 'Alba civil';

  @override
  String get sunMoonCivilDusk => 'Ocaso civil';

  @override
  String get sunMoonNauticalDawn => 'Alba náutica';

  @override
  String get sunMoonNauticalDusk => 'Ocaso náutico';

  @override
  String get sunMoonAstronomicalDawn => 'Alba astronómica';

  @override
  String get sunMoonAstronomicalDusk => 'Ocaso astronómico';

  @override
  String get sunMoonNightOpsSection => 'Operaciones nocturnas';

  @override
  String get sunMoonNightOpsHint =>
      'Del ocaso náutico al siguiente alba náutica (sol a 12° o más bajo el horizonte).';

  @override
  String get sunMoonNightOpsStart => 'Inicio de oscuridad';

  @override
  String get sunMoonNightOpsEnd => 'Fin de oscuridad';

  @override
  String get sunMoonMoonSection => 'Luna';

  @override
  String get sunMoonPhaseLabel => 'Fase';

  @override
  String get sunMoonPhaseNew => 'Luna nueva';

  @override
  String get sunMoonPhaseWaxingCrescent => 'Creciente';

  @override
  String get sunMoonPhaseFirstQuarter => 'Cuarto creciente';

  @override
  String get sunMoonPhaseWaxingGibbous => 'Gibosa creciente';

  @override
  String get sunMoonPhaseFull => 'Luna llena';

  @override
  String get sunMoonPhaseWaningGibbous => 'Gibosa menguante';

  @override
  String get sunMoonPhaseLastQuarter => 'Cuarto menguante';

  @override
  String get sunMoonPhaseWaningCrescent => 'Menguante';

  @override
  String get sunMoonIlluminationLabel => 'Iluminación';

  @override
  String sunMoonIlluminationValue(int percent) {
    return '$percent%';
  }

  @override
  String get sunMoonAgeLabel => 'Edad';

  @override
  String sunMoonAgeValue(String days) {
    return '$days días';
  }

  @override
  String get sunMoonMoonrise => 'Salida de la luna';

  @override
  String get sunMoonMoonset => 'Puesta de la luna';

  @override
  String get rangeRingTitle => 'Anillo de alcance';

  @override
  String get coveragePlanTitle => 'Plan de cobertura';

  @override
  String get coveragePlanSubtitle =>
      'Coloque sitios sugeridos de repetidor o malla con círculos de alcance. Opcionalmente calcule la cuenca visual (LOS) en la semilla. Solo geometría de planificación — no es RF en vivo.';

  @override
  String get coveragePlanTemplateLabel => 'Plantilla';

  @override
  String get coveragePlanTemplateMesh => 'Malla / LoRa';

  @override
  String get coveragePlanTemplateRepeater => 'Repetidor VHF/UHF';

  @override
  String get coveragePlanTemplateShack => 'Ham shack';

  @override
  String get coveragePlanLayoutLabel => 'Disposición';

  @override
  String get coveragePlanLayoutSingle => 'Un sitio';

  @override
  String get coveragePlanLayoutHexRing => 'Anillo hexagonal (7)';

  @override
  String get coveragePlanAnchorLabel => 'Centro semilla';

  @override
  String get coveragePlanAnchorMarker => 'Marcador';

  @override
  String coveragePlanAnchorMarkerNamed(String name) {
    return 'Marcador: $name';
  }

  @override
  String get coveragePlanAnchorHome => 'Inicio';

  @override
  String get coveragePlanAnchorMapPoint => 'Punto del mapa';

  @override
  String get coveragePlanRadiusLabel => 'Radio de cobertura';

  @override
  String get coveragePlanRadiusHelp =>
      'Círculo de alcance alrededor de cada sitio.';

  @override
  String get coveragePlanSpacingLabel => 'Separación entre sitios';

  @override
  String get coveragePlanSpacingHelp =>
      'Distancia centro a centro del anillo hexagonal (por defecto ~1,7× el radio para solape ligero).';

  @override
  String get coveragePlanCreateMarkers => 'Crear marcadores';

  @override
  String get coveragePlanCreateCircles => 'Crear círculos de alcance';

  @override
  String get coveragePlanRunViewshed => 'Calcular cuenca visual en la semilla';

  @override
  String get coveragePlanRunViewshedHelp =>
      'Calcula LOS por terreno desde la semilla con la antena y el radio de la plantilla.';

  @override
  String coveragePlanSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crea $count sitios',
      one: 'Crea 1 sitio',
    );
    return '$_temp0';
  }

  @override
  String get coveragePlanCreateAction => 'Crear plan';

  @override
  String get coveragePlanMissingCenter =>
      'Elija un centro semilla (marcador, inicio o punto del mapa).';

  @override
  String get coveragePlanInvalidRadius =>
      'Introduzca un radio entre 50 m y 100 km.';

  @override
  String get coveragePlanInvalidSpacing =>
      'Introduzca una separación entre 50 m y 100 km.';

  @override
  String get coveragePlanNeedOutput =>
      'Active marcadores y/o círculos de alcance.';

  @override
  String coveragePlanSiteName(String template, String label) {
    return '$template $label';
  }

  @override
  String coveragePlanCircleNotes(String template) {
    return 'Círculo de cobertura del plan ($template)';
  }

  @override
  String coveragePlanRadioNotes(String template) {
    return 'Colocado por el plan de cobertura ($template)';
  }

  @override
  String coveragePlanCreatedSnack(int markers, int circles) {
    return 'Plan de cobertura: $markers marcador(es), $circles círculo(s).';
  }

  @override
  String get rangeRingHelp =>
      'Calcule un radio de viaje o combustible desde el hogar, un marcador seleccionado (punto de reunión) o el punto del mapa, y guárdelo como círculo.';

  @override
  String get rangeRingCenterLabel => 'Centro';

  @override
  String get rangeRingCenterMarker => 'Marcador';

  @override
  String get rangeRingCenterHome => 'Hogar';

  @override
  String get rangeRingCenterMapPoint => 'Punto del mapa';

  @override
  String get rangeRingNoCenter =>
      'Seleccione un marcador, configure un hogar o mantenga pulsado el mapa primero.';

  @override
  String get rangeRingModeLabel => 'Modo';

  @override
  String get rangeRingBasisLabel => 'Base';

  @override
  String get rangeRingBasisDuration => 'Duración';

  @override
  String get rangeRingBasisFuel => 'Combustible';

  @override
  String get rangeRingDurationHoursLabel => 'Duración (horas)';

  @override
  String rangeRingDurationHelp(String speedKmh) {
    return 'Usa $speedKmh km/h de velocidad planificada (editable en Supuestos).';
  }

  @override
  String get rangeRingFuelAmountLabel => 'Cantidad de combustible';

  @override
  String get rangeRingFuelUnitLabel => 'Unidad';

  @override
  String get rangeRingFuelUnitLiters => 'L';

  @override
  String get rangeRingFuelUnitGallons => 'gal';

  @override
  String rangeRingFuelTankHelp(String amount, String unit) {
    return 'Depósito predeterminado ≈ $amount $unit.';
  }

  @override
  String get rangeRingAssumptionsTitle => 'Supuestos';

  @override
  String get rangeRingSpeedKmhLabel => 'Velocidad (km/h)';

  @override
  String get rangeRingEconomyLabel => 'Consumo (L/100 km)';

  @override
  String get rangeRingEconomyHelp =>
      'Un valor más bajo es más eficiente. El ATV consume más que un coche.';

  @override
  String rangeRingTankLabel(String unit) {
    return 'Capacidad del depósito ($unit)';
  }

  @override
  String get rangeRingUseFullTank => 'Usar depósito lleno';

  @override
  String get rangeRingPreviewEmpty =>
      'Introduzca una duración o cantidad de combustible para previsualizar el radio.';

  @override
  String rangeRingPreviewRadius(String distance) {
    return 'Radio ≈ $distance';
  }

  @override
  String get rangeRingContinue => 'Continuar';

  @override
  String get rangeRingInvalidInput =>
      'Introduzca una duración o cantidad de combustible válida.';

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
    return 'Alcance $mode';
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
  String get mapRadialAddToGeocoding => 'Añadir a búsqueda';

  @override
  String get viewshedTitle => 'Cuenca visual / RF';

  @override
  String get slopeTitle => 'Pendiente / campo a través';

  @override
  String get slopeRangeLabel => 'Alcance';

  @override
  String get slopeOpacityLabel => 'Opacidad';

  @override
  String get slopeModeCost => 'Coste';

  @override
  String get slopeModeSlope => 'Pendiente';

  @override
  String get slopeMobilityWalk => 'A pie';

  @override
  String get slopeMobilityBike => 'Bici';

  @override
  String get slopeMobilityDrive => 'Coche';

  @override
  String get slopeComputeAction => 'Calcular';

  @override
  String get slopeStatusReadyToCompute => 'Listo';

  @override
  String slopeStatusComputing(int percent) {
    return 'Calculando $percent%';
  }

  @override
  String get slopeStatusReady => 'Listo';

  @override
  String get slopeStatusMissingDem => 'Sin datos DEM de elevación';

  @override
  String get slopeStatusError => 'Falló el análisis de pendiente';

  @override
  String slopeStats(String mean, String max) {
    return 'Pendiente media $mean° · Máx $max°';
  }

  @override
  String get slopeLegendHint =>
      'Verde = suave / más fácil · Rojo = empinado / costoso. Solo pendiente DEM — elige A pie, Bici o Coche.';

  @override
  String get slopeLegendHintWalk =>
      'Coste a pie: verde = fácil · rojo = trepada empinada. Solo pendiente DEM (sin senderos).';

  @override
  String get slopeLegendHintBike =>
      'Coste en bici: verde = rodaje fácil · rojo = subida dura. Solo pendiente DEM (sin carreteras).';

  @override
  String get slopeLegendHintDrive =>
      'Coste en coche: verde = pendiente suave · rojo = empinado para vehículos. Solo pendiente DEM (sin red vial).';

  @override
  String get slopeLegendHintSlope =>
      'Ángulo de pendiente: verde = llano · rojo = empinado (~35°+). Grado DEM bruto, no coste de viaje.';

  @override
  String get viewshedInstructions =>
      'Antena = altura del observador sobre el suelo (edificio + mástil). Objetivo = altura AGL del receptor/ojo (0 = suelo). Alcance = distancia a calcular. Las alturas y el alcance usan tus unidades de medida (Ajustes).';

  @override
  String viewshedAntennaHeightLabel(String unit) {
    return 'Ant. ($unit)';
  }

  @override
  String viewshedTargetHeightLabel(String unit) {
    return 'Obj. ($unit)';
  }

  @override
  String get viewshedRangeLabel => 'Alcance';

  @override
  String get viewshedComputeAction => 'Calcular';

  @override
  String get viewshedStatusReadyToCompute => 'Listo';

  @override
  String viewshedStatusComputing(int percent) {
    return 'Calculando… $percent%';
  }

  @override
  String get viewshedStatusReady => 'Listo';

  @override
  String get viewshedStatusMissingDem => 'Sin datos DEM de elevación';

  @override
  String get viewshedStatusMissingElevation => 'Sin elevación en el observador';

  @override
  String get viewshedStatusError => 'Error en la cuenca visual';

  @override
  String viewshedObserverElevation(String ground, String eye) {
    return 'Suelo $ground · ojo $eye';
  }

  @override
  String get mapDeadReckoningTitle => 'Navegación a estima';

  @override
  String get mapDeadReckoningModePaces => 'Pasos';

  @override
  String get mapDeadReckoningModeDistance => 'Distancia';

  @override
  String get mapDeadReckoningHeadingLabel => 'Rumbo';

  @override
  String get mapDeadReckoningPacesLabel => 'Pasos';

  @override
  String get mapDeadReckoningPaceLengthLabel => 'm/paso';

  @override
  String get mapDeadReckoningDistanceLabel => 'Dist';

  @override
  String get mapDeadReckoningPlaceMarker => 'Colocar marcador';

  @override
  String get mapDeadReckoningCreateLine => 'Crear línea';

  @override
  String get mapDeadReckoningMarkerName => 'Estimación DR';

  @override
  String get mapAddToGeocodingSearch => 'Añadir a búsqueda geográfica';

  @override
  String get mapCoordinatesCopied => 'Coordenadas copiadas al portapapeles.';

  @override
  String get mapMgrsCopyTooltip => 'Copiar MGRS';

  @override
  String get mapMgrsCopied => 'MGRS copiado al portapapeles.';

  @override
  String get mapMarkerShareUrlLabel => 'Enlace';

  @override
  String get mapMarkerCopyUrlTooltip => 'Copiar enlace del marcador';

  @override
  String get mapMarkerQrButton => 'Código QR';

  @override
  String get mapMarkerQrTitle => 'Código QR del marcador';

  @override
  String get mapMarkerQrSavePng => 'Guardar imagen';

  @override
  String get mapMarkerQrSaveSvg => 'Guardar vector';

  @override
  String get mapMarkerQrSavedPng => 'Imagen del código QR guardada.';

  @override
  String get mapMarkerQrSavedSvg => 'Vector del código QR guardado.';

  @override
  String mapMarkerQrSaveFailed(String error) {
    return 'No se pudo guardar el código QR: $error';
  }

  @override
  String get mapMarkerUrlCopied =>
      'Enlace del marcador copiado al portapapeles.';

  @override
  String get mapMarkerIdLabel => 'ID del marcador';

  @override
  String get mapMarkerCopyIdTooltip => 'Copiar ID del marcador';

  @override
  String get mapMarkerIdCopied => 'ID del marcador copiado al portapapeles.';

  @override
  String get mapRelativeAngleLabel => 'Rel°';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortCreated => 'Creación';

  @override
  String get sortHue => 'Tono';

  @override
  String get sidebarMergeLines => 'Fusionar líneas';

  @override
  String get sidebarMergeLinesNeedTwo =>
      'Seleccione al menos dos líneas para fusionar.';

  @override
  String get sidebarMergeLinesDone =>
      'Líneas fusionadas. Se conservaron los puntos de control en orden de recorrido.';

  @override
  String sidebarMergeLinesFailed(String error) {
    return 'No se pudieron fusionar las líneas: $error';
  }

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
  String get mapObjectTypePolygon => 'Polígono';

  @override
  String get mapObjectTypeEvacKit => 'Kit de rutas de evacuación';

  @override
  String get evacKitCreateTitle => 'Crear kit de rutas de evacuación';

  @override
  String get evacKitEditTitle => 'Editar kit de rutas de evacuación';

  @override
  String get evacKitDefaultName => 'Kit de evacuación';

  @override
  String get evacKitNameHint => 'Punto de reunión → refugio…';

  @override
  String evacKitFormHelp(int count) {
    return '$count puntos en la ruta principal';
  }

  @override
  String evacKitEtaPreview(String mode, String eta) {
    return '$mode: $eta';
  }

  @override
  String get evacKitPrimaryRouteName => 'Principal';

  @override
  String get evacKitPrimaryRouteNameLabel => 'Nombre de la ruta principal';

  @override
  String get evacKitDefaultModeLabel => 'Modo de viaje predeterminado';

  @override
  String get evacKitShowNameLabel => 'Mostrar nombre en el mapa';

  @override
  String get evacKitAddAlternateTitle => 'Añadir ruta alternativa';

  @override
  String get evacKitRouteNameLabel => 'Nombre de la ruta';

  @override
  String evacKitAlternateRouteName(int index) {
    return 'Alternativa $index';
  }

  @override
  String get evacKitDrawingHint =>
      'Toca para añadir puntos (o toca marcadores). Doble toque o Finalizar (2+). Deshacer quita el último punto.';

  @override
  String get evacKitDrawingFinish => 'Finalizar';

  @override
  String get evacKitDrawingUndo => 'Deshacer';

  @override
  String get evacKitDrawingCancel => 'Cancelar';

  @override
  String get evacKitRoutesLabel => 'Rutas';

  @override
  String get evacKitPrimaryBadge => 'Principal';

  @override
  String get evacKitAlternateBadge => 'Alternativa';

  @override
  String get evacKitWaypointsLabel => 'Puntos';

  @override
  String get evacKitDistanceLabel => 'Distancia';

  @override
  String get evacKitEtaLabel => 'ETA';

  @override
  String get evacKitAddAlternate => 'Añadir ruta alternativa';

  @override
  String get evacKitRemoveAlternate => 'Quitar alternativa';

  @override
  String get evacKitRemoveAlternateConfirm =>
      '¿Quitar esta ruta alternativa del kit?';

  @override
  String get evacKitRemoveRoute => 'Quitar ruta';

  @override
  String get evacKitRemovePrimaryConfirm =>
      '¿Quitar la ruta principal? Elige qué alternativa será la nueva principal.';

  @override
  String evacKitRemovePrimarySingleConfirm(String name) {
    return '¿Quitar la ruta principal? “$name” pasará a ser la principal.';
  }

  @override
  String get evacKitChooseNewPrimary => 'Nueva ruta principal';

  @override
  String get evacKitMakePrimary => 'Hacer principal';

  @override
  String evacKitMakePrimaryConfirm(String name) {
    return '¿Hacer “$name” la ruta principal? La actual pasará a ser alternativa.';
  }

  @override
  String get evacKitCannotRemoveLastRoute =>
      'Un kit debe conservar al menos una ruta.';

  @override
  String get evacKitEditRouteOnMap => 'Editar ruta en el mapa';

  @override
  String get evacKitEditingHint =>
      'Arrastra un waypoint o punto de control para mover · toca un segmento para añadir un punto de control · doble toque en un punto intermedio para convertir waypoint ↔ control · toca el último waypoint para alargar · mantén pulsado un punto intermedio para quitar (mín. 2 waypoints) · Listo al terminar';

  @override
  String get evacKitExtendingHint =>
      'Toca el mapa o marcadores para añadir puntos al final. Listo deja de alargar.';

  @override
  String get sidebarEditEvacKit => 'Editar kit de evacuación';

  @override
  String get sidebarDeleteEvacKit => 'Eliminar kit de evacuación';

  @override
  String get polygonCreateTitle => 'Crear polígono AOI';

  @override
  String get polygonEditTitle => 'Editar polígono AOI';

  @override
  String get polygonDefaultName => 'Polígono';

  @override
  String get polygonNameHint => 'Límite, sector de patrulla, zona prohibida…';

  @override
  String polygonVertexCount(int count) {
    return '$count vértices';
  }

  @override
  String get polygonDrawingHint =>
      'Toca para añadir vértices. Doble toque o Finalizar (3+). Deshacer quita el último punto.';

  @override
  String get polygonFinishAction => 'Finalizar';

  @override
  String get polygonUndoAction => 'Deshacer';

  @override
  String get sidebarHidePolygon => 'Ocultar polígono';

  @override
  String get sidebarShowPolygon => 'Mostrar polígono';

  @override
  String get sidebarEditPolygon => 'Editar polígono';

  @override
  String get sidebarDeletePolygon => 'Eliminar polígono';

  @override
  String get mapObjectDetailVertices => 'Vértices';

  @override
  String get searchSubtitleCoordinates => 'Coordenadas';

  @override
  String get searchSubtitleMgrs => 'MGRS';

  @override
  String get searchSubtitleMarker => 'Marcador';

  @override
  String searchSubtitleZone(String type) {
    return 'Zona ($type)';
  }

  @override
  String searchHint(String example) {
    return 'Buscar lugares, marcadores, zonas, lat/lng o MGRS (p. ej. $example)';
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
  String get markerIconCity => 'Ciudad';

  @override
  String get markerIconTown => 'Pueblo';

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
  String get markerIconMedical => 'Hospital';

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
  String get markerIconPhoto => 'Cámara';

  @override
  String get markerIconPets => 'Mascotas';

  @override
  String get markerIconMan => 'Hombre';

  @override
  String get markerIconWoman => 'Mujer';

  @override
  String get markerIconBoy => 'Niño';

  @override
  String get markerIconGirl => 'Niña';

  @override
  String get markerIconCat => 'Gato';

  @override
  String get markerIconDog => 'Perro';

  @override
  String get markerIconRadioTower => 'Torre de radio';

  @override
  String get markerIconCellTower => 'Torre celular';

  @override
  String get markerIconRadioStation => 'Estación de radio';

  @override
  String get markerIconRadioRepeater => 'Repetidor de radio';

  @override
  String get markerIconMeshNetworkNode => 'Nodo de malla';

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
  String get markerIconPowerPlant => 'Central eléctrica';

  @override
  String get markerIconNuclear => 'Nuclear';

  @override
  String get markerIconNuclearPowerPlant => 'Central nuclear';

  @override
  String get markerIconNuclearWeaponsFacility => 'Instalación nuclear de armas';

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
  String get markerIconPort => 'Puerto';

  @override
  String get markerIconDock => 'Muelle';

  @override
  String get markerIconFerry => 'Ferry';

  @override
  String get markerIconYacht => 'Yate';

  @override
  String get markerIconSailboat => 'Velero';

  @override
  String get markerIconRiverBoat => 'Barco fluvial';

  @override
  String get markerIconAirstrip => 'Pista / Aeropuerto';

  @override
  String get markerIconDefense => 'Defensa';

  @override
  String get markerIconArmyBase => 'Base del Ejército';

  @override
  String get markerIconNavyBase => 'Base naval';

  @override
  String get markerIconMarineCorpsBase => 'Base del Cuerpo de Marines';

  @override
  String get markerIconAirForceBase => 'Base de la Fuerza Aérea';

  @override
  String get markerIconSpaceForceBase => 'Base de la Fuerza Espacial';

  @override
  String get markerIconCoastGuardBase => 'Base de la Guardia Costera';

  @override
  String get markerIconHunting => 'Caza';

  @override
  String get markerIconFishing => 'Pesca';

  @override
  String get markerIconForaging => 'Recolección';

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

  @override
  String get markerIconClinic => 'Clínica';

  @override
  String get markerIconDentist => 'Dentista';

  @override
  String get markerIconDoctorsOffice => 'Consultorio médico';

  @override
  String get markerIconEyeDoctor => 'Oftalmólogo';

  @override
  String get markerIconOnFoot => 'A pie';

  @override
  String get markerIconHorse => 'Caballo';

  @override
  String get markerIconMotorcycle => 'Motocicleta';

  @override
  String get markerIconAtv => 'ATV';

  @override
  String get markerIconTruck => 'Camión';

  @override
  String get markerIconBus => 'Autobús';

  @override
  String get markerIconRv => 'Vehículo recreativo';

  @override
  String get markerIconTrain => 'Tren';

  @override
  String get markerIconAmbulance => 'Ambulancia';

  @override
  String get markerIconFireTruck => 'Camión de bomberos';

  @override
  String get markerIconFarmVehicle => 'Vehículo agrícola';

  @override
  String get markerIconCanoe => 'Canoa';

  @override
  String get markerIconHelicopter => 'Helicóptero';

  @override
  String get markerIconAirplane => 'Avión';

  @override
  String get markerIconGlider => 'Planeador';

  @override
  String get markerIconBalloon => 'Globo';

  @override
  String get markerIconFalloutShelter => 'Refugio antinuclear';

  @override
  String get markerIconStormShelter => 'Refugio contra tormentas';

  @override
  String get markerIconBunker => 'Búnker';

  @override
  String get markerIconWaterWell => 'Pozo de agua';

  @override
  String get markerIconCistern => 'Cisterna';

  @override
  String get markerIconRootCellar => 'Bodega subterránea';

  @override
  String get markerIconGreenhouse => 'Invernadero';

  @override
  String get markerIconFuelDepot => 'Depósito de combustible';

  @override
  String get markerIconTruckStop => 'Parada de camiones';

  @override
  String get markerIconRestStop => 'Área de descanso';

  @override
  String get markerIconEvChargingStation => 'Estación de carga EV';

  @override
  String get markerIconWindTurbine => 'Turbina eólica';

  @override
  String get markerIconHamShack => 'Estación de radioaficionado';

  @override
  String get markerIconSecurityPost => 'Puesto de seguridad';

  @override
  String get markerIconMedicalCache => 'Alijo médico';

  @override
  String get markerIconFirewoodCache => 'Reserva de leña';

  @override
  String get markerIconGrainSilo => 'Silo de grano';

  @override
  String get markerIconSafeRoom => 'Habitación segura';

  @override
  String get markerIconDeconStation => 'Estación de descontaminación';

  @override
  String get markerIconPublicRestroom => 'Baño público';

  @override
  String get markerIconOuthouse => 'Letrina exterior';

  @override
  String get markerIconLatrine => 'Letrina';

  @override
  String get markerIconCompostingToilet => 'Baño compostero';

  @override
  String get markerIconHandWashStation => 'Estación de lavado de manos';

  @override
  String get markerIconSepticTank => 'Fosa séptica';

  @override
  String get markerIconPortableToilet => 'Baño portátil';

  @override
  String get markerIconAmmoCache => 'Alijo de munición';

  @override
  String get markerIconPoliceDepartment => 'Departamento de policía';

  @override
  String get markerIconPostOffice => 'Oficina de correos';

  @override
  String get markerIconArmory => 'Arsenal';

  @override
  String get markerIconPrison => 'Prisión';

  @override
  String get markerIconJail => 'Cárcel';

  @override
  String get markerIconCollege => 'Universidad';

  @override
  String get markerIconFireStation => 'Estación de bomberos';

  @override
  String get markerIconCourthouse => 'Palacio de justicia';

  @override
  String get markerIconLibrary => 'Biblioteca';

  @override
  String get markerIconBank => 'Banco';

  @override
  String get markerIconCemetery => 'Cementerio';

  @override
  String get markerIconWildfire => 'Incendio forestal';

  @override
  String get markerIconTornado => 'Tornado';

  @override
  String get markerIconHurricane => 'Huracán';

  @override
  String get markerIconFlood => 'Inundación';

  @override
  String get markerIconStorm => 'Tormenta';

  @override
  String get markerIconEarthquake => 'Terremoto';

  @override
  String get markerIconVolcano => 'Volcán';

  @override
  String get markerIconTsunami => 'Tsunami';

  @override
  String get markerIconLandslide => 'Deslizamiento';

  @override
  String get markerIconDrought => 'Sequía';

  @override
  String get markerIconBlizzard => 'Ventisca';

  @override
  String get markerIconHail => 'Granizo';

  @override
  String get markerIconSnow => 'Nieve';

  @override
  String get markerIconIcyRoad => 'Carretera helada';

  @override
  String get markerIconTreeDown => 'Árbol caído';

  @override
  String get markerIconPowerLineDown => 'Línea eléctrica caída';

  @override
  String get markerIconHighWind => 'Viento fuerte';

  @override
  String get markerIconIceStorm => 'Tormenta de hielo';

  @override
  String get markerIconRoadBlocked => 'Carretera bloqueada';

  @override
  String get markerIconPowerOutage => 'Corte de energía';

  @override
  String get markerIconWeatherStation => 'Estación meteorológica';

  @override
  String get settingsRestApiTitle => 'Acceso a la API REST';

  @override
  String get settingsRestApiPermissionDenied =>
      'No tienes permiso para gestionar las claves de la API REST.';

  @override
  String get settingsRestApiDescription =>
      'Protege los endpoints REST /api con claves con nombre. Crea una clave distinta para cada app o dispositivo para poder revocar una sin afectar las demás.';

  @override
  String get settingsRestApiStatusLabel => 'Protección';

  @override
  String get settingsRestApiStatusEnabled => 'Activada';

  @override
  String get settingsRestApiStatusDisabled => 'Desactivada';

  @override
  String get settingsRestApiKeysTitle => 'Claves API';

  @override
  String get settingsRestApiKeysEmpty =>
      'Aún no hay claves API. Crea una para cada app o dispositivo que use la API REST.';

  @override
  String get settingsRestApiCreateAction => 'Crear clave API';

  @override
  String get settingsRestApiCreateNameLabel => 'Nombre de la aplicación';

  @override
  String get settingsRestApiCreateNameHint => 'p. ej. Rastreador GPS, Domótica';

  @override
  String get settingsRestApiDeleteAction => 'Eliminar';

  @override
  String get settingsRestApiDeleteConfirmTitle => '¿Eliminar clave API?';

  @override
  String settingsRestApiDeleteConfirmMessage(String name) {
    return 'La clave \"$name\" dejará de funcionar de inmediato. Las demás claves no se verán afectadas.';
  }

  @override
  String get settingsRestApiDeleted => 'Clave API eliminada.';

  @override
  String get settingsRestApiEnvKeyNote =>
      'También hay una clave API configurada en el entorno del servidor. No se puede eliminar desde esta pantalla.';

  @override
  String get settingsRestApiClearAction => 'Eliminar todas las claves';

  @override
  String get settingsRestApiClearConfirmTitle =>
      '¿Eliminar todas las claves API?';

  @override
  String get settingsRestApiClearConfirmMessage =>
      'Se eliminarán todas las claves almacenadas. La API REST quedará abierta salvo que haya una clave de entorno configurada.';

  @override
  String get settingsRestApiCleared =>
      'Se eliminaron todas las claves almacenadas.';

  @override
  String get settingsRestApiGeneratedTitle => 'Nueva clave API';

  @override
  String settingsRestApiGeneratedFor(String name) {
    return 'Creada para $name.';
  }

  @override
  String get settingsRestApiGeneratedMessage =>
      'Copia esta clave ahora. Solo se muestra una vez. Úsala como X-API-Key o Authorization: Bearer <clave>.';

  @override
  String get settingsRestApiCopyAction => 'Copiar clave';

  @override
  String get settingsRestApiCopied => 'Clave API copiada.';

  @override
  String settingsRestApiLoadFailed(String error) {
    return 'No se pudieron cargar los ajustes de la API REST: $error';
  }

  @override
  String get settingsRestApiClientKeyTitle => 'Clave en este dispositivo';

  @override
  String get settingsRestApiClientKeyDescription =>
      'Guarda la clave aquí para que esta app pueda usar respaldos REST (restauración, sincronización de ajustes, etc.).';

  @override
  String get settingsRestApiClientKeyLabel => 'Clave API';

  @override
  String get settingsRestApiSaveClientKeyAction =>
      'Guardar clave en este dispositivo';

  @override
  String get settingsRestApiKeySaved =>
      'Clave API guardada en este dispositivo.';

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
}
