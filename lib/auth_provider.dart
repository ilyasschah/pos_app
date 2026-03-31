import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'user_model.dart';
import 'api_client.dart';
import 'company_provider.dart';

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User user) {
    state = user;
  }

  void logout() {
    state = null;
  }
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

    final data = response.data as List;
    return data.map((json) => User.fromJson(json)).toList();
  } on DioException catch (e) {
    print("Failed to fetch users: ${e.message}");
    return [];
  } catch (e) {
    print("Unexpected error fetching users: $e");
    return [];
  }
});
