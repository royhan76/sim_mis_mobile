class BendaharaSummaryItem {
  BendaharaSummaryItem({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final int value;
  final String note;

  factory BendaharaSummaryItem.fromJson(Map<String, dynamic> json) {
    return BendaharaSummaryItem(
      label: '${json['label'] ?? '-'}',
      value: json['value'] is int ? json['value'] as int : int.tryParse('${json['value']}') ?? 0,
      note: '${json['note'] ?? '-'}',
    );
  }
}

class BendaharaUnitItem {
  BendaharaUnitItem({
    required this.id,
    required this.namaUnit,
    required this.nominalRupiah,
    required this.tanggalBayar,
    required this.keterangan,
  });

  final int id;
  final String namaUnit;
  final String nominalRupiah;
  final String tanggalBayar;
  final String keterangan;

  factory BendaharaUnitItem.fromJson(Map<String, dynamic> json) {
    return BendaharaUnitItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      namaUnit: '${json['nama_unit'] ?? json['name'] ?? '-'}',
      nominalRupiah: '${json['nominal_rupiah'] ?? '-'}',
      tanggalBayar: '${json['tanggal_bayar'] ?? '-'}',
      keterangan: '${json['keterangan'] ?? '-'}',
    );
  }
}

class BendaharaSyahriyahItem {
  BendaharaSyahriyahItem({
    required this.id,
    required this.bulan,
    required this.tahunHijriyah,
    required this.nominal,
    required this.nominalRupiah,
    required this.tanggalBayar,
    required this.keterangan,
  });

  final int id;
  final String bulan;
  final String tahunHijriyah;
  final int nominal;
  final String nominalRupiah;
  final String tanggalBayar;
  final String keterangan;

  factory BendaharaSyahriyahItem.fromJson(
    Map<String, dynamic> json, {
    int? fallbackNominal,
  }) {
    final nominal = json['nominal'] is int
        ? json['nominal'] as int
        : int.tryParse('${json['nominal']}') ?? 0;
    final effectiveNominal =
        nominal > 0 ? nominal : (fallbackNominal != null && fallbackNominal > 0 ? fallbackNominal : 0);

    return BendaharaSyahriyahItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      bulan: '${json['bulan'] ?? '-'}',
      tahunHijriyah: '${json['tahun_hijriyah'] ?? '-'}',
      nominal: effectiveNominal,
      nominalRupiah: effectiveNominal > 0
          ? 'Rp ${_formatRupiah(effectiveNominal)}'
          : '${json['nominal_rupiah'] ?? '-'}',
      tanggalBayar: '${json['tanggal_bayar'] ?? '-'}',
      keterangan: '${json['keterangan'] ?? '-'}',
    );
  }
}

class BendaharaTransactionItem {
  BendaharaTransactionItem({
    required this.id,
    required this.jenis,
    required this.detail,
    required this.nominalRupiah,
    required this.tanggalBayar,
    required this.keterangan,
  });

  final int id;
  final String jenis;
  final String detail;
  final String nominalRupiah;
  final String tanggalBayar;
  final String keterangan;

  factory BendaharaTransactionItem.fromJson(Map<String, dynamic> json) {
    return BendaharaTransactionItem(
      id: json['transaksi_id'] is int ? json['transaksi_id'] as int : int.tryParse('${json['transaksi_id']}') ?? 0,
      jenis: '${json['jenis'] ?? '-'}',
      detail: '${json['detail'] ?? '-'}',
      nominalRupiah: '${json['nominal_rupiah'] ?? '-'}',
      tanggalBayar: '${json['tanggal_bayar'] ?? '-'}',
      keterangan: '${json['keterangan'] ?? '-'}',
    );
  }
}

class BendaharaOverview {
  BendaharaOverview({
    required this.santri,
    required this.summary,
    required this.unitSudahBayar,
    required this.unitBelumBayar,
    required this.syahriyahSudahBayar,
    required this.syahriyahBelumBayar,
    required this.syahriyahNominal,
    required this.tahunHijriyah,
    required this.transaksi,
  });

  final Map<String, dynamic> santri;
  final List<BendaharaSummaryItem> summary;
  final List<BendaharaUnitItem> unitSudahBayar;
  final List<BendaharaUnitItem> unitBelumBayar;
  final List<BendaharaSyahriyahItem> syahriyahSudahBayar;
  final List<String> syahriyahBelumBayar;
  final int syahriyahNominal;
  final String tahunHijriyah;
  final List<BendaharaTransactionItem> transaksi;

