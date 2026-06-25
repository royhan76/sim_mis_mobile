
import '../../../../core/storage/session_storage.dart';
import '../models/santri_session.dart';
import '../services/auth_api_service.dart';

class AuthRepository {
  AuthRepository({
    AuthApiService? apiService,
    SessionStorage? sessionStorage,
  })  : _apiService = apiService ?? AuthApiService(),
        _sessionStorage = sessionStorage ?? SessionStorage();

  final AuthApiService _apiService;
  final SessionStorage _sessionStorage;

  Future<SantriSession> login({
    required String username,
    required String password,
  }) async {
    final session = await _apiService.login(username: username, password: password);
    await _sessionStorage.save(session.toStoredJson());
    return session;
  }

  Future<SantriSession?> restoreSession() async {
    final raw = await _sessionStorage.load();
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      return SantriSession.fromStoredString(raw);
    } catch (_) {
      await _sessionStorage.clear();
      return null;
    }
  }

  Future<SantriSession> refreshProfile(SantriSession session) async {
    final fresh = await _apiService.me(session.token);
    await _sessionStorage.save(fresh.toStoredJson());
    return fresh;
  }

  Future<void> logout(SantriSession session) async {
    try {
      await _apiService.logout(session.token);
    } catch (_) {
      // ignore token invalidation errors on the client side
    }

    await _sessionStorage.clear();
  }
}

