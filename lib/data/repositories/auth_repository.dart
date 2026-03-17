import '../../services/api_service.dart';

class AuthRepository {
  final ApiService api;
  AuthRepository(this.api);

  Future<bool> login(String username, String password) async {
    return true;
  }
}
