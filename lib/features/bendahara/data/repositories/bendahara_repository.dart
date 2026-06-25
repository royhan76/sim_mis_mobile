import '../../../auth/data/models/santri_session.dart';
import '../models/bendahara_models.dart';
import '../services/bendahara_api_service.dart';

class BendaharaRepository {
  BendaharaRepository({BendaharaApiService? apiService})
      : _apiService = apiService ?? BendaharaApiService();

  final BendaharaApiService _apiService;

  Future<BendaharaOverview> loadOverview(SantriSession session) {
    return _apiService.fetchOverview(
      session.token,
      santriId: session.santri?.santriId,
    );
  }
}
