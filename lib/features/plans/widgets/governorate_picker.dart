import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../egypt.dart';

/// What the user picked: a governorate, or the phone's location.
typedef CityChoice = ({Governorate? city});

/// Asks for the home governorate. Resolves to null when dismissed, or to a
/// choice whose city is null for "use my location".
Future<CityChoice?> showGovernoratePicker(
  BuildContext context, {
  Governorate? current,
}) {
  return showModalBottomSheet<CityChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.large),
      ),
    ),
    builder: (_) => _GovernoratePicker(current: current),
  );
}

class _GovernoratePicker extends StatefulWidget {
  const _GovernoratePicker({required this.current});

  final Governorate? current;

  @override
  State<_GovernoratePicker> createState() => _GovernoratePickerState();
}

class _GovernoratePickerState extends State<_GovernoratePicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final query = _query.trim();
    final matches = [
      for (final governorate in egyptGovernorates)
        if (governorate.matches(query)) governorate,
    ];

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.homeCityTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: l10n.searchGovernorate,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                children: [
                  if (query.isEmpty)
                    ListTile(
                      leading: Icon(
                        Icons.my_location_rounded,
                        color: colors.primary,
                      ),
                      title: Text(l10n.useMyLocation),
                      trailing: widget.current == null
                          ? Icon(Icons.check_rounded, color: colors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, (city: null)),
                    ),
                  for (final governorate in matches)
                    ListTile(
                      leading: const Icon(Icons.location_city_outlined),
                      title: Text(governorate.name(language)),
                      trailing: governorate.id == widget.current?.id
                          ? Icon(Icons.check_rounded, color: colors.primary)
                          : null,
                      onTap: () => Navigator.pop(context, (city: governorate)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
