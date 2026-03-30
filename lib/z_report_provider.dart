import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'z_report_model.dart';

final allZReportsProvider = FutureProvider.autoDispose<List<ZReportModel>>((ref) async {
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/ZReports/GetAll',
      queryParameters: {'companyId': companyId},
    );
    return (response.data as List).map((j) => ZReportModel.fromJson(j)).toList();
  } catch (e) {
    return [];
  }
});