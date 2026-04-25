import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/utils/api_error_parser.dart';

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User user) => state = user;
  void logout() => state = null;
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, User?>(() => CurrentUserNotifier());

final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/Users/GetAllUsers',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});
