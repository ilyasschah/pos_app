import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/bookings/booking_model.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';

final selectedBookingDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final allBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];
  final dio = createDio();
  final response = await dio.get(
    '/Bookings/GetAll',
    queryParameters: {'companyId': company.id},
  );
  return (response.data as List).map((j) => Booking.fromJson(j)).toList();
});

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// All floor-plan tables across every floor plan for the company.
/// Used by the booking dialog's Room/Resource dropdown.
final allRoomsProvider = FutureProvider.autoDispose<List<FloorPlanTable>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final plans = await ref.watch(allFloorPlansProvider.future);
  if (plans.isEmpty) return [];

  final dio = createDio();
  final tables = <FloorPlanTable>[];

  for (final plan in plans) {
    try {
      final response = await dio.get(
        '/FloorPlanTables/GetByFloorPlanId',
        queryParameters: {'floorPlanId': plan.id, 'companyId': company.id},
      );
      tables.addAll(
        (response.data as List).map((j) => FloorPlanTable.fromJson(j)),
      );
    } catch (_) {}
  }

  return tables;
});
