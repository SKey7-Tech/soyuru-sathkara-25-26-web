import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/paper.dart';
import '../../../repositories/paper_repository.dart';

/// Localised label for a paper's medium — the language the PDF is written in.
String mediumLabel(AppLocalizations l10n, AppLanguage medium) =>
    switch (medium) {
      AppLanguage.si => l10n.mediumSi,
      AppLanguage.en => l10n.mediumEn,
      AppLanguage.ta => l10n.mediumTa,
    };

/// Localised label for a paper type.
String paperTypeLabel(AppLocalizations l10n, PaperType type) => switch (type) {
      PaperType.past => l10n.paperTypePast,
      PaperType.model => l10n.paperTypeModel,
      PaperType.term => l10n.paperTypeTerm,
      PaperType.notes => l10n.paperTypeNotes,
    };

/// DEV B. The year / medium / type filter row above the papers list.
///
/// [scope] is null on the global Papers tab and the subject id inside a
/// subject's Papers tab, so the two keep independent selections.
///
/// A filter group with fewer than two options is hidden entirely: with the
/// seeded content every paper is from 2026, and a "2026" chip that can only
/// ever be on or off with the same result is pure clutter.
class PaperFilterChips extends ConsumerWidget {
  const PaperFilterChips({super.key, required this.scope});

  final String? scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(paperFilterOptionsProvider(scope));
    final filter = ref.watch(paperFilterProvider(scope));
    final controller = ref.read(paperFilterProvider(scope).notifier);

    final showMedium = options.mediums.length > 1;
    final showType = options.types.length > 1;
    final showYear = options.years.length > 1;

    if (!showMedium && !showType && !showYear) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 8,
            children: [
              if (showMedium)
                for (final medium in options.mediums)
                  FilterChip(
                    label: Text(mediumLabel(l10n, medium)),
                    selected: filter.medium == medium,
                    // Tapping the selected chip clears it, so there is no need
                    // for a separate "All" chip per group.
                    onSelected: (selected) => controller.setMedium(
                      selected ? medium : null,
                    ),
                  ),
              if (showMedium && (showType || showYear))
                const _ChipDivider(),
              if (showType)
                for (final type in options.types)
                  FilterChip(
                    label: Text(paperTypeLabel(l10n, type)),
                    selected: filter.type == type,
                    onSelected: (selected) =>
                        controller.setType(selected ? type : null),
                  ),
              if (showType && showYear) const _ChipDivider(),
              if (showYear)
                for (final year in options.years)
                  FilterChip(
                    label: Text('$year'),
                    selected: filter.year == year,
                    onSelected: (selected) =>
                        controller.setYear(selected ? year : null),
                  ),
            ],
          ),
        ),
        if (!filter.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: TextButton.icon(
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: Text(l10n.filterClear),
            ),
          ),
      ],
    );
  }
}

class _ChipDivider extends StatelessWidget {
  const _ChipDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 22,
        child: VerticalDivider(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
