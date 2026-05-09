import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/dashboard/dashboard_model.dart';

class DashboardDateRange {
  final DateTime start;
  final DateTime end;

  const DashboardDateRange({required this.start, required this.end});
}

class DashboardDateNotifier extends Notifier<DashboardDateRange> {
  @override
  DashboardDateRange build() {
    final now = DateTime.now();
    return DashboardDateRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void update(DashboardDateRange range) => state = range;
}

final dashboardDateProvider =
    NotifierProvider<DashboardDateNotifier, DashboardDateRange>(
        () => DashboardDateNotifier());

Future<DashboardData> _fetch(
    int companyId, DateTime start, DateTime end) async {
  final dio = createDio();
  final res = await dio.get(
    '/Dashboard/GetDashboardData',
    queryParameters: {
      'companyId': companyId,
      'startDate': start.toIso8601String(),
      'endDate': end.toIso8601String(),
    },
  );
  return DashboardData.fromJson(res.data as Map<String, dynamic>);
}

// Fetches the full current year — used by the yearly overview bar chart.
final yearlyDashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return DashboardData.empty;
  final year = DateTime.now().year;
  return _fetch(company.id, DateTime(year, 1, 1),
      DateTime(year, 12, 31, 23, 59, 59));
});

// Fetches data for the user-selected date range — used by the 5 periodic cards.
final periodicDashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return DashboardData.empty;
  final range = ref.watch(dashboardDateProvider);
  return _fetch(company.id, range.start, range.end);
});
