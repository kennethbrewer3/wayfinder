import 'package:flutter/material.dart';
import 'package:wayfinder_flutter/l10n/app_localizations.dart';

import '../models/track_transportation_mode.dart';

class TrackTransportationModeField extends StatelessWidget {
  const TrackTransportationModeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TrackTransportationMode value;
  final ValueChanged<TrackTransportationMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<TrackTransportationMode>(
      key: ValueKey(value),
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.trackTransportationModeLabel,
      ),
      items: [
        for (final mode in TrackTransportationMode.values)
          DropdownMenuItem(
            value: mode,
            child: Row(
              children: [
                Icon(mode.icon, size: 20),
                const SizedBox(width: 12),
                Text(mode.label(l10n)),
              ],
            ),
          ),
      ],
      onChanged: (mode) {
        if (mode != null) {
          onChanged(mode);
        }
      },
    );
  }
}
