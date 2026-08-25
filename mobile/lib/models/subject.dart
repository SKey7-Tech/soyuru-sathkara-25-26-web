import 'package:flutter/material.dart';

import '../core/app_language.dart';
import '../core/colors.dart';

/// SHARED — frozen after Phase 0. Mirrors the `subjects` table.
class Subject {
  const Subject({
    required this.id,
    required this.nameEn,
    required this.nameSi,
    required this.nameTa,
    this.icon,
    this.colorHex,
    this.orderIndex = 0,
  });

  final String id;
  final String nameEn;
  final String nameSi;
  final String nameTa;

  /// A Material icon name (e.g. 'calculate'), resolved by [iconData].
  final String? icon;
  final String? colorHex;
  final int orderIndex;

  factory Subject.fromMap(Map<String, dynamic> map) => Subject(
        id: map['id'] as String,
        nameEn: map['name_en'] as String,
        nameSi: map['name_si'] as String,
        nameTa: map['name_ta'] as String,
        icon: map['icon'] as String?,
        colorHex: map['color_hex'] as String?,
        orderIndex: (map['order_index'] as int?) ?? 0,
      );

  String nameFor(AppLanguage language) => switch (language) {
        AppLanguage.en => nameEn,
        AppLanguage.si => nameSi,
        AppLanguage.ta => nameTa,
      };

  Color get color => AppColors.fromHex(colorHex);

  /// Resolves the `icon` text column to a real glyph.
  ///
  /// An explicit map rather than a dynamic lookup: Flutter's icon tree-shaker
  /// can only keep glyphs it can see referenced at compile time, so building
  /// IconData from a runtime string either breaks in release builds or forces
  /// --no-tree-shake-icons and drags the entire Material font into the APK.
  /// On a low-end-Android target that is not a trade worth making.
  ///
  /// To support a new subject icon: add its name to `subjects.icon` in the
  /// database and add the same name here.
  IconData get iconData => _icons[icon] ?? Icons.menu_book_rounded;

  static const Map<String, IconData> _icons = {
    'calculate': Icons.calculate_rounded,
    'science': Icons.science_rounded,
    'biotech': Icons.biotech_rounded,
    'book': Icons.menu_book_rounded,
    'language': Icons.translate_rounded,
    'history': Icons.history_edu_rounded,
    'public': Icons.public_rounded,
    'brush': Icons.brush_rounded,
  };

  @override
  bool operator ==(Object other) => other is Subject && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
