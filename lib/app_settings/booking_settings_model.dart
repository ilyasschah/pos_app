import 'dart:convert';

class BookingSettingsModel {
  final String resourceMode;
  final int defaultDurationMinutes;
  final int timeSnappingMinutes;

  const BookingSettingsModel({
    this.resourceMode = 'table',
    this.defaultDurationMinutes = 90,
    this.timeSnappingMinutes = 15,
  });

  static const _validModes = {'table', 'room', 'staff'};

  BookingSettingsModel copyWith({
    String? resourceMode,
    int? defaultDurationMinutes,
    int? timeSnappingMinutes,
  }) =>
      BookingSettingsModel(
        resourceMode: resourceMode ?? this.resourceMode,
        defaultDurationMinutes:
            defaultDurationMinutes ?? this.defaultDurationMinutes,
        timeSnappingMinutes: timeSnappingMinutes ?? this.timeSnappingMinutes,
      );

  Map<String, dynamic> toJson() => {
        'resourceMode': resourceMode,
        'defaultDurationMinutes': defaultDurationMinutes,
        'timeSnappingMinutes': timeSnappingMinutes,
      };

  factory BookingSettingsModel.fromJson(Map<String, dynamic> json) {
    final mode = json['resourceMode'] as String? ?? 'table';
    return BookingSettingsModel(
      resourceMode: _validModes.contains(mode) ? mode : 'table',
      defaultDurationMinutes:
          (json['defaultDurationMinutes'] as num?)?.toInt() ?? 90,
      timeSnappingMinutes:
          (json['timeSnappingMinutes'] as num?)?.toInt() ?? 15,
    );
  }

  static BookingSettingsModel fromJsonStr(String jsonStr) {
    if (jsonStr.isEmpty) return const BookingSettingsModel();
    try {
      return BookingSettingsModel.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return const BookingSettingsModel();
    }
  }

  String toJsonStr() => jsonEncode(toJson());
}
