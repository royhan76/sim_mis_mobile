import '../../../auth/data/models/santri_session.dart';
import '../models/maarif_models.dart';
import '../services/maarif_api_service.dart';

class MaarifRepository {
  MaarifRepository({MaarifApiService? apiService})
      : _apiService = apiService ?? MaarifApiService();

  final MaarifApiService _apiService;

  Future<MaarifOverview> loadOverview(SantriSession session) {
    return _apiService.fetchOverview(
      session.token,
      santriId: session.santri?.santriId,
    );
  }
}
