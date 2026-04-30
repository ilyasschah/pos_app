import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/bookings/booking_model.dart';

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