  factory BendaharaOverview.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? const {});
    final summaryMap = Map<String, dynamic>.from(data['summary'] as Map? ?? const {});
    final santri = Map<String, dynamic>.from(data['santri'] as Map? ?? const {});
    final syahriyahNominal = _parseInt(summaryMap['syahriyah_nominal']);
    final unitSudahBayar = (data['unit_sudah_bayar'] as List? ?? const [])
        .map((item) => BendaharaUnitItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final basePaymentMode = _resolvePaymentMode(
      santri['payment_mode'],
      santri['status'],
    );
    final lockedDaftarAwalUnit = _resolveLockedDaftarAwalUnit(
          santri['locked_daftar_awal_unit'],
        ) ??
        _resolveLockedDaftarAwalUnitFromPaidUnits(unitSudahBayar);
    final effectivePaymentMode = _resolveEffectivePaymentMode(
      basePaymentMode,
      lockedDaftarAwalUnit,
    );
    final statusKey = _resolveStatusKey(santri['status']);

    return BendaharaOverview(
      santri: santri,
      summary: [
        BendaharaSummaryItem(
          label: 'Total Dibayar',
          value: _parseInt(summaryMap['total_dibayar']),
          note: 'Gabungan unit dan syahriyah yang sudah dibayar.',
        ),
        BendaharaSummaryItem(
          label: 'Unit Dibayar',
          value: _parseInt(summaryMap['unit_transaksi']),
          note: 'Jumlah unit pembayaran yang tercatat.',
        ),
        BendaharaSummaryItem(
          label: 'Syahriyah Dibayar',
          value: _parseInt(summaryMap['syahriyah_transaksi']),
          note: 'Jumlah bulan syahriyah yang sudah dibayar.',
        ),
      ],
      unitSudahBayar: unitSudahBayar,
      unitBelumBayar: (data['unit_belum_bayar'] as List? ?? const [])
          .map((item) => BendaharaUnitItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .where(
            (item) => _isAllowedUnitForPaymentMode(
              item.namaUnit,
              effectivePaymentMode,
              lockedDaftarAwalUnit,
              statusKey,
            ),
          )
          .toList(),
      syahriyahSudahBayar: (data['syahriyah_sudah_bayar'] as List? ?? const [])
          .map(
            (item) => BendaharaSyahriyahItem.fromJson(
              Map<String, dynamic>.from(item as Map),
              fallbackNominal: syahriyahNominal,
            ),
          )
          .toList(),
      syahriyahBelumBayar: (data['syahriyah_belum_bayar'] as List? ?? const []).map((e) => '$e').toList(),
      syahriyahNominal: syahriyahNominal,
      tahunHijriyah: '${summaryMap['tahun_hijriyah'] ?? '-'}',
      transaksi: (data['transaksi'] as List? ?? const [])
          .map((item) => BendaharaTransactionItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }

  return int.tryParse('$value') ?? 0;
}

String _formatRupiah(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    final reverseIndex = digits.length - index;
    buffer.write(digits[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

String? _resolvePaymentMode(dynamic paymentMode, dynamic status) {
  final direct = '${paymentMode ?? ''}'.trim().toLowerCase();
  if (direct == 'baru' || direct == 'lama') {
    return direct;
  }

  final normalizedStatus = '${status ?? ''}'.trim().toLowerCase();
  if (normalizedStatus.contains('baru')) {
    return 'baru';
  }
  if (normalizedStatus.contains('lama')) {
    return 'lama';
  }

  return null;
}

String? _resolveLockedDaftarAwalUnit(dynamic value) {
  final normalized = '${value ?? ''}'.trim().toUpperCase();
  if (normalized == 'DB' || normalized == 'DU') {
    return normalized;
  }
  return null;
}

String? _resolveLockedDaftarAwalUnitFromPaidUnits(
  List<BendaharaUnitItem> paidUnits,
) {
  var hasDb = false;
  var hasDu = false;

  for (final item in paidUnits) {
    final code = _resolveUnitCode(item.namaUnit);
    if (code == 'DB') {
      hasDb = true;
    } else if (code == 'DU') {
      hasDu = true;
    }
  }

  if (hasDb && !hasDu) {
    return 'DB';
  }
  if (hasDu && !hasDb) {
    return 'DU';
  }
  if (hasDb && hasDu) {
    return 'DB';
  }

  return null;
}

bool _isAllowedUnitForPaymentMode(
  String unitName,
  String? paymentMode,
  String? lockedDaftarAwalUnit,
  String statusKey,
) {
  final unitCode = _resolveUnitCode(unitName);
  if (unitCode == null) {
    return true;
  }

  final isDaftarBaru = unitCode == 'DB';
  final isDaftarUlang = unitCode == 'DU';
  final isBaruVariant = {'DB', 'SARP_B', 'PENG_B', 'KTS', 'SER'}.contains(unitCode);
  final isLamaVariant = {'DU', 'SARP_L', 'PENG_L'}.contains(unitCode);

  if (lockedDaftarAwalUnit == 'DB' && isLamaVariant) {
    return false;
  }

  if (lockedDaftarAwalUnit == 'DU' && isBaruVariant) {
    return false;
  }

  if (paymentMode == null) {
    return true;
  }

  if (paymentMode == 'baru' && isLamaVariant) {
    return false;
  }

  if (paymentMode == 'lama' && isBaruVariant) {
    return false;
  }

  final allowedUnits = _allowedUnitCodesFor(statusKey, paymentMode);
  if (!allowedUnits.contains(unitCode)) {
    return false;
  }

  return true;
}

String? _resolveEffectivePaymentMode(
  String? paymentMode,
  String? lockedDaftarAwalUnit,
) {
  if (lockedDaftarAwalUnit == 'DB') {
    return 'baru';
  }
  if (lockedDaftarAwalUnit == 'DU') {
    return 'lama';
  }
  return paymentMode;
}

String _resolveStatusKey(dynamic status) {
  final normalized = '${status ?? ''}'.trim().toLowerCase();
  if (normalized.contains('ndalem')) {
    return 'ndalem';
  }
  if (normalized.contains('pengurus')) {
    return 'pengurus';
  }
  return 'tarbiyah';
}

Set<String> _allowedUnitCodesFor(String statusKey, String? paymentMode) {
  const rules = {
    'tarbiyah': {
      'baru': {'DB', 'SARP_B', 'PENG_B', 'RJB', 'KAL', 'KTS', 'SER'},
      'lama': {'DU', 'SARP_L', 'PENG_L', 'RJB', 'KAL'},
    },
    'ndalem': {
      'baru': {'DB', 'PENG_B', 'RJB', 'KAL', 'KTS', 'SER'},
      'lama': {'DU', 'PENG_L', 'RJB', 'KAL'},
    },
    'pengurus': {
      'baru': {'DB', 'PENG_B', 'RJB', 'KAL', 'KTS', 'SER'},
      'lama': {'DU', 'PENG_L', 'RJB', 'KAL'},
    },
  };

  const fallback = {
    'DB',
    'DU',
    'SARP_B',
    'SARP_L',
    'PENG_B',
    'PENG_L',
    'RJB',
    'KAL',
    'KTS',
    'SER',
  };

  if (paymentMode == null) {
    return fallback;
  }

  return rules[statusKey]?[paymentMode] ?? fallback;
}

String? _resolveUnitCode(String unitName) {
  final normalized = _normalizeUnitName(unitName);

  const aliasMap = {
    'DB': ['db', 'daftarbaru', 'daftarpondok'],
    'DU': ['du', 'daftarulang', 'daftarulanglama', 'pendaftaranulang', 'daftarlama'],
    'SARP_B': ['sarprasbaru', 'saranaprasaranabaru', 'sarpb'],
    'SARP_L': ['sarpraslama', 'saranaprasaranalama', 'sarpl', 'sarpras'],
    'PENG_B': ['pengairanbaru'],
    'PENG_L': ['pengairanlama'],
    'RJB': ['rojabiyah', 'rojabiyyah', 'rajabiyah', 'rjb', 'akhirussanah', 'akhirussanah', 'akhirussanahrojabiyah'],
    'KAL': ['kalender'],
    'KTS': ['kts', 'kartutandasantri'],
    'SER': ['seragam'],
  };

  for (final entry in aliasMap.entries) {
    if (entry.value.contains(normalized)) {
      return entry.key;
    }
  }

  if (normalized.contains('pengairan') && normalized.contains('baru')) {
    return 'PENG_B';
  }
  if (normalized.contains('pengairan') && normalized.contains('lama')) {
    return 'PENG_L';
  }
  if (normalized.contains('sarpras') && normalized.contains('baru')) {
    return 'SARP_B';
  }
  if (normalized.contains('sarpras') && normalized.contains('lama')) {
    return 'SARP_L';
  }

  return null;
}

String _normalizeUnitName(String value) {
  final lowered = value.toLowerCase().trim();
  return lowered.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}
