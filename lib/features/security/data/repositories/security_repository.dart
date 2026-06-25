import '../../../auth/data/models/santri_session.dart';
import '../models/security_models.dart';
import '../services/security_api_service.dart';

class SecurityRepository {
  SecurityRepository({SecurityApiService? apiService})
      : _apiService = apiService ?? SecurityApiService();

  final SecurityApiService _apiService;

  Future<SecurityOverview> loadOverview(SantriSession session) async {
    final token = session.token;
    final santriId = session.santri?.santriId;

    SecurityPelanggaranBundle? pelanggaran;
    SecurityIzinBundle? izin;

    try {
      pelanggaran = await _apiService.fetchPelanggaran(token, santriId: santriId);
    } catch (_) {}

    try {
      izin = await _apiService.fetchIzin(token, santriId: santriId);
    } catch (_) {}

    final santri = pelanggaran?.santri ?? izin?.santri ?? session.santri;

    if (santri == null) {
      throw Exception('Data santri tidak ditemukan.');
    }

    return SecurityOverview(
      santri: santri,
      pelanggaran: pelanggaran?.records ?? [],
      izin: izin?.records ?? [],
    );
  }
}
