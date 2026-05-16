import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/company/company_model.dart';
import 'package:pos_app/utils/api_error_parser.dart';
import 'package:pos_app/auth/auth_storage.dart';

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User user) => state = user;
  void logout() => state = null;
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  () => CurrentUserNotifier(),
);

final allUsersProvider = FutureProvider<List<User>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final storage = ref.read(authStorageProvider);
    final deviceId = await storage.getOrCreateDeviceId();

    final dio = createDio();
    final response = await dio.get(
      '/Users/GetAllUsers',
      queryParameters: {'companyId': company.id, 'deviceId': deviceId},
    );
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

final allUsersAdminProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final storage = ref.read(authStorageProvider);
    final deviceId = await storage.getOrCreateDeviceId();

    final dio = createDio();
    final response = await dio.get(
      '/Users/GetAllUsers',
      queryParameters: {'companyId': company.id, 'deviceId': deviceId, 'includeDisabled': true},
    );
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  } on DioException catch (e, st) {
    rethrowApiError(e, st);
    return [];
  }
});

final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  Future<void> loadFallbackCompany(int fallbackId) async {
    try {
      final dio = createDio();
      final res = await dio.get(
        '/Company/GetById',
        queryParameters: {'id': fallbackId},
      );
      final company = Company.fromJson(res.data as Map<String, dynamic>);
      _ref.read(selectedCompanyProvider.notifier).update(company);
    } catch (_) {
      _ref
          .read(selectedCompanyProvider.notifier)
          .update(Company(id: fallbackId, name: 'Branch #$fallbackId'));
    }
  }

  Future<void> setDevicePin({
    required int userId,
    required int companyId,
    required String pin,
  }) async {
    final storage = _ref.read(authStorageProvider);
    final deviceId = await storage.getOrCreateDeviceId();
    final dio = createDio();

    await dio.post(
      '/UserDevicePins/SetDevicePin',
      queryParameters: {'companyId': companyId},
      data: {'userId': userId, 'deviceId': deviceId, 'pin': pin},
    );
  }
}

final userManagementProvider = Provider((ref) => UserManagementService());

class UserManagementService {
  Future<void> updateSecurityKey(int companyId, String name, int level) async {
    final dio = createDio();
    await dio.patch(
      '/SecurityKeys/Update',
      queryParameters: {'companyId': companyId},
      data: {'name': name, 'level': level},
    );
  }

  Future<void> deleteUser(int companyId, int userId) async {
    final dio = createDio();
    await dio.delete(
      '/Users/Delete',
      queryParameters: {'id': userId, 'companyId': companyId},
    );
  }

  Future<void> toggleUserStatus(
    int companyId,
    int userId,
    bool isEnabled,
  ) async {
    final dio = createDio();
    await dio.patch(
      '/Users/UpdateUser',
      queryParameters: {'companyId': companyId},
      data: {'id': userId, 'isEnabled': isEnabled},
    );
  }

  Future<void> addUser(int companyId, Map<String, dynamic> userData) async {
    final dio = createDio();
    await dio.post(
      '/Users/Add',
      queryParameters: {'companyId': companyId},
      data: userData,
    );
  }

  Future<void> updateUser(int companyId, Map<String, dynamic> userData) async {
    final dio = createDio();
    await dio.patch(
      '/Users/UpdateUser',
      queryParameters: {'companyId': companyId},
      data: userData,
    );
  }

  Future<void> adminResetPassword(
    int companyId,
    int userId,
    String newPassword,
  ) async {
    final dio = createDio();
    await dio.patch(
      '/Users/AdminResetPassword',
      queryParameters: {'companyId': companyId},
      data: {'userId': userId, 'newPassword': newPassword},
    );
  }
}
