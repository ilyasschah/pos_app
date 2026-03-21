import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_model.dart';
import 'api_client.dart';
import 'company_provider.dart';

// 1. STATE: The Currently Logged In User
class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, User?>(() => CurrentUserNotifier());

// 2. FETCH: Get All Users — filtered by selected company
final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final dio = createDio();
  final response = await dio.get(
    'https://localhost:7002/api/Users/GetAllUsers',
    queryParameters: {'companyId': company.id},
  );

  final data = response.data as List;
  return data.map((json) => User.fromJson(json))
    .toList();
});
