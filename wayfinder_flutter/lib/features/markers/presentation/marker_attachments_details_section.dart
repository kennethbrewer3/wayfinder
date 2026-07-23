import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wayfinder_client/wayfinder_client.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../../../core/logging/app_logger.dart';
import '../../access/providers/access_session_provider.dart';
import '../../kiosk/providers/kiosk_mode_provider.dart';
import '../../offline_packs/providers/server_reachability_provider.dart';
import '../data/marker_attachment_repository.dart';

final markerAttachmentsProvider =
    FutureProvider.family<List<MarkerAttachment>, String>((ref, markerId) {
      return ref
          .watch(markerAttachmentRepositoryProvider)
          .listForMarker(UuidValue.fromString(markerId));
    });

class MarkerAttachmentsDetailsSection extends ConsumerStatefulWidget {
  const MarkerAttachmentsDetailsSection({
    super.key,
    required this.marker,
  });

  final MapMarker marker;

  @override
  ConsumerState<MarkerAttachmentsDetailsSection> createState() =>
      _MarkerAttachmentsDetailsSectionState();
}

class _MarkerAttachmentsDetailsSectionState
    extends ConsumerState<MarkerAttachmentsDetailsSection> {
  static final _log = AppLogger.logMarkers;
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    setState(() => _uploading = true);
    try {
      await ref
          .read(markerAttachmentRepositoryProvider)
          .uploadPickedFile(
            markerId: widget.marker.id,
            file: result.files.single,
          );
      ref.invalidate(markerAttachmentsProvider(widget.marker.id.uuid));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.markerAttachmentUploadSuccess)),
      );
    } catch (error, stackTrace) {
      _log.error(
        '🖼️ Marker attachment upload failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.markerAttachmentUploadFailed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _delete(MarkerAttachment attachment) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.markerAttachmentDeleteConfirmTitle),
          content: Text(
            l10n.markerAttachmentDeleteConfirmMessage(attachment.fileName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionDelete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(markerAttachmentRepositoryProvider).delete(attachment.id);
      ref.invalidate(markerAttachmentsProvider(widget.marker.id.uuid));
    } catch (error, stackTrace) {
      _log.error(
        '🖼️ Marker attachment delete failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.markerAttachmentDeleteFailed(error.toString())),
        ),
      );
    }
  }

  void _openFullscreen(MarkerAttachment attachment) {
    final url = ref
        .read(markerAttachmentRepositoryProvider)
        .fileUrl(attachment.storageId);
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final offline = ref.watch(offlineModeActiveProvider);
    final kiosk = ref.watch(kioskModeActiveProvider);
    final roleLocked = ref.watch(mapEditsLockedByRoleProvider);
    final canEdit = !offline && !kiosk && !roleLocked;
    final attachmentsAsync = ref.watch(
      markerAttachmentsProvider(widget.marker.id.uuid),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.55,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.markerAttachmentsTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  if (canEdit)
                    TextButton.icon(
                      onPressed: _uploading ? null : _pickAndUpload,
                      icon: _uploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(
                        _uploading
                            ? l10n.markerAttachmentUploading
                            : l10n.markerAttachmentAdd,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              attachmentsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (error, _) => Text(
                  l10n.markerAttachmentLoadFailed(error.toString()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (attachments) {
                  if (attachments.isEmpty) {
                    return Text(
                      canEdit
                          ? l10n.markerAttachmentsEmpty
                          : l10n.markerAttachmentsEmptyReadOnly,
                      style: theme.textTheme.bodySmall,
                    );
                  }
                  return SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachments.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final attachment = attachments[index];
                        final url = ref
                            .read(markerAttachmentRepositoryProvider)
                            .fileUrl(attachment.storageId);
                        return _AttachmentThumb(
                          url: url,
                          fileName: attachment.fileName,
                          canDelete: canEdit,
                          onOpen: () => _openFullscreen(attachment),
                          onDelete: () => _delete(attachment),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentThumb extends StatelessWidget {
  const _AttachmentThumb({
    required this.url,
    required this.fileName,
    required this.canDelete,
    required this.onOpen,
    required this.onDelete,
  });

  final String url;
  final String fileName;
  final bool canDelete;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onOpen,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
          ),
          if (canDelete)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: fileName,
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(28, 28),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
